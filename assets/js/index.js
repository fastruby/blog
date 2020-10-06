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
    });

    const searchForm = document.getElementById('search-form-wrapper-sidebar');
    const searchInput = document.getElementById('search-input-sidebar');
    const searchFormNav = document.getElementById('search-form-wrapper-nav');
    const searchInputNav = document.getElementById('search-input-nav');

     document.getElementById('close-button-sidebar').addEventListener('click', (e) => {
       e.preventDefault()
       searchForm.classList.remove('show-search')
       searchInput.value = ''
     })

     document.getElementById('close-button-nav').addEventListener('click', (e) => {
       e.preventDefault()
       searchFormNav.classList.remove('show-search')
       searchInputNav.value = ''
     })

     document.getElementById('search-input-sidebar').addEventListener('input', (e) => {
       if (e.target.value !== '') {
         searchForm.classList.add('show-search')
       } else {
         searchForm.classList.remove('show-search')
       }
     })

     document.getElementById('search-input-nav').addEventListener('input', (e) => {
       if (e.target.value !== '') {
         searchFormNav.classList.add('show-search')
       } else {
         searchFormNav.classList.remove('show-search')
       }
     })

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

        var headerHeight = $("header").outerHeight();
        var scrollTop = $(document).scrollTop();
        var viewportWidth = $(document).width();

        if(scrollTop >= headerHeight && viewportWidth >= 768){
            $(".sidebar-container").addClass("fixed");
        }else if(viewportWidth < 768){
            $(".sidebar-container").addClass("fixed");
        }else if(scrollTop === 0){
            $(".sidebar-container").removeClass("fixed");
        }

        if(scrollTop <= headerHeight){
            $("header").removeClass("fixed");
        }else if(scrollTop > headerHeight){
            $("header").addClass("fixed");
        }

    })

    $('.navbar-toggler').click(function(){
        $(this).toggleClass('open');
    });

})(jQuery);
