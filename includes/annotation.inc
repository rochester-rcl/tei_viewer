<?php
/**
 * @file
 * Annotation callback(s).
 */

/**
 * Page callback; add an annotation with an additional relationship.
 */
function tei_viewer_add_annotation(AbstractObject $object) {
  $properties = filter_input(INPUT_POST, 'raw_properties', FILTER_DEFAULT, FILTER_REQUIRE_ARRAY);
  $inclusion = islandora_object_load($properties['inclusion']);

  module_load_include('inc', 'islandora_image_annotation', 'includes/annotation');
  try {
    $annotation_object = islandora_image_annotation_create_annotation($object);
    $annotation_object->relationships->add(FEDORA_RELS_EXT_URI, 'isDescriptionOf', $inclusion->id);
    islandora_add_object($annotation_object);
    echo $annotation_object->id;
  }
  catch (IslandoraImageAnnotationPropertyMissingException $e) {
    drupal_add_http_header('Status', '400 Bad Request');
  }
  drupal_exit();
}
