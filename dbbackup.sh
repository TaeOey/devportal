#!/bin/bash

#Declare variables
CWD=`pwd`
CURRENT_DATETIME=`date +%Y%m%d-%H%M%S`
BACKUP_DIRECTORY=/var/www/backups
REMOTE_BACKUP_DIRECTORY="#{RemoteDBBackup}"
ROLLBACK_SCRIPT="Rollback.sh"
DB_BACKUP="devportal-backup-${CURRENT_DATETIME}.sql"
DB_IP="#{DrupalDbHost}"
DB_PORT="#{DrupalDbPort}"
DB_NAME="#{DrupalDbName}"
DB_USER="#{DrupalUser}"
DB_PASSWORD='#{DrupalPassword}'
DB_DRIVER="#{DrupalDriver}"

#Check if backup directory exists
if [ ! -d "${BACKUP_DIRECTORY}" ]; then
    sudo mkdir -p ${BACKUP_DIRECTORY}
fi

#Mount remote backup directory if present
if [[ $REMOTE_BACKUP_DIRECTORY != \#\{*\} ]]; 
then
    echo "Mounting remote share"
    sudo mount $REMOTE_BACKUP_DIRECTORY $BACKUP_DIRECTORY
fi

#Backup Drupal database
echo "Create database backup in ${BACKUP_DIRECTORY}/${DB_BACKUP}"
echo "${DB_IP}:${DB_PORT}:${DB_NAME}:${DB_USER}"
sudo sh -c "mysqldump --user ${DB_USER} --password='${DB_PASSWORD}' ${DB_NAME} | gzip > ${BACKUP_DIRECTORY}/${DB_BACKUP}.gz"

#Unmount remote backup directory if present
if [[ $REMOTE_BACKUP_DIRECTORY != \#\{*\} ]]; 
then
    echo "Unmounting remote share"
    sudo umount -l $BACKUP_DIRECTORY
fi

#Create a database rollback script
sudo cat << EOF >> ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh
echo "Restoring database backup ${DB_BACKUP}"
gunzip ${BACKUP_DIRECTORY}/${DB_BACKUP}.gz
mysql -u ${DB_USER} --password='${DB_PASSWORD}' ${DB_NAME} < ${BACKUP_DIRECTORY}/${DB_BACKUP}
EOF

#Update rollback script if remote is present
if [[ $REMOTE_BACKUP_DIRECTORY != \#\{*\} ]]; 
then
    echo "mount $REMOTE_BACKUP_DIRECTORY $BACKUP_DIRECTORY" | cat - ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh > temp && mv temp ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh
    echo "umount -l $BACKUP_DIRECTORY" >> ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh
fi


chmod +x ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh
echo "Rollback script created at ${BACKUP_DIRECTORY}/Rollback-${DB_BACKUP}.sh"

#Create a backup cleanup job
sudo bash -c "cat << EOF > /etc/cron.daily/dbbackupcleanup
find ${BACKUP_DIRECTORY} -type f -mtime +30 -exec rm -f {} \;
EOF
"

if [[ $REMOTE_BACKUP_DIRECTORY != \#\{*\} ]]; 
then
    sudo bash -c "cat << EOF >> /etc/cron.daily/dbbackupcleanup
    mount ${REMOTE_BACKUP_DIRECTORY} ${BACKUP_DIRECTORY}
    find ${BACKUP_DIRECTORY} -type f -mtime +30 -exec rm -f {} \;
    umount -l $BACKUP_DIRECTORY
EOF
"
fi

#30 days

sudo chmod +x  /etc/cron.daily/dbbackupcleanup

# echo "Checking for remote backup directory"
# if [ ! -d "${REMOTE_BACKUP_DIRECTORY}" ]; then
#     echo "Sending backup to remote backup directory"
#     cp ${BACKUP_DIRECTORY}/${DB_BACKUP} ${REMOTE_BACKUP_DIRECTORY}/${DB_BACKUP}
# fi



echo "dbbackup script ran"