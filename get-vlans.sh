#!/bin/bash
#
# get-vlans.sh - Get VLAN IDs from host
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

set -euo pipefail

DIR=$(dirname "$0")

source "$DIR"/snmp-env.sh

get_vlans()
{
  local host=$1

  local vtpVlanState=".1.3.6.1.4.1.9.9.46.1.3.1.1.2"

  ${SNMPWALK} -One $host $vtpVlanState \
    | sed -e "s/$vtpVlanState\.1\.//"  \
    | awk '{print $1}'
}


if [ $# -ne 1 ]; then
  echo "$0 <host>" >&2
  exit 1
fi

HOST=$1

get_vlans $HOST

