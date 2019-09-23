#!/bin/bash

CWD=`pwd`
APIGEE_DRUPAL_ROOT=/var/www/devportal/"#{Octopus.Release.Package.PackageId}"
DRUPAL_BACKUP="sites-all.tar.gz"
DRUPAL_DIR_LIST="modules themes"
DB_BACKUP="devportal-backup-*.sql"
#TWO_DP_SETUP="#{TwoDevPortalSetup}"
#SECOND_DP_IP="#{SecondDevPortalIP}"

#Unpack modules and themes
echo "Unpacking directories ${DRUPAL_DIR_LIST}"
tar -xzf ${DRUPAL_BACKUP}

#Restore modules and themes
for item in ${DRUPAL_DIR_LIST}; do
    echo "Restoring ${item}"
    sudo chown -R apigee.apigee ${item}
    sudo rsync -av --delete ${item}/ ${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}
    # if [ "${TWO_DP_SETUP}" == "true" ]; then
    #     echo "Restoring ${item} on second DP on ${SECOND_DP_IP}"
    #     sudo rsync -av --delete ${item}/ root@${SECOND_DP_IP}:${EMONEY_DEVPORTAL_PROJECT_DIRECTORY}/${item}
    # fi
done

#Install drush
echo "Installing drush"
unzip -o drush.zip
chmod 755 drush
mv drush drush.phar
ln -s ${CWD}/drush.phar ${CWD}/drush

#Drop database:
echo "Dropping database"
sudo ${CWD}/drush --root=$APIGEE_DRUPAL_ROOT sql-drop -y

#Import database dump:
echo "Importing database from dump ${DB_BACKUP}"
sudo ${CWD}/drush --root=$APIGEE_DRUPAL_ROOT sqlq --file=${CWD}/${DB_BACKUP} -y
