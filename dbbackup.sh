#!/bin/bash

#Declare variables
CWD=`pwd`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
REMOTE_BACKUP_DIRECTORY="#{RemoteDBBackup}"
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


#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
sudo mysqldump --user ${DB_USER} --password ${DB_PASSWORD} ${DB_NAME} | gzip > ${BACKUP_DIRECTORY}/${DB_BACKUP}

# #Delete old database backups
echo "Cleaning up old backups"
DB_BACKUP_PATTERN=`sudo echo $DB_BACKUP | sed -E 's/[[:digit:]]{8}-[[:digit:]]{6}/*/g'`
sudo ls -t ${BACKUP_DIRECTORY}/${DB_BACKUP_PATTERN} | tail -n +4 | xargs rm --

echo "Checking for remote backup directory"
if [ ! -d "${REMOTE_BACKUP_DIRECTORY}" ]; then
    echo "Sending backup to remote backup directory"
    cp ${BACKUP_DIRECTORY}/${DB_BACKUP} ${REMOTE_BACKUP_DIRECTORY}/${DB_BACKUP}
fi

echo "dbbackup script ran"