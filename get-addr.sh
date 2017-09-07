#!/bin/bash
#
# get-addr.sh - Get list of IP addresses from host
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

set -euo pipefail

DIR=$(dirname "$0")

source "$DIR"/snmp-env.sh


function get_ip_mask_tuples
{
  # Output 192.0.2.1 255.255.255.0
  #
  local host=$1

  ${SNMPTABLE} -Ov $host ipAddrTable |
    grep '\.'                        |
    awk '{print $1,$3}'
}

function mask_octet_to_bits
{
  local octet=$1

  case $octet in
    0)   echo 0;;
    128) echo 1;;
    192) echo 2;;
    224) echo 3;;
    240) echo 4;;
    248) echo 5;;
    252) echo 6;;
    254) echo 7;;
    255) echo 8;;
  esac
}

function mask_to_length
{
  local mask=$1

  local octets=$(echo $mask | sed -e 's/\./ /g')
  local length=0

  for o in $octets
  do
    local bits=$(mask_octet_to_bits $o)

    length=$((length + bits))
  done

  echo $length
}

function ip_mask_to_cidr
{
  local ip=$1
  local mask=$2

  echo $ip/$(mask_to_length $mask)
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

  while read ip_mask_tuple
  do
    ip_mask_to_cidr $ip_mask_tuple

  done < <(get_ip_mask_tuples $host)
}


main $@

