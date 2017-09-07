#!/bin/bash
#
# get-ifs.sh - Get interface indices and aliases from host
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

set -euo pipefail

DIR=$(dirname "$0")

source "$DIR"/snmp-env.sh


function get_if_aliases
{
  local ip=$1

  ${SNMPTABLE} -Cf '|' -Oe $ip ifXTable |
    egrep '[0-9]' |
    awk -F'|' '{print $1,$18}'
}

function get_if_indices
{
  local ip=$1

  ${SNMPTABLE} -Oe $ip ifTable |
    egrep '[0-9]'              |
    awk '{print $1}'
}

function zip
{
  local right=$1

  cat | pr -tmJs' ' - <(echo "$right")
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

  get_if_indices $host |
    zip "$(get_if_aliases $host)"
}


main $@

