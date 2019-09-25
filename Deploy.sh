#!/bin/bash

#Declare variables
CWD=`pwd`
APIGEE_DRUPAL_SOURCE_ROOT=/var/www/devportal
APIGEE_DRUPAL_WEB_DOCROOT=/var/www/devportal/web
APIGEE_DRUPAL_SOURCE_ROOT_RELEASE=/var/www/"#{Octopus.Release.Number}"
WEB_FILES_ROOT=/var/www/devportal/web/sites/default/files
WEB_FILES_STORAGE=/var/www/files
#EMONEY_DEVPORTAL_PROJECT_DIRECTORY=/opt/apigee/data/apigee-drupal-devportal/sites/all
PACKAGE_ID=`basename $(pwd)`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
DRUPAL_BACKUP="sites-all.tar.gz"
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="devportal-backup-${CURRENT_DATETIME}.sql.gz"
DB_IP="#{DrupalDbHost}"
DB_PORT="#{DrupalDbPort}"
DB_NAME="#{DrupalDbName}"
DB_USER="#{DrupalUser}"
DB_PASSWORD="#{DrupalPassword}"
#DB_PREFIX="#{DrupalPrefix}"
DB_DRIVER="#{DrupalDriver}"

#TWO_DP_SETUP="#{TwoDevPortalSetup}"
#SECOND_DP_IP="#{SecondDevPortalIP}"

#Check if backup directory exists
if [ ! -d "${BACKUP_DIRECTORY}" ]; then
    sudo mkdir -p ${BACKUP_DIRECTORY}
fi

#Install drush
unzip -o drush.zip
chmod 755 drush
mv drush drush.phar
ln -s ${CWD}/drush.phar ${CWD}/drush
echo "test drush version"
echo "${CWD}"
${CWD}/drush version

#Backup Drupal data - not necessary??
# echo "Create drupal directories backup in ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP}"
# sudo tar czfP  ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP} -C ${APIGEE_DRUPAL_SOURCE_ROOT} ${DRUPAL_DIR_LIST}

#Copy rollback script - not done yet
#echo "Create rollback script ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}"
#sudo cp ${ROLLBACK_SCRIPT} ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}
#sudo cp drush.zip ${BACKUP_DIRECTORY}/drush.zip

echo "Creating and Fixing Permission On ${APIGEE_DRUPAL_SOURCE_ROOT}"

sudo mkdir ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}

sudo rsync -r * ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}
sudo cp ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/settingstemplate.config ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/web/sites/default/settings.php

sudo chown nginx:nginx -R ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type d -exec chmod 755 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type f -exec chmod 644 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/web/sites/default/ -type d -exec chmod 775 {} \;
sudo chmod 777 ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/vendor/bin/drush.launcher
sudo chmod 777 ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/vendor/drush/drush/drush.launcher
#sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/web/sites/default/files -type d -exec chmod 775 {} \;

#Backup Drupal database
# echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
# echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
# sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} sql-dump --gzip > ${BACKUP_DIRECTORY}/${DB_BACKUP}

#Fix symlink
APIGEE_DRUPAL_SOURCE_ROOT_RELEASE_OLD=$(readlink ${APIGEE_DRUPAL_SOURCE_ROOT})
echo "symlink ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} to ${APIGEE_DRUPAL_SOURCE_ROOT}"
sudo ln -sfvn ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} ${APIGEE_DRUPAL_SOURCE_ROOT}

echo "symlink ${WEB_FILES_STORAGE} to ${WEB_FILES_ROOT}"
sudo ln -sfvn ${WEB_FILES_STORAGE} ${WEB_FILES_ROOT}

#Actualize configuration layer:
sudo drush cc drush
echo "Actualize configuration layer"
echo "${CWD}"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} cim -y

#Initialize updates:
echo "Initializing updates"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} updb -y

#Clear caches:
echo "Clear caches"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} cr

#Delete old versions
sudo rm -rf $APIGEE_DRUPAL_SOURCE_ROOT_RELEASE_OLD

#Delete old database backups
DB_BACKUP_PATTERN=`sudo echo $DB_BACKUP | sed -E 's/[[:digit:]]{8}-[[:digit:]]{6}/*/g'`
sudo ls -t ${BACKUP_DIRECTORY}/${DB_BACKUP_PATTERN} | tail -n +4 | xargs rm --