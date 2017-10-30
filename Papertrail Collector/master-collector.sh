#!/bin/bash
# Make sure you replace the API and/or APP key below
# with the ones for your account
#set -x
#ENV Variables for Master Collector
PAPERTRAIL_API_TOKEN=${PAPERTRAIL_API_TOKEN:='****'}
DATADOG_API_TOKEN=${DATADOG_API_TOKEN:='****'}
#Client specific variabless
PAPERTRAIL_ALEBRIDGE_HOST=${PAPERTRAIL_ALEBRIDGE_HOST:='13.92.*.40'}
PAPERTRAIL_ALEBRIDGE_NAME=${PAPERTRAIL_ALEBRIDGE_NAME:='alebridge'}

PAPERTRAIL_COREBRIDGE_HOST=${PAPERTRAIL_COREBRIDGE_HOST:='13.92.*.40'}
PAPERTRAIL_COREBRIDGE_NAME=${PAPERTRAIL_COREBRIDGE_NAME:='corebridge'}
DATADOG_METRIC_NAME=${DATADOG_METRIC_NAME:='Kohls'}

#Functions
function vizix.cleaning {
#Cleans the container up

if [ -f "$@" ] 
then 
  echo "Cleaning temp files" && rm "$@"
else 
  echo "Already clean!" 
fi

}
function edgebridge.age {

#Retrieving information from Papertrail
#10 seconds timeframe
#13th Column to parse

PAPERTRAIL_AGE_ARGUMENTS=$(papertrail --min-time '10 seconds ago' "$PAPERTRAIL_ALEBRIDGE_HOST $PAPERTRAIL_ALEBRIDGE_NAME age=" | awk '{ print $13 }' | grep -oP '(?<=\=\[)(.*?)(?=\,)' > temp.age)
#Posting to Datadog
echo "-----------------------------"
echo "Edge Bridge Log Parser Age"
echo "Logs retrieve from: $PAPERTRAIL_ALEBRIDGE_HOST"
echo "Papertrail program used: $PAPERTRAIL_ALEBRIDGE_NAME"
echo "Timeframe: 10 seconds ago"
echo "Posting to Datadog at: infrastructure@mojix.com account"
echo "Data to post: "
echo "-----------------------------"
cat temp.age | head -n4 > age.reduced
cat age.reduced
echo "-----------------------------"

while read age; do
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"mojix.alebridge.age.$DATADOG_METRIC_NAME\",
          \"points\":[[$currenttime, $age]],
          \"type\":\"gauge\",
          \"host\":\"$PAPERTRAIL_ALEBRIDGE_HOST.$DATADOG_METRIC_NAME\",
          \"tags\":[\"alebridge:age\"]}
        ]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key='$DATADOG_API_TOKEN''
done < age.reduced
echo "Edge Bridge successfully published"
vizix.cleaning temp.age
vizix.cleaning age.reduced
}

function edgebridge.status {

#Retrieving information from Papertrail
#15 seconds timeframe
#status based metric

PAPERTRAIL_AGE_ARGUMENTS=$(papertrail --min-time '5 seconds ago' "$PAPERTRAIL_ALEBRIDGE_HOST $PAPERTRAIL_ALEBRIDGE_NAME health and status" > health.status)
#Posting to Datadog
echo "-----------------------------"
echo "Edge Bridge Health and Status"
echo "Logs retrieve from: $PAPERTRAIL_ALEBRIDGE_HOST"
echo "Papertrail program used: $PAPERTRAIL_ALEBRIDGE_NAME"
echo "Timeframe: 15 seconds ago"
echo "Posting to Datadog at: infrastructure@mojix.com account"
echo "-----------------------------"

if [ -s /health.status ]
then
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{
      \"check\": \"mojix.alebridge.status.$DATADOG_METRIC_NAME\",
      \"host_name\": \"$PAPERTRAIL_ALEBRIDGE_HOST.$DATADOG_METRIC_NAME\",
      \"timestamp\": $currenttime,
      \"status\": 0
  }" \
'https://app.datadoghq.com/api/v1/check_run?api_key='$DATADOG_API_TOKEN''
else
  #If ALEBridge did not send a healt and status message it will post a CRITICAL Post to Datadog
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{
      \"check\": \"mojix.alebridge.status.$DATADOG_METRIC_NAME\",
      \"host_name\": \"$PAPERTRAIL_ALEBRIDGE_HOST.$DATADOG_METRIC_NAME\",
      \"timestamp\": $currenttime,
      \"status\": 2
  }" \
'https://app.datadoghq.com/api/v1/check_run?api_key='$DATADOG_API_TOKEN''
fi
echo "Health and Status successfully published"
vizix.cleaning health.status
}


