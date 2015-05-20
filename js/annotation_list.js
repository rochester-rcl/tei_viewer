/**
 * @file
 * List overrides.
 *
 * This file MUST be weighted after the core islandora_image_annotation_list.js.
 */
(function ($) {
  var old_create = Drupal.IslandoraImageAnnotationList.prototype.createAnnotation;
  Drupal.IslandoraImageAnnotationList.prototype.createAnnotation = function (annotation) {
    var $annotation = old_create.call(this, annotation);

    if (typeof Drupal.settings.teiViewerList.linklist[annotation.id] != 'undefined') {
      $annotation.find('.comment-text').append(Drupal.t('<a href="@link">Inclusion</a>', {
        '@link': Drupal.settings.teiViewerList.linklist[annotation.id],
      }));
    }

    return $annotation;
  };
})(jQuery);
