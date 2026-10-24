#!/bin/sh
# Dumps the Redis of the view-profile service once a day and keeps the newest MAX_BACKUPS dumps, like the MariaDB
# backup (HBTGmbH/hbt-power#251). Redis holds the view profiles and the report templates, which no other backup has;
# the statistics in it are reloaded from the profile service anyway. Restoring: REDIS-BACKUP.md.
#
# REDIS_HOST: the Redis container; REDISCLI_AUTH: its password (read by redis-cli, so it is no command line argument);
# BACKUP_TIME: HH:MM in the container's time zone; MAX_BACKUPS: how many dumps to keep.
set -u
BACKUP_TIME=${BACKUP_TIME:-02:30}
MAX_BACKUPS=${MAX_BACKUPS:-30}
mkdir -p /backup

backup() {
    file=/backup/view-profile-$(date +%Y%m%d-%H%M).rdb
    if redis-cli -h "$REDIS_HOST" --rdb "$file" > /dev/null && gzip -9 "$file"; then
        echo "$(date) Redis backup written: $file.gz"
    else
        echo "$(date) Redis backup FAILED" >&2
        rm -f "$file"
    fi
    # The newest MAX_BACKUPS stay
    ls -1t /backup/view-profile-*.rdb.gz 2> /dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -f
}

echo "$(date) Redis backup of $REDIS_HOST every day at $BACKUP_TIME, keeping $MAX_BACKUPS"
while true; do
    if [ "$(date +%H:%M)" = "$BACKUP_TIME" ]; then
        backup
        # Past the minute, so it runs once
        sleep 60
    fi
    sleep 20
done
