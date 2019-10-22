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

        /* Match the card width when the page is loaded */
        $(document).ready(function() {
          var card_width = $('.path-frontpage .paragraph.card-group--default:not(".card-group-2") .card').width();
            $('.path-frontpage .paragraph.card-group--default.card-group-2 .card-deck .card').each(function(){
              $(this).css('width', card_width);
            });
         });

        /* Resize the cards in the second row to match with the frist row in homepage*/ 
        $(window).resize(function() {
          var card_width = $('.path-frontpage .paragraph.card-group--default:not(".card-group-2") .card').width();
          $('.path-frontpage .paragraph.card-group--default.card-group-2 .card-deck .card').each(function(){
            $(this).css('width', card_width);
          });
        });   

        /** Add toggle feature to accordion paragraph */
        $('.paragraph.accordion', context).once('myModuleBehavior').each(function () {
          const accordion = $(this);
          const title = accordion.find('.accordion__title');
          const arrowUp = 'fa-angle-up';
          const arrowDown = 'fa-angle-down';

          title.append('<i class="fas ' + arrowDown + '"></i>');

          title.click(function() {
            const arrow = $(this).find('svg');
            accordion.toggleClass('accordion--expanded');
            arrow.toggleClass(arrowUp + ' ' + arrowDown)
          });
        });

        /** Add toggle feature to Support page */
        $('.faq-question', context).once('myModuleBehavior').each(function () {
          const question = $(this);
          const answer = question.next('.faq-answer');

          question.click(function() {
            const arrow = $(this).find('svg');
            answer.toggleClass('faq-answer--open');
            arrow.toggleClass('fa-chevron-up fa-chevron-down');
          });
        });

        /** Remove try-out section from API page */
        $('#swagger-ui-spec-0').once('myModuleBehavior').each(function () {

          const targetNode = document.getElementById('swagger-ui-spec-0');
          const config = { attributes: true, childList: true, subtree: true };

          const callback = function(mutationsList, observer) {
            for(let mutation of mutationsList) {
              if(mutation.type === 'childList') {
                const tryOut = document.getElementsByClassName('try-out');
                const schemeContainer = document.getElementsByClassName('scheme-container');

                if(tryOut.length) {
                  for (let i = 0; i < tryOut.length; i++) {
                    tryOut[i].remove();
                  }
                }

                if(schemeContainer.length) {
                  for (let i = 0; i < schemeContainer.length; i++) {
                    schemeContainer[i].remove();
                  }
                }
              }
            }
          };

          const observer = new MutationObserver(callback);
          observer.observe(targetNode, config);
        });
      }
    };
  })(jQuery, Drupal);
