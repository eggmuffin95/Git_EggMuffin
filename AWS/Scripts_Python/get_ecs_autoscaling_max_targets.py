#!/usr/local/bin/python3.6

import boto3
import json
import logging
from datetime import datetime, timedelta
from pprint import pprint,pformat

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_autoscaling_max_targets():
    logger.info("Get Autoscaling Services Policies Infos")

    ecs = boto3.client('ecs')
    if not ecs:
        logger.error("ecs_error")
        return False

    appasc = boto3.client('application-autoscaling')
    if not appasc:
        logger.error('application-autoscaling error')
        return False


    TargetDetailsList = appasc.describe_scalable_targets(ServiceNamespace='ecs')['ScalableTargets']

    ListMaxCapacityValues = []
    for resourceID in TargetDetailsList:
        if 'ResourceId' in resourceID:
            ListMaxCapacityValues.append(resourceID['ResourceId'])
            ListMaxCapacityValues.append(resourceID['MaxCapacity'])

    print("La valeur max de tasks deployables en Autoscaling pour les services suivants sont :")
    pprint(ListMaxCapacityValues)

if __name__ == '__main__':
    get_autoscaling_max_targets()
