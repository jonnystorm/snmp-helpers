#!/bin/bash
#
# get-arp.sh - Get ARP cache from host
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

set -euo pipefail

DIR=$(dirname "$0")

source "$DIR"/snmp-env.sh

get_arp_entries()
{
  local host=$1

  ${SNMPTABLE} -Ov $host ipNetToMediaTable
}

filter_non_entries()
{
  cat | egrep 'static|dynamic'
}

format_arp_entries()
{
  # _ C0:FF:33:C0:FF:33 192.0.2.1 _
  #   -> 192.0.2.1 c0:ff:33:c0:ff:33
  cat | awk '{print $3,$2}' | tr '[:upper:]' '[:lower:]'
}


if [ $# -ne 1 ]; then
  echo "$0 <IP_address>" >&2
  exit 1
fi

ip=$1

get_arp_entries $ip \
  | filter_non_entries \
  | format_arp_entries

