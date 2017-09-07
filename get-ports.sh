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


function get_vlans
{
  local host=$1

  $DIR/get-vlans.sh $host |
    egrep -v '^100[2-5]$'
}

function get_port_ifindex_pairs
{
  local host=$1
  local vlan_id=$2

  local context="vlan-$vlan_id"

  ${SNMPTABLE} -n $context -Ov $host dot1dBasePortTable |
    grep -v 'No entries' |
    awk '{print $1,$2}'
}

function sort_numeric
{
  cat | sort -n
}

function print_usage_and_exit
{
  echo "$0 <host>" >&2

  exit 1
}

function main
{
  if [ $# -ne 1 ]; then
    print_usage_and_exit
  fi

  local host=$1

  for vlan in `get_vlans $host`
  do
    get_port_ifindex_pairs $host $vlan

  done | sort_numeric | uniq
}


main $@

