#!/bin/bash

#Declare variables
CWD=`pwd`
APIGEE_DRUPAL_SOURCE_ROOT=/var/www/devportal
APIGEE_DRUPAL_WEB_DOCROOT=/var/www/devportal/web
APIGEE_DRUPAL_SOURCE_ROOT_RELEASE=/var/www/"#{Octopus.Release.Number}"
WEB_FILES_ROOT=/var/www/devportal/web/sites/default/files
WEB_FILES_STORAGE=/var/www/files
PACKAGE_ID=`basename $(pwd)`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
DRUPAL_BACKUP="sites-all.tar.gz"
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="devportal-backup-${CURRENT_DATETIME}.sql.gz"

#Check if backup directory exists
if [ ! -d "${BACKUP_DIRECTORY}" ]; then
    sudo mkdir -p ${BACKUP_DIRECTORY}
fi

unzip -o drush.zip
chmod 755 drush
mv drush drush.phar
sudo ln -s ${CWD}/drush.phar ${CWD}/drush
echo "test drush version"
sudo ${CWD}/drush version

#Copy rollback script - not done yet
#echo "Create rollback script ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}"
#sudo cp ${ROLLBACK_SCRIPT} ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}
#sudo cp drush.zip ${BACKUP_DIRECTORY}/drush.zip

echo "Creating and Fixing Permission On ${APIGEE_DRUPAL_SOURCE_ROOT}"

sudo mkdir ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}

sudo rsync -r * ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}
echo "copying settings file"
sudo cp ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/settingstemplate.config ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/web/sites/default/settings.php

echo "test drush version"
#cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo ${CWD}/drush version

sudo chown nginx:nginx -R ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type d -exec chmod 755 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type f -exec chmod 644 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/web/sites/default/ -type d -exec chmod 775 {} \;
sudo chmod 777 ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/vendor/bin/drush.launcher
sudo chmod 777 ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/vendor/drush/drush/drush.launcher
#sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/web/sites/default/files -type d -exec chmod 775 {} \;

#Fix symlink
APIGEE_DRUPAL_SOURCE_ROOT_RELEASE_OLD=$(readlink ${APIGEE_DRUPAL_SOURCE_ROOT})
echo "symlink ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} to ${APIGEE_DRUPAL_SOURCE_ROOT}"
sudo ln -sfvn ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} ${APIGEE_DRUPAL_SOURCE_ROOT}

echo "symlink ${WEB_FILES_STORAGE} to ${WEB_FILES_ROOT}"
sudo ln -sfvn ${WEB_FILES_STORAGE} ${WEB_FILES_ROOT}

#Actualize configuration layer:
#sudo ${CWD}/drush cc drush
sudo pwd
sudo drush version
echo "drushccdrush"
sudo ${CWD}/drush cc drush

echo "Actualize configuration layer"
#sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} cim -y
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} cim -y

#Initialize updates:
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} updb -y
sudo drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} updb -y

#Clear caches:
echo "Clear caches"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} cr

#Delete old versions
sudo rm -rf $APIGEE_DRUPAL_SOURCE_ROOT_RELEASE_OLD