#!/bin/bash

#Credits to https://github.com/oliranks/openHAB3-full_backup_and_restore

TIMESTAMP="`date +%Y%m%d_%H%M%S`";
BACKUPDIR="/data/backups/";
BACKUPNAME="openhab-full-backup";
INFLUXDB2CONFIGDIR="/var/lib/docker/volumes/influxdb_config_v2/_data"
INFLUXDB2BACKUPDIR="/var/lib/docker/volumes/influxdb_backups_v2/_data/db"

echo -e "\e[96m#############################\e[0m"
echo -e "\e[96m##### \e[31mStopping services \e[96m#####\e[0m"
echo -e "\e[96m#############################\e[0m"
echo -e "Stopping openhab service..."
sudo systemctl stop openhab.service
echo -e "openhab service \e[31mstopped\e[0m."
echo -e ""

echo -e "\e[96m######################################\e[0m"
echo -e "\e[96m##### \e[31mFolder setup \e[96m#####\e[0m"
echo -e "\e[96m######################################\e[0m"
echo -e "Creating openhab backup directory:";
sudo mkdir -v "$BACKUPDIR$BACKUPNAME/openhab";
echo -e "Creating influxdb backup directory:";
sudo mkdir -v "$BACKUPDIR$BACKUPNAME/influxdb";
echo -e ""

echo -e "\e[96m###########################\e[0m"
echo -e "\e[96m##### \e[31mopenHAB4 Backup \e[96m#####\e[0m"
echo -e "\e[96m###########################\e[0m"
echo -e "Creating openHAB4 backup..."
sudo openhab-cli backup "$BACKUPDIR$BACKUPNAME/openhab/openhab-backup.zip"

echo -e "\e[96m###########################\e[0m"
echo -e "\e[96m##### \e[31mInfluxdb Backup \e[96m#####\e[0m"
echo -e "\e[96m###########################\e[0m"
echo -e "Copying influxdb config file..."
sudo cp -arv "$INFLUXDB2CONFIGDIR" "$BACKUPDIR$BACKUPNAME/influxdb/"
echo -e "Exporting influxdb databases..."
sudo rm -Rf $INFLUXDB2BACKUPDIR
sudo docker exec influxdb2 influx backup "/backups/db/"
sudo mv $INFLUXDB2BACKUPDIR/ $BACKUPDIR$BACKUPNAME/influxdb/
echo -e ""

echo -e "\e[96m###############################\e[0m"
echo -e "\e[96m##### \e[31mRestarting services \e[96m#####\e[0m"
echo -e "\e[96m###############################\e[0m"
echo -e "Starting openhab service..."
sudo systemctl start openhab.service
echo -e "openhab service \e[32mstarted\e[0m."
echo -e ""

echo -e "\e[96m##############################\e[0m"
echo -e "\e[96m##### \e[31mCompressing backup \e[96m#####\e[0m"
echo -e "\e[96m##############################\e[0m"
cd $BACKUPDIR
sudo tar cfvz $BACKUPDIR$BACKUPNAME.tar.gz $BACKUPNAME/
echo -e ""

echo -e "Backup finished!"
echo -e ""

echo -e "Total backup folder size:"
sudo du -sh -- $BACKUPDIR$BACKUPNAME/*
echo -e ""

echo -e "Compressed backup file size:"
sudo du -sh -- $BACKUPDIR$BACKUPNAME.tar.gz
echo -e ""

echo -e "\e[96m#######################\e[0m";
echo -e "\e[96m##### \e[31mCleaning up \e[96m#####\e[0m";
echo -e "\e[96m#######################\e[0m";
sudo rm -rf $BACKUPDIR$BACKUPNAME/openhab
sudo rm -rf $BACKUPDIR$BACKUPNAME/influxdb
echo -e "Temporary directory deleted.";
echo -e "";

echo -e "Backup created \e[32msucessfully\e[0m! -> $BACKUPDIR$BACKUPNAME.tar.gz"
echo -e "Move file on NAS using SCP"
sudo scp $BACKUPDIR$BACKUPNAME.tar.gz sshd@192.168.1.6:/shares/Backup/Backup_OH4/$BACKUPNAME-$TIMESTAMP.tar.gz
echo -e "SUCCESS"
