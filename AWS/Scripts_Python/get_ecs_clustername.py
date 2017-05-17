#!/usr/local/bin/python3.6

import boto3
import json
import logging
from datetime import datetime, timedelta
from pprint import pprint,pformat

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_clustername():
    logger.info("Get Autoscaling Services Policies Infos")

    ecs = boto3.client('ecs')
    if not ecs:
        logger.error("ecs_error")
        return False

    appasc = boto3.client('application-autoscaling')
    if not appasc:
        logger.error('application-autoscaling error')
        return False

    cluster_list = ecs.list_clusters()['clusterArns']
    describe_cluster = ecs.describe_clusters(clusters = cluster_list)

    ListClusterName = []
    for cluster in describe_cluster['clusters']:
        if 'clusterName' in cluster:
            ListClusterName.append(cluster['clusterName'])

    pprint(ListClusterName)

if __name__ == '__main__':
    get_clustername()
