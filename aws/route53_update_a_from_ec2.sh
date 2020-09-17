#!/bin/bash
## Script to update a single Route53 DNS entry
## Author: John Q.   Updated: 2017-09-26

## Standard variables
AWSZONEID="$1"
DNSZONE="$2"
RECORDSET="$3"
INSTANCE="$4"
TTL=300
AWSPARAMS="--profile lab1ops --region us-east-1"
###

printf "=== Route53 Update === \n"
printf "ZoneID: ${AWSZONEID} | DNS Zone: ${DNSZONE} | RecordSet: ${RECORDSET} \n | InstanceID: ${INSTANCE}"

## Pull current IP from instance ID
MYIP="`aws --profile lab1ops --region us-east-1  ec2 describe-instances --instance-ids ${INSTANCE} --output text | grep ASSOCIATION | uniq | awk '{print $NF}'`"
printf "Current IP from DNS: "
printf "${MYIP} ... \n"

## Pull current record from NameServers (warning, could be out of date if a recent change was submitted)
SITEIP="`dig +short ${RECORDSET}`"

if [ "${SITEIP}" == "${MYIP}" ] ; then
        printf "IP ${SITEIP} unchanged.\n"
else
        ## Send change request using formatted JSON
        printf "Updating ${MYIP} ... \n"
        aws ${AWSPARAMS} route53 change-resource-record-sets  --cli-input-json  "{ \"HostedZoneId\":\"${AWSZONEID}\", \"ChangeBatch\": { \"Comment\":\"Update ${DNSZONE} ${RECORDSET} to ${MYIP}\",\"Changes\":[ { \"Action\":\"UPSERT\",\"ResourceRecordSet\": { \"Name\":\"${RECORDSET}\", \"Type\":\"A\", \"TTL\":${TTL}, \"ResourceRecords\": [ { \"Value\":\"${MYIP}\" } ] } } ] } }"

fi

printf "=== Done. ===\n"

