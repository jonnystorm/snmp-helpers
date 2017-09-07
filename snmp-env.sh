#
# snmp-env.sh - Set up base environment for SNMP helper scripts
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.


function get_snmp_common_args
{
  echo -mALL -Le
}

function get_snmpv1_args
{
  local community=$1

  echo -n "$(get_snmp_common_args) "
  echo -n "-v 1 "
  echo    "-c $community"
}

function get_snmpv2c_args
{
  local community=$1

  echo -n "$(get_snmp_common_args) "
  echo -n "-v 2c "
  echo    "-c $community"
}

function get_snmpv3_authnopriv_args
{
  local   sec_name=$1
  local auth_proto=$2
  local  auth_pass=$3

  echo -n "-u ${sec_name} "
  echo -n "-a ${auth_proto} "
  echo    "-A ${auth_pass}"
}

function get_snmpv3_authpriv_args
{
  local   sec_name=$1
  local auth_proto=$2
  local  auth_pass=$3
  local priv_proto=$4
  local  priv_pass=$5

  echo -n "-u ${sec_name} "
  echo -n "-a ${auth_proto} "
  echo -n "-A ${auth_pass} "
  echo -n "-x ${priv_proto} "
  echo    "-X ${priv_pass}"
}

function get_snmpv3_args
{
  local sec_level=$1
  shift
  
  case $sec_level in
    auth[nN]o[pP]riv)
      echo -n "-l $sec_level "
      echo    "$(get_snmpv3_authnopriv_args $@)"
      ;;
    auth[pP]riv)
      echo -n "-l $sec_level "
      echo    "$(get_snmpv3_authpriv_args $@)"
      ;;
  esac
}

function get_snmp_args
{
  local version=$1
  shift

  case $version in
    1)
      echo -n "$(get_snmp_common_args) "
      echo -n "-v $version "
      echo    "$(get_snmpv1_args $@)"
      ;;
    2c)
      echo -n "$(get_snmp_common_args) "
      echo -n "-v $version "
      echo    "$(get_snmpv2c_args $@)"
      ;;
    3)
      echo -n "$(get_snmp_common_args) "
      echo -n "-v $version "
      echo    "$(get_snmpv3_args $@)"
      ;;
  esac
}


SNMPARGS=$(get_snmp_args `cat $SNMP_CREDENTIALS`)

SNMPWALK="snmpwalk $SNMPARGS"
SNMPTABLE="snmptable -OX -CH $SNMPARGS"

