#!/bin/bash

TARGET_IP=192.168.0.3

if [ $# -lt 1 ]; then
	echo "Usage: $0 FILE"
	exit 1
fi

FILE=$1

if ! [ -f $FILE ]; then
	echo "# time packet_loss_ratio rtt_avg rtt_mdev" > $FILE
fi

TEMP=`mktemp`
ERRTEMP=`mktemp`

T=`date +'%Y-%m-%dT%H:%M:%S'`

ping -q -c 1 $TARGET_IP 1> $TEMP  2> $ERRTEMP
if grep unreachable $ERRTEMP; then
	echo $T 100 -1 -1 >> $FILE
else
	sed 's!.*[^0-9]\([0-9][0-9]*% packet loss\)!\1!' $TEMP | \
	  awk '/packet loss/ { gsub(/%/, "", $1); print $1; if ($1 == "100") print "-1\n-1" } $1 ~ /rtt/ { N = split($4, VAL, /\//); print VAL[2] "\n" VAL[4] }' | xargs echo $T >> $FILE
fi

rm $TEMP $ERRTEMP
