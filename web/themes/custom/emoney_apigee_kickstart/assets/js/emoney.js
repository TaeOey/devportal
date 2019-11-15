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

            for (var mutation in mutationsList) {
              if (mutationsList.hasOwnProperty(mutation)) {
                const element = mutationsList[mutation];

                if(element.type === 'childList') {
                  const tryOut = document.getElementsByClassName('try-out');
                  const schemeContainer = document.getElementsByClassName('scheme-container');

                  if(tryOut.length) {
                    for (let i = 0; i < tryOut.length; i++) {
                      $(tryOut[i]).remove();
                    }
                  }

                  if(schemeContainer.length) {
                    for (let i = 0; i < schemeContainer.length; i++) {
                      $(schemeContainer[i]).remove();
                    }
                  }
                }
              }
            }
          };

          const observer = new MutationObserver(callback);
          observer.observe(targetNode, config);
        });

        /** Implement feature to scroll to up */
        $('button.go-to-up').once('myModuleBehavior').each(function () {
          const goToUpButton = $(this);

          $(window).scroll(function() {
            const viewPort = $(window).height();
            const scrollTop = $(document).scrollTop();

            if(scrollTop > viewPort) {
              goToUpButton.addClass('go-to-up--visible');
            } else {
              goToUpButton.removeClass('go-to-up--visible');
            };
          });

          goToUpButton.click(function(){
            $('html, body').animate({
              scrollTop: 0
            }, 800, function() {
              goToUpButton.blur();
            });
          });
        });

        /** Add Stick Navigation */
        $('nav.navbar').once('myModuleBehavior').each(function () {
          const navBar = $(this);
          const brandImg = navBar.find('.navbar-brand img');
          const lg = 992;

          $(window).scroll(function() {
            const scrollTop = $(document).scrollTop();
            const widthViewPort = $(window).width();

            if(scrollTop >= navBar.height()) {
              widthViewPort > lg && brandImg.attr('src', '/sites/default/files/logo_blue.png');
              navBar.addClass('stick');
            } else {
              widthViewPort > lg && brandImg.attr('src', '/sites/default/files/logo.png');
              navBar.removeClass('stick');
            };
          });

          $(window).resize(function() {
            const widthViewPort = $(window).width();

            if(navBar.hasClass('stick')) {
              if(widthViewPort > lg) {
                brandImg.attr('src', '/sites/default/files/logo_blue.png');
              } else {
                brandImg.attr('src', '/sites/default/files/logo.png');
              }
            }
          });
        });
      }
    };
  })(jQuery, Drupal);
