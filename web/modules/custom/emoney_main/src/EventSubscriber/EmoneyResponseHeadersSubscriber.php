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
  }

  public static function getSubscribedEvents() {
    $events[KernelEvents::RESPONSE][] = ['onRespond', -100];
    return $events;
  }
}
