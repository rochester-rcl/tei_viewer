(function ($) {
var base = '#islandora-image-annotation-dialog';
Drupal.behaviors.teiViewerAnnotation = {
  attach: function (context, drupal_settings) {
    $(base).once('tei-viewer-annotation', function () {
      var IIAD = Drupal.IslandoraImageAnnotationDialog.getInstance();
      var that = IIAD;
      var old_show = IIAD.show;
      var old_ingest = IIAD.ingestAnnotation;
      var $dialog = $(base);
      var settings = drupal_settings.islandoraImageAnnotationDialog;

      IIAD.ingestAnnotation = function (values) {
        if (typeof values.inclusion == 'undefined' || values.inclusion == '') {
          old_ingest(that.createAnnotation(values));
          return;
        }

        // XXX: "Shapes" have some recursion, so cannot be serialized easily.
        var simplified = jQuery.extend({}, values);
        delete simplified.shapes;

        $.ajax({
          type: 'POST',
          async: true,
          url: IIAUtils.url('islandora/object/' + settings.pid + '/tei_viewer/annotation/add'),
          data: {
            // Create RDFa representing the current annotation, all the
            // parameters are required. Except entityID, entityLabel, it also
            // generates identifiers for the annotation and it's content.
            data: that.createAnnotation(values),
            raw_properties: simplified,
          },
          success: function (pid) {
            var url = IIAUtils.url('islandora/object/' + settings.pid + '/annotation/get/' + pid);
            //Drupal.IslandoraImageAnnotation.getInstance().fetchTriples(url);
          },
          error: function () {
            console.log('Failed to Create Annotation for: ' + settings.pid);
          }
        });
      }

      IIAD.show = function (annotation) {
        if (typeof annotation != 'undefined') {
          // Update handling can be the same.
          old_show(annotation);
          return;
        }

        $dialog.dialog($.extend(IIAD.defaultDialogProperties, {
          title: Drupal.t('Annotate'),
          open: function () {
            var canvas = Drupal.IslandoraImageAnnotationCanvas.getInstance();
            // Clear the form to be safe.
            that.clearForm();
            // If we aren't editing an existing annotation we must be creating a
            // new one, so prepare the canvas.
            canvas.startAnnotating(canvas.getCurrentCanvas(), that.getAnnotationProperties);
          },
          close: function () {
            // Stop all annotations.
            var canvas = Drupal.IslandoraImageAnnotationCanvas.getInstance();
            canvas.stopAnnotating(canvas.getCurrentCanvas());
            // Reset to defaults.
            that.clearForm();
          },
          buttons: [{
            text: Drupal.t('Save'),
            // Assumes only one canvas with a valid 'canvas' attribute.
            click: function () {
              var values = that.getFormValues();

              // Minimally we only allow users to create content if they have
              // entered a title and annotation.
              if (!values.text || !values.title) {
                alert(Drupal.t('An annotation needs both title and content'));
                return 0;
              }
              // Also the user must have actually marked up the image.
              if (values.shapes.length === 0) {
                alert(Drupal.t('You must draw a shape around the target.'));
                return 0;
              }

              // Set default type if not specified.
              values.type = (values.type === '' || values.type === null) ? Drupal.t('unclassified') : values.type;

              that.ingestAnnotation(values);
              $dialog.dialog('close');
            }
          }, {
            text: Drupal.t('Cancel'),
            click: function () {
              $dialog.dialog('close');
            }
          }]
        }));
      };
    });
  }
};
})(jQuery);
