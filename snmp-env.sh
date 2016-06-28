#
# snmp-env.sh - Set up base environment for SNMP helper scripts
#
# Copyright © 2016 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.


get_snmp_common_args()
{
  echo "-mALL -Le"
}

get_snmpv1_args()
{
  local community=$1

  echo \
    "$(get_snmp_common_args) \
     -v 1                    \
     -c $community"
}

get_snmpv2c_args()
{
  local community=$1

  echo \
    "$(get_snmp_common_args) \
     -v 2c                   \
     -c $community"
}

get_snmpv3_auth_args()
{
  local   sec_name=$1
  local auth_proto=$2
  local  auth_pass=$3

  echo \
    "-u ${sec_name}   \
     -a ${auth_proto} \
     -A ${auth_pass}"
}

get_snmpv3_authpriv_args()
{
  local   sec_name=$1
  local auth_proto=$2
  local  auth_pass=$3
  local priv_proto=$4
  local  priv_pass=$5

  echo \
    "-u ${sec_name}   \
     -a ${auth_proto} \
     -A ${auth_pass}  \
     -x ${priv_proto} \
     -X ${priv_pass}"
}

get_snmpv3_args()
{
  local sec_level=$1
  shift
  
  case $sec_level in
    auth)
      echo \
        "-l $sec_level \
         $(get_snmpv3_auth_args $@)"
      ;;
    auth[pP]riv)
      echo \
        "-l $sec_level \
         $(get_snmpv3_authpriv_args $@)"
      ;;
  esac
}

get_snmp_args()
{
  local version=$1
  shift

  case $version in
    1)
      echo \
        "$(get_snmp_common_args) \
         -v $version             \
         $(get_snmpv1_args $@)"
      ;;
    2c)
      echo \
        "$(get_snmp_common_args) \
         -v $version             \
         $(get_snmpv2c_args $@)"
      ;;
    3)
      echo \
        "$(get_snmp_common_args) \
         -v $version             \
         $(get_snmpv3_args $@)"
      ;;
  esac
}


SNMPARGS=$(get_snmp_args `cat $SNMP_CREDENTIALS`)

SNMPWALK="snmpwalk $SNMPARGS"
SNMPTABLE="snmptable -OX -CH $SNMPARGS"

