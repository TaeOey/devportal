<?php

namespace Drupal\emoney_main\EventSubscriber;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\KernelEvents;

class EmoneyRequestRedirectSubscriber implements EventSubscriberInterface {

  public function onKernelRequest($event) {
    $request = $event;
//    $foo = $response->getTargetUrl();
//    if ($response instanceOf RedirectResponse && $response->getTargetUrl() == 'http://example.com') {
//      $response->setTargetUrl('http://example2.com');
//    }
  }

  public static function getSubscribedEvents() {
    $events[KernelEvents::REQUEST][] = ['onKernelRequest'];
    return $events;
  }
}
