#!/bin/bash

#Declare variables
CWD=`pwd`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="devportal-backup-${CURRENT_DATETIME}.sql.gz"
DB_IP="#{DrupalDbHost}"
DB_PORT="#{DrupalDbPort}"
DB_NAME="#{DrupalDbName}"
DB_USER="#{DrupalUser}"
DB_PASSWORD="#{DrupalPassword}"
DB_DRIVER="#{DrupalDriver}"

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

echo "dbbackup script ran"
#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
sudo ${CWD}/drush --root=${APIGEE_DRUPAL_WEB_DOCROOT} sql-dump --gzip > ${BACKUP_DIRECTORY}/${DB_BACKUP}

# #Delete old database backups
DB_BACKUP_PATTERN=`sudo echo $DB_BACKUP | sed -E 's/[[:digit:]]{8}-[[:digit:]]{6}/*/g'`
sudo ls -t ${BACKUP_DIRECTORY}/${DB_BACKUP_PATTERN} | tail -n +4 | xargs rm --