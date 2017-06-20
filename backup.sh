#!/bin/bash

# Generate a (gzipped) dumpfile for each database specified in ${DBS}.
# Upload to gCloud

PREFIX=${PREFIX:-backup}

. /etc/container_environment.sh

# Bailout if any command fails
set -e

# Create a temporary directory to hold the backup files.
DIR="/backup"

# Generate a timestamp to name the backup files with.
TS=$(date +%s)

# Backup all databases, unless a list of databases has been specified
if [ -z "$DBS" ]
then
	# Backup all DB's in bulk
	mysqldump -uroot -p$MYSQL_ROOT_PWD -hmysql --all-databases | gzip > $DIR/$PREFIX-all-databases-$TS.sql.gz
else
	# Backup each DB separately
	for DB in $DBS
	do
		mysqldump -uroot -p$MYSQL_ROOT_PWD -hmysql -B $DB | gzip > $DIR/$PREFIX-$DB-$TS.sql.gz
	done
fi

if [ -n "$MAX_BACKUPS" ]
then
  while [ "$(find /backup -maxdepth 1 -name "*.sql.gz" | wc -l)" -gt "$MAX_BACKUPS" ];
  do
    TARGET=$(find /backup -maxdepth 1 -name "*.sql.gz" | sort | head -n 1)
    echo "Backup $TARGET is deleted"
    rm -rf "$TARGET"
  done
fi