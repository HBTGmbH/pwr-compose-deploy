# Redis backup

Redis (`view_profile_service_db`) holds the view profiles and the metadata of the report templates
(HBTGmbH/hbt-power#251). The MariaDB backup (`db-backup`) doesn't cover it, so `redis-backup` dumps it once a day
(`conf/redis-backup.sh`, 02:30 UTC, half an hour after the MariaDB backup) to `pwr-backup/redis/` and keeps the newest
30 dumps, like the MariaDB backup. The statistics in the same Redis need no backup: the statistics service reloads them
from the profile service within an hour.

Each dump is a gzipped RDB file `view-profile-<yyyymmdd-hhmm>.rdb.gz`; the log of the container says when one was
written or failed (`docker compose logs redis-backup`).

## Restore

The view profiles and templates go back to the state of the dump; changes since then are lost.

1. Stop the services that write to Redis, then Redis:
   ```shell
   docker compose stop pwr-view-profile-service pwr-statistics-service
   docker compose stop view_profile_service_db
   ```
2. Put the dump in place of the current one (Redis loads `dump.rdb` at start; AOF is off):
   ```shell
   cp rdb-data/dump.rdb rdb-data/dump.rdb.before-restore
   gunzip -c pwr-backup/redis/view-profile-<yyyymmdd-hhmm>.rdb.gz > rdb-data/dump.rdb
   ```
3. Start Redis, check the number of keys, then start the services:
   ```shell
   docker compose start view_profile_service_db
   docker compose exec view_profile_service_db redis-cli --askpass info keyspace
   docker compose start pwr-view-profile-service pwr-statistics-service
   ```

Probed on 2026-10-24 with the local development Redis: a dump of 15 keys was loaded into a fresh Redis and showed the
same 15 keys.
