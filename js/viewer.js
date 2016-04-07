(function ($) {

    Drupal.behaviors.teiViewerTEIUpdate = {
        attach: function (context, settings) {
            var self = this;
            var element = $("#paged-tei-seadragon-viewer-tei");
            var pager = $("#islandora_paged_tei_seadragon_pager");
            var get_pid = function () {
                return pager.children("option:selected").val();
            };
            
            
            var get_url_page_number = function (pid) {
                return $("#hidden_paged_tei_seadragon_pager option[value='" + pid + "']" ).text();
            };
            
            element.data("object", get_url_page_number(get_pid()));

            $('.note').popover({trigger: 'manual'});
            $(document).on('click', function (e) {
                $(".note").popover('hide');
            });
            $(".note").click(function () {
                var self = this;
                $.each($(".note"), function (index, element) {
                    if (element !== self) {
                        $(element).popover('hide');
                    } else {
                        $(self).popover('toggle');
                    }
                });
                return false;
            });

            $("#paged-tei-seadragon-viewer-tei").scroll(function () {
                $(".popover").fadeOut(100);
                $(".note").popover('hide');
            });

            if ($(".no-markup").length > 0) {
                $("#yourButton").hide();
            } else {
                $("#yourButton").show();
            }


            // Monkey patch Drupal.settings.islandora_paged_tei_seadragon_update_page
            // to update compound block to ensure we always get the current one.
            // 
            // This overrides the existing islandora_paged_tei_seadragon_update_page
            var old_page_update = Drupal.settings.islandora_paged_tei_seadragon_update_page;

            Drupal.settings.islandora_paged_tei_seadragon_update_page = function (pid, page_number) {

                page_number = get_url_page_number(pid);           
                // Drop out here if we are the most current request.
                if (pid === Drupal.settings.islandora_paged_tei_seadragon.current_page) {
                    return;
                }

                Drupal.settings.islandora_paged_tei_seadragon.current_page = pid;

                //old_page_update(pid, page_number);
                // get the url parameters
                (function () {
                    var match,
                            pl = /\+/g, // Regex for replacing addition symbol with a space
                            search = /([^&=]+)=?([^&]*)/g,
                            decode = function (s) {
                                return decodeURIComponent(s.replace(pl, " "));
                            },
                            query = window.location.search.substring(1);

                    urlParams = {};
                    while (match = search.exec(query))
                        urlParams[decode(match[1])] = decode(match[2]);
                })();

                var viewOccluded = false;
                if (urlParams && urlParams['occluded'] && urlParams['occluded'] === "true") {
                    viewOccluded = true;
                }

                // Check if the new page has an occluded object and update the occluded
                // link display.
                $.ajax(settings.basePath + "islandora/object/" + pid + "/tei_viewer/find_occluded", {
                    success: function (data, status, jqXHR) {
                        var imagePid = pid;
                        if (data.found && viewOccluded) {
                            imagePid = data.pid;
                        }
                        self._handleNewPage(imagePid, pid, page_number, settings, viewOccluded, data.found);
                    },
                    error: function (error) {
                        console.log("error", error);
                    }
                });
            };

            $("#tei-viewer-annotate").click(function () {
                window.location = Drupal.settings.basePath + "islandora/object/" + settings.islandoraOpenSeadragon.pid + "/annotation";
                return false;
            });

            $("#tei-viewer-original").click(function () {
                var page = get_url_page_number(get_pid());
                var params = {
                    "islandora_paged_content_page": page,
                    "occluded": true
                };
                var $current = $(this)
                if (!$current.hasClass("active")) {
                    $current.addClass("active");
                    $("#tei-viewer-manuscript").removeClass("active");
                    window.location = location.pathname + "?" + $.param(params);
                }
            });

            $("#tei-viewer-manuscript").click(function () {
                var page = get_url_page_number(get_pid());
                var params = {
                    "islandora_paged_content_page": page
                };

                var $current = $(this)
                if (!$current.hasClass("active")) {
                    $current.addClass("active");
                    $("#tei-viewer-original").removeClass("active");
                    window.location = location.pathname + "?" + $.param(params);
                }
            });

            $(document).keydown(function (e) {
                switch (e.which) {
                    case 37: // left
                        $("#islandora-paged-tei-seadragon-navigate-left").trigger("click");
                        break;


                    case 39: // right
                        $("#islandora-paged-tei-seadragon-navigate-right").trigger("click");
                        break;

                    default:
                        return; // exit this handler for other keys
                }
                e.preventDefault(); // prevent the default action (scroll / move caret)
            });


            return false;
        },
        _handleNewPage: function (pid, contentPid, page_number, settings, viewOccluded, hasOccluded) {

            // Drop out here if we are the most current request.
            if (contentPid !== Drupal.settings.islandora_paged_tei_seadragon.current_page) {
                return;
            }

            // Update current URL.
            // @todo preserve query params here.
            var params = {};
            params.islandora_paged_content_page = page_number;
            if (viewOccluded) {
                params.occluded = true;
            }

            if (viewOccluded) {
                $("#tei-viewer-original").addClass("active");
                $("#tei-viewer-manuscript").removeClass("active");
            } else {
                $("#tei-viewer-original").removeClass("active");
                $("#tei-viewer-manuscript").addClass("active");
            }

            if (hasOccluded) {
                $("#tei-viewer-original").removeClass("hidden");
                $("#tei-viewer-original-only").addClass("hidden");
                $("#tei-viewer-manuscript").removeClass("hidden");
            } else {
                $("#tei-viewer-original").addClass("hidden");
                $("#tei-viewer-original-only").removeClass("hidden");
                $("#tei-viewer-manuscript").addClass("hidden");
            }

            // Update current page to prevent race conditions.
            Drupal.settings.islandora_paged_tei_seadragon.current_page = contentPid;
            $.ajax(settings.basePath + "islandora/object/" + contentPid + "/tei_viewer/markup", {
                success: function (data, status, jqXHR) {
                    // Drop out here if we are not the most current request.
                    if (contentPid !== Drupal.settings.islandora_paged_tei_seadragon.current_page) {
                        return;
                    }
                    var element = $("#paged-tei-seadragon-viewer-tei");
                    element.html(data);

                    if ($(".no-markup").length > 0) {
                        $("#yourButton").hide();
                    } else {
                        $("#yourButton").show();
                    }

                    // handle the popover manually
                    $('.note').popover({trigger: 'manual'});
                    $(document).on('click', function (e) {
                        $(".note").popover('hide');
                    });
                    $(".note").click(function () {
                        var self = this;
                        $.each($(".note"), function (index, element) {
                            if (element !== self) {
                                $(element).popover('hide');
                            } else {
                                $(self).popover('toggle');
                            }
                        });
                        return false;
                    });

                    $("#paged-tei-seadragon-viewer-tei").scroll(function () {
                        $(".popover").fadeOut(100);
                        $(".note").popover('hide');
                    });


                }
            });

            //only push on if this is not a back action
            if(!window.popped_state){
                var historyData = {};
                historyData.pid = pid;
                 history.pushState(historyData, 
                "", location.pathname + "?" + $.param(params));
            }
           
            window.popped_state = false;


            // Update page rendering.
            $.ajax({
                url: Drupal.settings.basePath + "islandora/rest/v1/object/"
                        + pid + "/datastream/JP2/token?" + $.param({"uses": 2}),
                cache: false,
                success: function (token) {
                    // Drop out here if we are not the most current request.

                    // Update seadragon.
                    settings.islandoraOpenSeadragon.resourceUri =
                            location.protocol + "//" + location.host + "/" +
                            Drupal.settings.basePath + "islandora/object/" + pid
                            + "/datastream/JP2/view?token=" + token;
                    tile_source = new OpenSeadragon.DjatokaTileSource(
                            settings.islandoraOpenSeadragon.settings.djatokaServerBaseURL,
                            settings.islandoraOpenSeadragon.resourceUri,
                            settings.islandoraOpenSeadragon
                            );
                    Drupal.settings.islandora_open_seadragon_viewer.open(tile_source);
                    // Updating the PID to keep it consistent, it isn't used.
                    settings.islandoraOpenSeadragon.pid = pid;


                    // Swap out datastream download links.
                    var iteration;
                    var page_dsids = Drupal.settings.islandora_paged_tei_seadragon.page_dsids;
                    for (iteration = 0; iteration < page_dsids.length; ++iteration) {
                        var dsid = page_dsids[iteration];
                        $("#paged-tei-seadragon-viewer-download-datastream-" + dsid).empty();
                        $.ajax({
                            url: Drupal.settings.basePath + "islandora/rest/v1/object/"
                                    + pid + "/datastream/" + dsid + "?" + $.param({"content": "FALSE"}),
                            cache: false,
                            success: function (datastream_info) {
                                // Drop out here if we are not the most current request.
                                if (contentPid !== Drupal.settings.islandora_paged_tei_seadragon.current_page) {
                                    return;
                                }
                                var kilobyte = 1024;
                                var megabyte = kilobyte * 1024;
                                var gigabyte = megabyte * 1024;
                                var terabyte = gigabyte * 1024;
                                var bytes = datastream_info.size;
                                var size = 0;

                                // Round is less precise than Islandora's PHP side.
                                if ((bytes >= 0) && (bytes < kilobyte)) {
                                    size = bytes + ' B';
                                }
                                else if ((bytes >= kilobyte) && (bytes < megabyte)) {
                                    size = Math.round(bytes / kilobyte * 100) / 100 + ' KiB';
                                }
                                else if ((bytes >= megabyte) && (bytes < gigabyte)) {
                                    size = Math.round(bytes / megabyte * 100) / 100 + ' MiB';
                                }
                                else if ((bytes >= gigabyte) && (bytes < terabyte)) {
                                    size = Math.round(bytes / gigabyte * 100) / 100 + ' GiB';
                                }
                                else if (bytes >= terabyte) {
                                    size = Math.round(bytes / terabyte * 100) / 100 + ' TiB';
                                }
                                else {
                                    size = bytes + ' B';
                                }
                                download = "<div>" + Drupal.settings.islandora_paged_tei_seadragon.download_prefix
                                        + "<a href=" + Drupal.settings.basePath + "islandora/object/"
                                        + pid + "/datastream/" + datastream_info.dsid + "/download" + ">" + datastream_info.dsid + "<span> " + size + " </span>" + "</a></div>";
                                $("#paged-tei-seadragon-viewer-download-datastream-" + datastream_info.dsid).html(download);
                            }
                        });
                    }

                }
            });
        }
    };
    
    
    window.onpopstate = function (event) {
        //set pop state to prevent pushing onto history state later on
        window.popped_state = true;
        //force navigation
        if (event.state && event.state && event.state.pid) {
            $("#islandora_paged_tei_seadragon_pager").val(event.state.pid).trigger('change');
        } else {
            //use url if no state available
            var match,
                    pl = /\+/g, // Regex for replacing addition symbol with a space
                    search = /([^&=]+)=?([^&]*)/g,
                    decode = function (s) {
                        return decodeURIComponent(s.replace(pl, " "));
                    },
                    query = window.location.search.substring(1);

            urlParams = {};
            while (match = search.exec(query))
                urlParams[decode(match[1])] = decode(match[2]);

            
            if (urlParams && urlParams['islandora_paged_content_page']) {
                var $option = $('#hidden_paged_tei_seadragon_pager option').filter(function (i, e) {
                    //console.log($(e).text(), urlParams['islandora_paged_content_page'])
                    return $(e).text() == urlParams['islandora_paged_content_page'];
                });

                if($option && $option.val()){
                    $("#islandora_paged_tei_seadragon_pager").val($option.val()).trigger('change');
                }
                
            }
        }

    };

})(jQuery);