function corebridge.lpt {
#Retrieving information from Papertrail
#1 second timeframe
#LPT total for Corebridge

PAPERTRAIL_AGE_ARGUMENTS=$(papertrail --min-time '1 seconds ago' "$PAPERTRAIL_COREBRIDGE_HOST $PAPERTRAIL_COREBRIDGE_NAME lpt=" | awk '{ print $13 }' | grep -oP '(?<=\=\[)(.*?)(?=\,)' > temp.lpt)
#Posting to Datadog
echo "-----------------------------"
echo "Core Bridge Log Parser LPT"
echo "Logs retrieve from: $PAPERTRAIL_COREBRIDGE_HOST"
echo "Papertrail program used: $PAPERTRAIL_COREBRIDGE_NAME"
echo "Timeframe: 1 second ago"
echo "Posting to Datadog at: infrastructure@mojix.com account"
echo "Data to post: "
echo "-----------------------------"
cat temp.lpt | head -n4 > lpt.reduced
cat lpt.reduced
echo "-----------------------------"

while read lpt; do
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"mojix.corebridge.lpt.$DATADOG_METRIC_NAME\",
          \"points\":[[$currenttime, $lpt]],
          \"type\":\"gauge\",
          \"host\":\"$PAPERTRAIL_COREBRIDGE_HOST.$DATADOG_METRIC_NAME\",
          \"tags\":[\"corebridge:lpt\"]}
        ]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key='$DATADOG_API_TOKEN''
done < lpt.reduced
echo "COREBRIDGE LPT has been successfully published"
#Cleaning temporal files
vizix.cleaning temp.lpt
vizix.cleaning lpt.reduced
}

function corebridge.thingcount () {
#Retrieving information from Papertrail
#1 second timeframe
#Thing Count total for Corebridge

PAPERTRAIL_AGE_ARGUMENTS=$(papertrail --min-time '1 seconds ago' "$PAPERTRAIL_COREBRIDGE_HOST $PAPERTRAIL_COREBRIDGE_NAME thing_count_total=" | grep -oPe '(?<=thing_count_total=)(\d*)' > temp.count )
#Posting to Datadog
echo "-----------------------------"
echo "Core Bridge Log Parser Thing Count"
echo "Logs retrieve from: $PAPERTRAIL_COREBRIDGE_HOST"
echo "Papertrail program used: $PAPERTRAIL_COREBRIDGE_NAME"
echo "Timeframe: 1 second ago"
echo "Posting to Datadog at: infrastructure@mojix.com account"
echo "Data to post: "
echo "-----------------------------"
cat temp.count | head -n1 > temp.unique
cat temp.unique
echo "-----------------------------"
#Posting to Datadog
while read count; do
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"mojix.corebridge.thingcount.$DATADOG_METRIC_NAME\",
          \"points\":[[$currenttime, $count]],
          \"type\":\"gauge\",
          \"host\":\"$PAPERTRAIL_COREBRIDGE_HOST.$DATADOG_METRIC_NAME\",
          \"tags\":[\"corebridge:thingcount\"]}
        ]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key='$DATADOG_API_TOKEN''
done < temp.unique
echo "COREBRIDGE Thing Total Count has been successfully published"
vizix.cleaning temp.unique
vizix.cleaning temp.count
}

function corebridge.qsize {

PAPERTRAIL_AGE_ARGUMENTS=$(papertrail --min-time '1 seconds ago' "$PAPERTRAIL_COREBRIDGE_HOST $PAPERTRAIL_COREBRIDGE_NAME ThingsMessageProcessor que_size" | grep -oPe '(?<=que_size_blog=)(\d*)' > qsize.blog )
#Posting to Datadog
echo "-----------------------------"
echo "Core Bridge Log Parser QSize Backlog"
echo "Logs retrieve from: $PAPERTRAIL_COREBRIDGE_HOST"
echo "Papertrail program used: $PAPERTRAIL_COREBRIDGE_NAME"
echo "Timeframe: 1 second ago"
echo "Posting to Datadog at: infrastructure@mojix.com account"
echo "Data to post: "
echo "-----------------------------"
cat qsize.blog | head -n4 > qsize.reduced
cat qsize.reduced
echo "-----------------------------"
#Posting to Datadog
while read qsize; do
currenttime=$(date +%s)
curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"mojix.corebridge.qsize.$DATADOG_METRIC_NAME\",
          \"points\":[[$currenttime, $qsize]],
          \"type\":\"gauge\",
          \"host\":\"$PAPERTRAIL_COREBRIDGE_HOST.$DATADOG_METRIC_NAME\",
          \"tags\":[\"corebridge:qsize\"]}
        ]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key='$DATADOG_API_TOKEN''
done < qsize.reduced

echo "COREBRIDGE QSIZE Backlog successfully posted"
vizix.cleaning qsize.blog
vizix.cleaning qsize.reduced

}

#Show configuration:


while true
do

edgebridge.age
edgebridge.status
corebridge.lpt
corebridge.thingcount
corebridge.qsize
done