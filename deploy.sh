#!/bin/bash

#Declare variables
CWD=`pwd`
APIGEE_DRUPAL_SOURCE_ROOT=/var/www/devportal
APIGEE_DRUPAL_WEB_DOCROOT=/var/www/devportal/web
EMONEY_DEVPORTAL_PROJECT_DIRECTORY=/opt/apigee/data/apigee-drupal-devportal/sites/all
PACKAGE_ID=`basename $(pwd)`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
DRUPAL_BACKUP="sites-all.tar.gz"
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="dpdb.sql"
DB_IP="#{DrupalDbHost}"
DB_PORT=#{DrupalDbPort}
DB_NAME="#{DrupalDbName}"
DB_USER="#{DrupalUser}"
DB_PASSWORD="#{DrupalPassword}"
TWO_DP_SETUP="#{TwoDevPortalSetup}"
SECOND_DP_IP="#{SecondDevPortalIP}"

#Check if backup directory exists
if [ ! -d "${BACKUP_DIRECTORY}" ]; then
    sudo mkdir -p ${BACKUP_DIRECTORY}
fi

#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
sudo cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo drush sql-dump > ${BACKUP_DIRECTORY}/${DB_BACKUP}


#Backup Drupal data - not necessary??
echo "Create drupal directories backup in ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP}"
sudo tar czfP  ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP} -C ${EMONEY_DEVPORTAL_PROJECT_DIRECTORY} ${DRUPAL_DIR_LIST}

#Copy rollback script - not done yet
echo "Create rollback script ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}"
sudo cp ${ROLLBACK_SCRIPT} ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}
sudo cp drush.zip ${BACKUP_DIRECTORY}/drush.zip

#Update codebase to actual version (this I need help with to figure out
echo "Updating codebase"
for item in ${DRUPAL_DIR_LIST}; do
    echo "Deploying ${item}"
    sudo rsync -av --delete ${item}/ ${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}
    sudo chown -R apigee.apigee ${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}
    if [ "${TWO_DP_SETUP}" == "true" ]; then
        echo "Deploying ${item} to second DP on ${SECOND_DP_IP}"
        sudo rsync -av --delete ${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}/ root@${SECOND_DP_IP}:${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}
    fi
done

#Initialize updates:
echo "Initializing updates"
sudo cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo drush updb -y


#Actualize configuration layer:
echo "Actualize configuration layer"
sudo cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo drush cim -y

#Clear caches:
sudo cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo drush cr
