<?php

namespace Drupal\emoney_main\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\FilterResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

class EmoneyResponseHeadersSubscriber implements EventSubscriberInterface {

  public function onRespond(FilterResponseEvent $event) {
    $response = $event->getResponse();
    $response->headers->remove('x-generator');
    $response->headers->remove('x-drupal-cache');
    $response->headers->remove('x-drupal-cache-tags');
    $response->headers->remove('x-drupal-cache-contexts');
    $response->headers->remove('x-drupal-dynamic-cache');
    $response->headers->set('Content-Security-Policy', 'script-src "self"');
    $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    $response->headers->set('Referrer-Policy', 'strict-origin');
    $response->headers->set('Feature-Policy', 'vibrate "self"; speaker "self"; camera "self"; payment "none"; push "none"');
  }

  public static function getSubscribedEvents() {
    $events[KernelEvents::RESPONSE][] = ['onRespond', -100];
    return $events;
  }
}
