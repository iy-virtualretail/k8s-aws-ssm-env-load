#!/bin/bash

/bin/load-ssm-parameters.py
echo "settting env from env.sh"
.  /tmp/env.sh

rm -f /tmp/env.sh

exec "$@"
