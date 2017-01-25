#!/bin/sh

# boilerplate from check_sensors
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
export PATH
PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.2"

. $PROGPATH/utils.sh

# Commands
CMD_BASENAME=$(which basename)
CMD_SNMPWALK=$(which snmpwalk)
CMD_GREP=$(which grep)
CMD_WC=$(which wc)

#Default variables
OID=.1.3.6.1.2.1.25.4.2.1.2
HOST="127.0.0.1"
COMM="public"
PROCN="snmpd"
STATE=$STATE_UNKNOWN
WARNING=0
CRITICAL=0
PERFDATA=""
MIN=0
MAX=100

print_usage() {
  echo "Usage: ./check_snmp_proc -H 127.0.0.1 -C public -N ssh -w 3 -c 0"
  echo "  $PROGNAME -H ADDRESS"
  echo "  $PROGNAME -C STRING"
  echo "  $PROGNAME -N STRING"
  echo "  $PROGNAME -w INTEGER"
  echo "  $PROGNAME -c INTEGER"
  echo "  $PROGNAME -h"
  echo "  $PROGNAME -V"
}

print_help() {
  print_revision $PROGNAME $REVISION
  echo ""
  print_usage
  echo ""
  echo "Check the process by name via snmp"
  echo ""
  echo "-H ADDRESS"
  echo "   Name or IP address of host (default 127.0.0.1)"
  echo "-C STRING"
  echo "   Community name for the host SNMP agent (default public)"
  echo "-N PROCESS NAME"
  echo "   Exact process name (default snmpd)"
  echo "-w INTEGER"
  echo "   Warning level of running processes (default: 0)"
  echo "-c INTEGER"
  echo "   Critical level of running processes (default: 0)"
  echo "-m INTEGER"
  echo "   Minimum for performance data (default: 0)"
  echo "-M INTEGER"
  echo "   Maximum for performance data (default: 100)"
  echo "-h"
  echo "   Print this help screen"
  echo "-V"
  echo "   Print version and license information"
  echo ""
  echo "This plugin uses the 'snmpwalk' command included with the NET-SNMP package."
  echo "This plugin uses the utils.sh from monitoring-plugins.org."
}

while getopts H:C:N:w:c:m:M:Vh OPT
do
  case $OPT in
    H) HOST="$OPTARG" ;;
    C) COMM="$OPTARG" ;;
    N) PROCN="$OPTARG" ;;
    w) WARNING=$OPTARG ;;
    c) CRITICAL=$OPTARG ;;
    m) MIN=$OPTARG ;;
    M) MAX=$OPTARG ;;
    h)
      print_help
      exit $STATE_OK
      ;;
    V)
      print_revision $PROGNAME $REVISION
      exit $STATE_OK
      ;;
   esac
done

#Plugin 
#PROCN=${PROCN:0:15}
PROCN=`echo $PROCN | cut -c -15`

#echo $PROCN

CNT=`$CMD_SNMPWALK -v1 -On -c $COMM $HOST $OID | $CMD_GREP "\"$PROCN\"" | $CMD_WC -l`

check_range $CNT $CRITICAL
RET_CRIT=$?
if [ "$RET_CRIT" -eq 2 ]; then
  STATE=$STATE_CRITICAL
  exit $STATE
fi

check_range $CNT $WARNING
RET_WARN=$?
if [ "$RET_WARN" -eq 2 ]; then
  STATE=$STATE_CRITICAL
  exit $STATE
fi

#echo "Range return is critical $RET_CRIT and warning $RET_WARN"

PERFDATA="$PROCN=$CNT;$WARNING;$CRITICAL;$MIN;$MAX"

if [ "$RET_CRIT" -eq 0 ]; then
  STATE=$STATE_CRITICAL
  DESCRIPTION="PROCESS CRITICAL: Number of $PROCN not in range $CRITICAL"
elif [ "$RET_WARN" -eq 0 ]; then
  STATE=$STATE_WARNING
  DESCRIPTION="PROCESS WARNING: Number of $PROCN not in range $WARNING"
else
  STATE=$STATE_OK
  DESCRIPTION="PROCESS OK: Running $CNT instances of $PROCN"
fi

echo "$DESCRIPTION | $PERFDATA"
exit $STATE
