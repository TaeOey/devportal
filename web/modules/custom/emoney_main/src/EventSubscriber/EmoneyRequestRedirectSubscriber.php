<?php

namespace Drupal\emoney_main\EventSubscriber;

use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\GetResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;


class EmoneyRequestRedirectSubscriber implements EventSubscriberInterface {

  public function onKernelRequest(GetResponseEvent $event) {
    $request = $event->getRequest();
    $logged_in = \Drupal::currentUser()->isAuthenticated();
    if ($logged_in && $request->getPathInfo() == '/apis') {
      $response = new RedirectResponse('/api/all-apis', 307);
      $event->setResponse($response);
      $event->stopPropagation();
    }
  }

  public static function getSubscribedEvents() {
    $events[KernelEvents::REQUEST][] = ['onKernelRequest'];
    return $events;
  }
}
