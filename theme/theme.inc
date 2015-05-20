<?php

function template_preprocess_tei_viewer_image_annotation_dialog(&$variables) {
  module_load_include('inc', 'islandora_image_annotation', 'theme/theme');
  template_preprocess_islandora_image_annotation_dialog($variables);
  $mod_path = drupal_get_path('module', 'tei_viewer');
  $variables['inclusion_array'] = array(
    '#attached' => array(
      'js' => array(
        "$mod_path/js/annotation.js",
      ),
    ),
    '#id' => 'inclusion',
    '#name' => 'inclusion',
    '#title' => t('Inclusions'),
    '#type' => 'select',
    '#options' => array(
      NULL => t('New Annotation Object'),
    ) + tei_viewer_get_inclusions($variables['object']),
  );
}

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

function template_process_tei_viewer_image_annotation_dialog(&$variables) {
  module_load_include('inc', 'islandora_image_annotation', 'theme/theme');
  template_process_islandora_image_annotation_dialog($variables);
  $variables['inclusion'] = drupal_render($variables['inclusion_array']);
}
