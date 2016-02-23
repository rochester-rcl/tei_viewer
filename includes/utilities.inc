<?php
/**
 * @file
 * Miscellaneous utility functions.
 */

/**
 * Get markup for the given object as a renderable array.
 *
 * @param AbstractObject $object
 *   The object for which to generate markup.
 *
 * @return array
 *   A renderable array.
 */
function tei_viewer_get_markup(AbstractObject $object) {
  $path = drupal_get_path('module', 'tei_viewer') . '/tei_transforms';
  if (isset($object['TEI'])) {
    $type = 'reading';
    $input = new DOMDocument();
    $content = preg_replace('/<\?xml-model .*\?>/', '', $object['TEI']->content);
    $input->loadXML($content);
    $wrapper_xslt_doc = new DOMDocument();
    $wrapper_xslt_doc->load("$path/wrap.xslt");
    $wrapper_xslt = new XSLTProcessor();
    $wrapper_xslt->importStylesheet($wrapper_xslt_doc);
    $wrapped = $wrapper_xslt->transformToDoc($input);

    require_once "$path/refcounter.php";
    \TEIViewer\count_refs($wrapped);
    $unwrapper_xslt_doc = new DOMDocument();
    $unwrapper_xslt_doc->load("$path/unwrap.xslt");
    $unwrapper_xslt = new XSLTProcessor();
    $unwrapper_xslt->importStylesheet($unwrapper_xslt_doc);
    $unwrapper_xslt->setParameter('', 'type', $type);
    $unwrapped_doc = $unwrapper_xslt->transformToDoc($wrapped);

    // Remove non-display info from reading TEI.
    $xpath = new DOMXpath($unwrapped_doc);
    $xpath->registerNamespace('tei', 'http://www.tei-c.org/ns/1.0');
    $xpath->registerNamespace('rdf', 'http://www.w3.org/1999/02/22-rdf-syntax-ns#');
    $nukable = $xpath->query('//rdf:RDF | //tei:teiHeader');
    foreach ($nukable as $nukee) {
      $nukee->parentNode->removeChild($nukee);
    }

    $tempfile_object = file_save_data($unwrapped_doc->saveXML(), file_default_scheme() . '://');
    $source = file_create_url($tempfile_object->uri);
    $style = file_create_url("$path/tei2html.xslt");
    $islandora_url = variable_get('islandora_base_url', 'http://localhost:8080/fedora');
    $tomcat_url = str_replace('/fedora', '', $islandora_url);
    $saxon_url = url("$tomcat_url/saxon/SaxonServlet", array(
      'absolute' => TRUE,
      'external' => TRUE,
      'query' => array(
        'style' => $style,
        'source' => $source,
        'clear-stylesheet-cache' => 'yes',
        'css_base' => file_create_url($path),
        'type' => $type,
      ),
    ));
    $result = drupal_http_request($saxon_url);
    file_delete($tempfile_object);
    if (isset($result->error)) {
      $markup = "$saxon_url $result->error";
    }
    else {
     
      // don't show errors
      libxml_use_internal_errors(true);
      $my_data = new DOMDocument();
      $my_data->loadHTML($result->data);
      $markup = $my_data->saveHTML();
    }
  }

  return array(
    '#attached' => array(
      'css' => array(
        "$path/stylesheets/screen.css" => array(
          'media' => 'screen, projection',
        ),
        "$path/stylesheets/print.css" => array(
          'media' => 'print',
        ),
        "$path/stylesheets/ie.css" => array(
          'media' => 'screen, projection',
          'browsers' => array(
            '!IE' => FALSE,
            'IE' => TRUE,
          ),
        ),
      ),
    ),
    '#type' => 'item',
    '#title' => $object->label,
    '#markup' => isset($markup) ? $markup : t('No markup available.'),
  );
}

/**
 * Helper to actually find an occluded version of an object.
 *
 * @param AbstractObject $object
 *   The object for which to check for an occluded version.
 */
function tei_viewer_lookup_occluded(AbstractObject $object) {
  $qp = new IslandoraSolrQueryProcessor();
  $qp->buildQuery(format_string('!field:"!value"', array(
    '!field' => 'RELS_EXT_isPartOf_uri_ms',
    '!value' => "info:fedora/{$object->id}",
  )));
  $qp->solrParams['fq'][] = format_string('!field:"!value"', array(
    '!field' => 'RELS_EXT_hasModel_uri_ms',
    '!value' => 'info:fedora/islandora:sp_large_image_cmodel',
  ));
  $qp->solrParams['fl'] = 'PID';
  $qp->solrLimit = 1;
  $qp->executeQuery();

  $results = $qp->islandoraSolrResult['response']['objects'];
  if (empty($results)) {
    return FALSE;
  }
  else {
    $result = reset($results);
    return $result['PID'];
  }
}

/**
 * Map annotation URNs to inclusion URLs.
 *
 * @param AbstractObject $object
 *   The object for which to get annotations.
 *
 * @return array
 *   An associative array mapping annotation URN URIs to Islandora URLs for
 *   inclusions, if applicable.
 */
function tei_viewer_get_linked_inclusions(AbstractObject $object) {
  module_load_include('inc', 'islandora_image_annotation', 'includes/utils');
  $settings = islandora_image_annotation_get_settings($object);
  $annotations = $settings['islandoraImageAnnotationList']['annotations'];
  $map_to_url = function ($info) {
    $annotation = islandora_object_load($info['pid']);
    if ($descriptions = $annotation->relationships->get(FEDORA_RELS_EXT_URI, 'isDescriptionOf')) {
      $description = reset($descriptions);
      return url("islandora/object/{$description['object']['value']}");
    }
    return FALSE;
  };
  $results = array_filter(array_map($map_to_url, $annotations));
  $map_pid_to_urn = function ($pid) {
    $annotation = islandora_object_load($pid);
    $urns = $annotation->relationships->get(ISLANDORA_RELS_EXT_URI, 'hasURN');
    $urn = reset($urns);
    return $urn['object']['value'];
  };
  return $results ?
    array_combine(array_map($map_pid_to_urn, array_keys($results)), array_values($results)) :
    array();
}

/**
 * Helper to get inclusions.
 *
 * @param AbstractObject $object
 *   An AbstractObject representing either the occluded or unoccluded image.
 *
 * @return array
 *   An associtive array mapping inclusion PIDs to their labels.
 */
function tei_viewer_get_inclusions(AbstractObject $object) {
  // We need the page in order to get down to the inclusions/occlusions... Let's
  // find it.
  $page_cmodel = 'islandora:pageCModel';
  $page_pid = NULL;
  if (in_array($page_cmodel, $object->models)) {
    // The object itself is a page.
    $page_pid = $object->id;
  }
  else {
    foreach ($object->relationships->get(FEDORA_RELS_EXT_URI, 'isPartOf') as $relationship) {
      $parent = islandora_object_load($relationship['object']['value']);
      if (in_array($page_cmodel, $parent->models)) {
        $page_pid = $parent->id;
        break;
      }
    }
  }

  if ($page_pid === NULL) {
    // Failed to find the page... Nothing from which to select.
    return array();
  }

  $results = islandora_compound_object_get_parts($page_pid, TRUE);
  $not_already_an_annotation = function ($info) {
    $object = islandora_object_load($info['pid']);
    return !in_array('islandora:OACCModel', $object->models);
  };
  $map_to_title = function ($info) {
    return $info['title'];
  };
  return array_map($map_to_title, array_filter($results, $not_already_an_annotation));
}
