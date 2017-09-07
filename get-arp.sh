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


function delimiter
{
  echo -n '|'
}

function get_arp_entries
{
  local host=$1

  ${SNMPTABLE} -Ov -Cf $(delimiter) $host ipNetToMediaTable
}

function filter_non_entries
{
  cat | egrep 'static|dynamic'
}

function format_arp_entry
{
  # _|C0:FF:33:C0:FF:33|192.0.2.1|_
  #   -> 192.0.2.1 c0:ff:33:c0:ff:33
  #
  # or
  #
  # _|"C0 FF 33 C0 FF 33 "|192.0.2.1|_
  #   -> 192.0.2.1 c0:ff:33:c0:ff:33
  #
  local entry=$1

  local ip=$(
    echo "$entry" |
      awk -F $(delimiter) '{print $4}'
  )

  local mac=$(
    echo "$entry"                      |
      awk -F $(delimiter) '{print $3}' |
      sed -e 's/^" *//' -e 's/ *"$//'  |
      sed -e 's/ /:/g'                 |
      tr '[:upper:]' '[:lower:]'
  )

  echo "$ip $mac"
}

function format_arp_entries
{
  while read row
  do
    format_arp_entry "$row"
  done < <(cat)
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

  get_arp_entries $host |
    filter_non_entries  |
    format_arp_entries
}


main $@

