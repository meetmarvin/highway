#!/bin/bash

set -e

service postgresql start

sudo -Hiu postgres psql --command "CREATE USER graeme WITH SUPERUSER PASSWORD 'saltwater';"

rake db:setup

exec /bin/bash
