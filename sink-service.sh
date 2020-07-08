#!/bin/sh -e

# Set the port, baud rate and active/inactive associated with the sinkID to a file or something that can be accessed
# This will be executed by the sink service daemon later as something like `sinkService -p <uart_port> -b <bitrate> -i <sink_id>`

# Read list of sinks in use (0-9 are possible), see if any were previously used for this same device, if so connect to that, if not select one not in use, prefer one never used.
launchSinkID = $1
INPUT=$SNAP_DATA/sinkList.csv

OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read sinkID sinkBaud sinkPath sinkRstPin sinkRstPol sinkPlugged sinkActive
do
  #find settings for our device
  if [ "$sinkID" == "$launchSinkID"]; then
    echo "Sink service ${launchSinkID} starting."

    #make sure tag now says active


    #launch sinkService
    sinkService  -p $sinkPath -b $sinkBaud -i $launchSinkID

    #If we get here the sinkService errored out.
    echo "Sink service ${launchSinkID} exited."
    
    #change tag to inactive

    return 40 #exited after starting
  fi
done < $INPUT
IFS=$OLDIFS

echo "No settings found for sink service  ${launchSinkID}, aborting."

#If we get here 3+ times without a success we should probably disable the daemon service.
#snapctl stop sinkService${newSinkID} --disable
return 41