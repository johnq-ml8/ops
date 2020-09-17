#!/bin/bash
## ec2_instance_start_stop.sh v1.0
##   Control EC2 instance states
##
## AWSPARAMS -- provide the profile and region, and any other awscli global parameters.
## DNSINDEX -- location of DNS list
##   Format of this file is, one entry per line: ZoneID DNSzone DNSrecord InstanceID
## DNSSCRIPT -- script to invoke to update DNS

TARGETSTATE="$1"
INSTANCEID="$2"

AWSPARAMS="--profile lab1ops --region us-east-1"
DNSINDEX="$HOME/aws/9-5_m-f_dns.txt"
DNSSCRIPT="$HOME/aws/route53_update_a_from_ec2.sh"

if [ $$ -lt 2 ]
then
	echo "Usage: $0 <state> <instanceid>"
	exit 1
fi

date

case $TARGETSTATE in
	start)
		echo "aws ${AWSPARAMS} ec2 start-instances --instance-id ${INSTANCEID}"
		aws ${AWSPARAMS} ec2 start-instances --instance-id ${INSTANCEID}

		CURRENTSTATE=`aws ${AWSPARAMS} ec2 describe-instance-status --instance-ids ${INSTANCEID} --output text | grep STATE | awk '{print $NF}'`
		while [ "${CURRENTSTATE}" != "running" ]
		do
			sleep 180
			echo "aws ${AWSPARAMS} ec2 describe-instance-status --instance-ids ${INSTANCEID} --output text | grep STATE | awk '{print $NF}'"
			CURRENTSTATE=`aws ${AWSPARAMS} ec2 describe-instance-status --instance-ids ${INSTANCEID} --output text | grep STATE | awk '{print $NF}'`
		done
		echo "${DNSSCRIPT} `grep ${INSTANCEID} ${DNSINDEX}`"
		${DNSSCRIPT} `grep ${INSTANCEID} ${DNSINDEX}`

		;;
	stop)
		echo "aws ${AWSPARAMS} ec2 stop-instances --instance-id ${INSTANCEID}"
		aws ${AWSPARAMS} ec2 stop-instances --instance-id ${INSTANCEID}

		;;
	reboot)
		echo "aws ${AWSPARAMS} ec2 reboot-instances --instance-id ${INSTANCEID}"
		aws ${AWSPARAMS} ec2 reboot-instances --instance-id ${INSTANCEID}

		;;
	*)
esac

