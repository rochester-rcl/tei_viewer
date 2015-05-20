<?php
/**
 * @file
 * Themeing callbacks.
 */

/**
 * Preprocess variables for "tei_viewer_image_annotation_dialog" templates.
 */
function template_preprocess_tei_viewer_image_annotation_dialog(&$variables) {
  module_load_include('inc', 'islandora_image_annotation', 'theme/theme');
  module_load_include('inc', 'tei_viewer', 'includes/utilities');
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

/**
 * Process variables for "tei_viewer_image_annotation_dialog" templates.
 */
function template_process_tei_viewer_image_annotation_dialog(&$variables) {
  module_load_include('inc', 'islandora_image_annotation', 'theme/theme');
  template_process_islandora_image_annotation_dialog($variables);
  $variables['inclusion'] = drupal_render($variables['inclusion_array']);
}
