snmp-helpers
=====

SNMP helper BASH scripts with easy-to-parse output

## Usage

Clone the repository.

    git clone https://github.com/jonnystorm/snmp-helpers.git
Create a file containing your credentials. For SNMPv1/v2c, you can do

    cat > ~/snmp-credentials <<EOF
    1 mycommunity
    EOF

or

    cat > ~/snmp-credentials <<EOF
    2c mycommunity
    EOF

For SNMPv3, use

    cat > ~/snmp-credentials <<EOF
    3 auth snmpuser sha authpass
    EOF

or

    cat > ~/snmp-credentials <<EOF
    3 authPriv snmpuser sha authpass aes privpass
    EOF

Export `SNMP_CREDENTIALS` with the path of your credentials file, or set it at each command:

    export SNMP_CREDENTIALS=~/snmp-credentialsv3
    
    ./snmp-helpers/get-sysname.sh 192.0.2.1
    
    SNMP_CREDENTIALS=~/snmp-credentialsv2c ./snmp-helpers/get-sysname.sh 192.0.2.2

All output is arranged simply for easy parsing.

    [jstorm@trivius snmp-helpers]$ SNMP_CREDENTIALS=~/snmp-credentials ./get-sysname.sh 192.0.2.3
    R1

    [jstorm@trivius snmp-helpers]$ SNMP_CREDENTIALS=~/snmp-credentials ./get-addr.sh 192.0.2.3
    192.0.2.3/31
    198.51.100.1/32

    [jstorm@trivius snmp-helpers]$ SNMP_CREDENTIALS=~/snmp-credentials ./get-arp.sh 192.0.2.3
    192.0.2.2 ea:90:1e:7:d0:b0
    192.0.2.3 c2:1:10:3d:0:0

    [jstorm@trivius snmp-helpers]$ SNMP_CREDENTIALS=~/snmp-credentials ./get-ifs.sh 192.0.2.3
    1 Fa1/0
    2 Fa0/0
    3 Fa0/1
    5 Nu0
    6 Lo0

    [jstorm@trivius snmp-helpers]$ SNMP_CREDENTIALS=~/snmp-credentials ./get-vlans.sh 192.0.2.3
    1
    1002
    1003
    1004
    1005

