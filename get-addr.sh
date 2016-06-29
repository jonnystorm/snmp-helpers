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

get_ip_mask_tuples()
{
  local host=$1

  # 192.0.2.1 255.255.255.0
  ${SNMPTABLE} -Ov $host ipAddrTable \
    | grep '\.'                      \
    | awk '{print $1,$3}'
}

mask_octet_to_bits()
{
  local oct=$1

  case $oct in
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

mask_to_length()
{
  local mask=$1

  local octets=$(echo $mask | sed -e 's/\./ /g')
  local length=0

  for o in $octets; do
    local bits=$(mask_octet_to_bits $o)

    length=$((length + bits))
  done

  echo $length
}

ip_mask_to_cidr()
{
  local ip=$1
  local mask=$2

  echo $ip/$(mask_to_length $mask)
}


if [ $# -ne 1 ]; then
  echo "$0 <host>" >&2
  exit 1
fi

HOST=$1

while read ip_mask_tuple; do
  ip_mask_to_cidr $ip_mask_tuple
done < <(get_ip_mask_tuples $HOST)

