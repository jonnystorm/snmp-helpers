#!/bin/bash
#
# get-fdb.sh - Get forwarding database from host
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

  $DIR/get-vlans.sh $host | egrep -v '^100[2-5]$'
}

get_vlan_fdb()
{
  local host=$1
  local vlan_id=$2

  ${SNMPTABLE} -n vlan-$vlan_id -Ov $host dot1dTpFdbTable
}

filter_static_entries()
{
  cat | egrep 'learned|mgmt'
}

lowercase()
{
  cat | tr '[:upper:]' '[:lower:]'
}

format_fdb_entry()
{
  local vlan_id=$1

  # port mac vid
  cat | awk "{print \$2,\$1 \" $vlan_id\"}"
}

sort_numeric()
{
  cat | sort -n
}


if [ $# -ne 1 ]; then
  echo "$0 <IP_address>" >&2
  exit 1
fi

ip=$1

for vlan in `get_vlans $ip`; do
  get_vlan_fdb $ip $vlan \
    | filter_static_entries  \
    | format_fdb_entry $vlan \
    | lowercase
done | sort_numeric

