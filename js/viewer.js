(function ($) {
Drupal.behaviors.teiViewerTEIUpdate = {
  attach: function (context, settings) {
    var element = $("#paged-tei-seadragon-viewer-tei");
    var pager = $("#islandora_paged_tei_seadragon_pager");
    var get_page = function() {
      return pager.children("option:selected");
    };
    element.data("object", get_page().val());
    pager.change(function () {
      var pid = this.value;
      $.ajax(settings.basePath + "islandora/object/" + pid + "/tei_viewer/markup", {
        beforeSend: function (jqXHR, settings) {
          element.data("object", pid);
        },
        success: function (data, status, jqXHR) {
          if (element.data("object") == pid) {
            element.html(data);
          }
        }
      });
    });
    $("#tei-viewer-annotate").click(function() {
      window.location = Drupal.settings.basePath + "islandora/object/" + settings.islandoraOpenSeadragon.pid + "/annotation";
      return false;
    });
    var $occluded = $("#tei-viewer-occluded");
    $occluded.click(function() {
      var link = $(this);
      var page = get_page().text();
      var params = {
        "islandora_paged_content_page": page,
      };
      if (element.data("object") == settings.islandoraOpenSeadragon.pid) {
        $.ajax(settings.basePath + "islandora/object/" + element.data("object") + "/tei_viewer/find_occluded", {
          statusCode: {
            404: function () {
              alert(Drupal.t("An occluded version could not be found for @pid.", {
                "@pid": element.data("object")
              }));
            }
          },
          beforeSend: function () {
            $occluded.after('<div class="ajax-progress ajax-progress-throbber"><div class="throbber">&nbsp;</div></div>');
          },
          success: function (data, status, jqXHR) {
            params.occluded = true;
            window.location = location.pathname + "?" + $.param(params);
          }
        });
      }
      else {
        window.location = location.pathname + "?" + $.param(params);
      }
    });
    return false;
  }
};
})(jQuery);
