#! /bin/bash

set -e

LISTENER_MODE=${LISTENER_MODE:="false"}
DESTINATION=${DESTINATION:=""}
if [ $LISTENER_MODE = "false" ]; then

MIN_MTU=$2
MAX_MTU=$3

echo "Getting MTU setup for destination: $1"
  for ((MTU=$MIN_MTU; MTU<=$MAX_MTU; MTU++))
  do
  ping -s $MTU -c1 $DESTINATION | grep -E "PING"
  ping -s $MTU -c1 $DESTINATION | grep -E "rtt" | tee -a rtt
  ping -s $MTU -c1 $DESTINATION | awk '/icmp_seq/ { print $7 }' | tee -a avg_time
  done

echo "Configured MTU: "
ifconfig | grep MTU
sleep 3
echo "------------------------------------------------------------"
echo "Establishing connection with $1 1 second int. 30 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -i1 -t30 -m
echo "------------------------------------------------------------"
echo "Establishing connection with $1 BIDERECTIONAL 30 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -d -i1 -t10 -m
echo "------------------------------------------------------------"
echo "Establishing connection with $1 PARALLEL (2) 10 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -P2 -i1 -t10 -m
echo "------------------------------------------------------------"
echo "Establishing connection with $1 PARALLEL (4) 10 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -P4 -i1 -t10 -m
echo "------------------------------------------------------------"
echo "Establishing connection with $1 PARALLEL (8) 10 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -P4 -i1 -t10 -m
echo "------------------------------------------------------------"
echo "Establishing connection with $1 Force Window Size 10 samples MSS"
echo "------------------------------------------------------------"
iperf -c $DESTINATION -i1 -t10 -m -w 8000

else

echo "Container set in Listener mode"
iperf -s

fi
