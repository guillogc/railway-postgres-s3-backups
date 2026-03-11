# Postgres S3 backups

A simple Bun application to backup your PostgreSQL database to S3. Run on a schedule via your platform's cron or scheduler.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/I4zGrH)

## Configuration

- `S3_ACCESS_KEY_ID` - AWS access key ID.

- `S3_SECRET_ACCESS_KEY` - AWS secret access key, sometimes also called an application key.

- `S3_BUCKET` - The name of the bucket that the access key ID and secret access key are authorized to access.

- `S3_REGION` - The name of the region your bucket is located in, set to `auto` if unknown.

- `DATABASE_URL` - The connection string of the database to backup. Defaults to `${{Postgres.DATABASE_URL}}` for Railway.

- `S3_ENDPOINT` - The S3 custom endpoint you want to use. Applicable for 3-rd party S3 services such as Cloudflare R2 or Backblaze R2.

- `S3_FORCE_PATH_STYLE` - Use path style for the endpoint instead of the default subdomain style, useful for MinIO. Default `false`

- `BACKUP_FILE_PREFIX` - Add a prefix to the file name.

- `BUCKET_SUBFOLDER` - Define a subfolder to place the backup files in.

- `SUPPORT_OBJECT_LOCK` - Enables support for buckets with object lock by providing an MD5 hash with the backup file.

- `BACKUP_OPTIONS` - Add any valid pg_dump option, supported pg_dump options can be found [here](https://www.postgresql.org/docs/current/app-pgdump.html). Example: `--exclude-table=pattern`

- `MAX_BACKUPS` - Maximum number of backups to keep in S3. Oldest backups are deleted when exceeded. 0 = unlimited. Default `0`.

- `BUN_VERSION` - Specify a custom Bun version to override the default version set in the Dockerfile.

- `PG_VERSION` - Specify a custom PostgreSQL version to override the default version set in the Dockerfile.

## Notes for Postgres 17

If backing up a Postgres 17 database imported from Postgres 16, set `PG_VERSION=17`.
