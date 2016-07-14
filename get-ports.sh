#!/bin/bash
#
# get-ports.sh - Get 802.1d port to if-index mappings from host
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

  $DIR/get-vlans.sh $ip | egrep -v '^100[2-5]$'
}

get_port_ifindex_pairs()
{
  local host=$1
  local vlan_id=$2

  ${SNMPTABLE} -n vlan-$vlan_id -Ov $host dot1dBasePortTable \
    | grep -v 'No entries'                                   \
    | awk '{print $1,$2}'
}

sort_numeric()
{
  cat | sort -n
}


if [ $# -ne 1 ]; then
  echo "$0 <host>" >&2
  exit 1
fi

HOST=$1

for vlan in `get_vlans $HOST`; do
  get_port_ifindex_pairs $HOST $vlan

done | sort_numeric | uniq

