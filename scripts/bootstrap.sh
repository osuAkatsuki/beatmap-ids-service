#!/usr/bin/env bash
set -euo pipefail

# handle int & kill signals as non-errors until final "exec" runs
trap "{ exit 0; }" TERM INT

if [ -z "$APP_COMPONENT" ]; then
  echo "Please set APP_COMPONENT"
  exit 1
fi

cd /srv/root

# await connected service availability
/scripts/await-service.sh $READ_DB_HOST $READ_DB_PORT
/scripts/await-service.sh $WRITE_DB_HOST $WRITE_DB_PORT

# ensure database exists
/scripts/init-db.sh

# run sql database migrations & seeds
/scripts/migrate-db.sh up
/scripts/seed-db.sh up

case $APP_COMPONENT in
  "api")
    exec /scripts/run-api.sh
    ;;

  *)
    echo "'$APP_COMPONENT' is not a known value for APP_COMPONENT"
    ;;
esac
