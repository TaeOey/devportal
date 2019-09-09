#!/bin/bash

#Declare variables
CWD=`pwd`
APIGEE_DRUPAL_SOURCE_ROOT=/var/www/devportal/"#{Octopus.Release.Number}"
APIGEE_DRUPAL_WEB_DOCROOT=/var/www/devportal/"#{Octopus.Release.Number}"/web
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

#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
#sudo cd ${APIGEE_DRUPAL_WEB_DOCROOT}
sudo /var/www/devportal/vendor/bin/drush sql-dump > ${BACKUP_DIRECTORY}/${DB_BACKUP}


#Backup Drupal data - not necessary??
# echo "Create drupal directories backup in ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP}"
# sudo tar czfP  ${BACKUP_DIRECTORY}/${DRUPAL_BACKUP} -C ${APIGEE_DRUPAL_SOURCE_ROOT} ${DRUPAL_DIR_LIST}

#Copy rollback script - not done yet
#echo "Create rollback script ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}"
#sudo cp ${ROLLBACK_SCRIPT} ${BACKUP_DIRECTORY}/${ROLLBACK_SCRIPT}
#sudo cp drush.zip ${BACKUP_DIRECTORY}/drush.zip

echo "Creating and Fixing Permission On ${APIGEE_DRUPAL_SOURCE_ROOT}"

sudo mkdir ${APIGEE_DRUPAL_SOURCE_ROOT}

sudo rsync -r * ${APIGEE_DRUPAL_SOURCE_ROOT}

sudo find ${APIGEE_DRUPAL_SOURCE_ROOT} -type d -exec chmod 755 {} \;
#sudo find ${APIGEE_DRUPAL_SOURCE_ROOT} f -exec chmod 644 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/web/sites/default/ -type d -exec chmod 775 {} \;
sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin -type d -exec chmod -R 777 {} \;
#sudo find ${APIGEE_DRUPAL_SOURCE_ROOT}/web/sites/default/files -type d -exec chmod 775 {} \;


#Update codebase to actual version (this I need help with to figure out
# echo "Updating codebase"
# for item in ${DRUPAL_DIR_LIST}; do
#     echo "Deploying ${item}"
#     sudo rsync -av --delete ${item}/ ${APIGEE_DRUPAL_WEB_DOCROOT}/${item}
    
# done

#Initialize updates:
echo "Initializing updates"
#sudo chmod -R 777 ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin
sudo /var/www/devportal/vendor/bin/drush version
#sudo && ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin/drush -v
#sudo && ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin/drush sql-dump > ${BACKUP_DIRECTORY}/${DB_BACKUP}
#sudo && ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin/drush updb -y


#Actualize configuration layer:
echo "Actualize configuration layer"
#sudo ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin/drush cim -y

#Clear caches:
#sudo ${APIGEE_DRUPAL_SOURCE_ROOT}/vendor/bin/drush cr

#Move Symlink

#Delete old versions