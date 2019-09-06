/**
 * @file
 * Contains Emoney Apigee Kickstart customizations
 */

(function ($, Drupal) {
    Drupal.behaviors.myModuleBehavior = {
      attach: function (context, settings) {
        $('.paragraph.card-group--default', context).once('myModuleBehavior').each(function () {
          var card_count = $(this).find('.card').length;
          if (card_count == 2) {
            $(this).addClass('card-group-2');
          }

        });

        /** Add toggle feature to accordion paragraph */
        $('.paragraph.accordion', context).once('myModuleBehavior').each(function () {
          const accordion = $(this);
          const title = $(this).find('.accordion__title');
          const expandedClass = 'accordion--expanded';
          const arrowUp = 'fa-angle-up';
          const arrowDown = 'fa-angle-down';

          title.append('<i class="fas ' + arrowDown + '"></i>');

          title.click(function() {
            if(accordion.hasClass(expandedClass)) {
              accordion.removeClass(expandedClass);
              $(this).find('svg').removeClass(arrowUp);
              $(this).find('svg').addClass(arrowDown);
            } else {
              accordion.addClass(expandedClass);
              $(this).find('svg').removeClass(arrowDown);
              $(this).find('svg').addClass(arrowUp);
            }
          });

        });
      }
    };
  })(jQuery, Drupal);
