<?php
namespace Drupal\emoney_main\Plugin\Menu;
use Drupal\user\Plugin\Menu\LoginLogoutMenuLink;

class EmoneyLoginLogoutMenuLink extends LoginLogoutMenuLink {
  public function getTitle() {
    if ($this->currentUser->isAuthenticated()) {
      return $this->t('Sign Out');
    }
    else {
      return $this->t('Sign In');
    }
  }
}
