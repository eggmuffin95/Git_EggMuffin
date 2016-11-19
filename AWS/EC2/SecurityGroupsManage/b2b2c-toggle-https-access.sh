#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

RESULT=0
AWS_COMMAND=""
WAIT=0
DATE=`date +%Y-%m-%d:%H:%M:%S`

while getopts "arw:" opt; do
    case "$opt" in
    a)  AWS_COMMAND="authorize-security-group-ingress"
        ;;
    r)  AWS_COMMAND="revoke-security-group-ingress"
        ;;
    w)  WAIT=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))


echo -e "\n["${DATE}"]" 

[ "$AWS_COMMAND" = "" -a "$WAIT" = 0 ] && echo "ERROR: $0 : No option given. Exit Script" && exit 1;

if [ "$WAIT" = 0 ]; then
    /usr/local/bin/aws ec2 $AWS_COMMAND --group-id sg-9f9425f8 --protocol tcp --port 443 --cidr 0.0.0.0/0 || exit $?;
    echo -e "\n*** b2b2c-staging aws $AWS_COMMAND tcp 443 0.0.0.0/0 => OK"
else
    AWS_COMMAND="authorize-security-group-ingress"
    /usr/local/bin/aws ec2 $AWS_COMMAND --group-id sg-9f9425f8 --protocol tcp --port 443 --cidr 0.0.0.0/0 || exit $?;
    echo -e "\n*** b2b2c-staging aws $AWS_COMMAND tcp 443 0.0.0.0/0 => OK"
    echo -e "\n Waiting Time : $WAIT"
    sleep $WAIT
    AWS_COMMAND="revoke-security-group-ingress"
    /usr/local/bin/aws ec2 $AWS_COMMAND --group-id sg-9f9425f8 --protocol tcp --port 443 --cidr 0.0.0.0/0 || exit $?;
    echo -e "\n*** b2b2c-staging aws $AWS_COMMAND tcp 443 0.0.0.0/0 => OK"
fi

exit 0;
