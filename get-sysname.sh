#!/bin/bash
#
# get-sysname.sh - Get system name from host
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

set -euo pipefail

DIR=$(dirname "$0")

source "$DIR"/snmp-env.sh

get_sysname()
{
  local host=$1

  ${SNMPWALK} -Ov $host sysName.0 | awk '{print $2}'
}


if [ $# -ne 1 ]; then
  echo "$0 <host>" >&2
  exit 1
fi

HOST=$1

get_sysname $HOST

