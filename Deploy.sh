#!/bin/bash

#Declare variables
CWD=`pwd`
APIGEE_DRUPAL_SOURCE_ROOT=/var/www/devportal/
APIGEE_DRUPAL_WEB_DOCROOT=/var/www/devportal/web
APIGEE_DRUPAL_SOURCE_ROOT_RELEASE=/var/www/"#{Octopus.Release.Number}"
EMONEY_DEVPORTAL_PROJECT_DIRECTORY=/opt/apigee/data/apigee-drupal-devportal/sites/all
PACKAGE_ID=`basename $(pwd)`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
DRUPAL_BACKUP="sites-all.tar.gz"
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="devportal-backup-${CURRENT_DATETIME}.sql"
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
${CWD}/drush version

#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} sql-dump > ${BACKUP_DIRECTORY}/${DB_BACKUP}

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

sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type d -exec chmod 755 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} -type f -exec chmod 644 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE}/web/sites/default/ -type d -exec chmod 775 {} \;
#sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/web/sites/default/files -type d -exec chmod 775 {} \;

#Fix symlink
sudo ln -sf ${APIGEE_DRUPAL_SOURCE_ROOT_RELEASE} ${APIGEE_DRUPAL_SOURCE_ROOT}

#Initialize updates:
echo "Initializing updates"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} drush updb -y

#Actualize configuration layer:
echo "Actualize configuration layer"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} drush cim -y

#Clear caches:
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} drush cr

#Delete old versions