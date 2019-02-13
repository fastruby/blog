/**
 * Main JS file for Casper behaviours
 */

/* globals jQuery, document */
(function ($, sr, undefined) {
    "use strict";

    var $document = $(document);

    $document.ready(function () {

        var $postContent = $(".post-content");
        $postContent.fitVids();

        $(".scroll-down").arctic_scroll();

        $(".adv-close").click(function (event) {
            $("#advertisement").hide();
            event.preventDefault();
        });

    });

    // Arctic Scroll by Paul Adam Davis
    // https://github.com/PaulAdamDavis/Arctic-Scroll
    $.fn.arctic_scroll = function (options) {

        var defaults = {
            elem: $(this),
            speed: 500
        },

        allOptions = $.extend(defaults, options);

        allOptions.elem.click(function (event) {
            event.preventDefault();
            var $this = $(this),
                $htmlBody = $('html, body'),
                offset = ($this.attr('data-offset')) ? $this.attr('data-offset') : false,
                position = ($this.attr('data-position')) ? $this.attr('data-position') : false,
                toMove;

            if (offset) {
                toMove = parseInt(offset);
                $htmlBody.stop(true, false).animate({scrollTop: ($(this.hash).offset().top + toMove) }, allOptions.speed);
            } else if (position) {
                toMove = parseInt(position);
                $htmlBody.stop(true, false).animate({scrollTop: toMove }, allOptions.speed);
            } else {
                $htmlBody.stop(true, false).animate({scrollTop: ($(this.hash).offset().top) }, allOptions.speed);
            }
        });

    };

    $document.scroll(function(){

        var headerHeight = $(".main-header").outerHeight();
        var scrollTop = $(document).scrollTop();
        var viewportWidth = $(document).width();
      
        if(scrollTop >= headerHeight && viewportWidth >= 768){
            $("#sidebar").addClass("fixed");
            $(".main-header").addClass("fixed");
        }else if(viewportWidth < 768){
            $("#sidebar").addClass("fixed");
            $(".main-header").addClass("fixed");
        }else if(scrollTop === 0){
            $(".main-header").removeClass("fixed");
            $("#sidebar").removeClass("fixed");
        }
      
    })
    
})(jQuery);
