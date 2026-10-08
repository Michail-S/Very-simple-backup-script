#!/bin/bash
# Very simple backup script by Michail

# Settings:
save_backups_to=/tmp/backups/ # All backup archives will be saved here, dir will be created if not already present!
backup=/home/michails/docs # What exactly to backup (folder)
cleanup_on_exit=true # DO NOT ENABLE IN PRODUCTION. DELETES ALL BACKUPS IN BACKUP DESTINATION PATH
set +x # -x=debug on   +x=debug off               On=A lot of spam in the console!
set -e # Stop execution on any error, delete to disable
# End of the Settings





echo "Starting backup..."

# Check if source path exists 
if [ -d "$backup" ]; then
  echo "Source $backup does exist, proceeding..."
else
  echo "Source (what to backup) does not exist! Exiting..."
  exit 1
fi

# Check if source path is readable
if [ -r "$backup" ]; then
    echo "Source path read permission check completed"
else 
   echo "Source path read permission check failed! Exiting..."
   exit 1 
fi



# Get & set backup timestamp
timestamp=$(date +%s)
# Create backup archive
tar -c -f backup_${timestamp}.tar.gz $backup
# Get archive file size for later use in the code
sz=$(stat -c '%s' backup_${timestamp}.tar.gz)


# Check if backup save dir exists
if [ -d "$save_backups_to" ]; then
  echo "$save_backups_to does exist, proceeding..."
fi
# If backup save dir does not exist, create it
if [ ! -d "$save_backups_to" ]; then
  echo "$save_backups_to does not exist, creating..."
  mkdir $save_backups_to
fi
# Check if destination path is writable
if [ -w "$save_backups_to" ]; then
    echo "Destination path write permission check completed"
else
   echo "Destination path write permission check failed! Exiting..."
   exit 1
fi


# Move backup to defined backup save dir
echo "Moving backup to dir..."
mv backup_${timestamp}.tar.gz $save_backups_to

# Success message
echo "Backup completed!"
# Backup size output
echo "Total backup size: ${sz}"
# Backup size format warning
echo "Backup size is in unix timestamp format! Convert using timestamp-converter.com."

echo "Exit code: $?"
echo "If the value above is not 0 then, there was probably an error. Try using debug mode."

# Cleanup for dev purposes
if [ "$cleanup_on_exit" = true ]; then
  echo "Waiting 8 seconds before cleanup, press CTRL+C immdediately if this is in producion!!!"
  sleep 8
  rm -rf $save_backups_to
  echo "Cleanup complete"
fi

