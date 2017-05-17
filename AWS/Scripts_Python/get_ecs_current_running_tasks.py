#!/usr/local/bin/python3.6

import sys
sys.path.append("/Users/eggmuffin/Desktop/Scripts_Python")
import boto3
import json
import logging
from datetime import datetime, timedelta
from pprint import pprint,pformat
import get_ecs_services_as_policies

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_current_running_tasks():
    logger.info("Get Current Running Tasks Infos")

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

        ListServiceName = []
        for cluster in ListClusterName:
            services_list = ecs.list_services(cluster = cluster)['serviceArns']

            for service in services_list:
                services_details = ecs.describe_services(
                    cluster = cluster,
                    services = services_list
                )['services'][0]['deployments']

                ListRunningCount = []
                for running in services_details:
                    if 'runningCount' in running:
                        ListRunningCount.append(running['runningCount'])
        print("Le nombre de tâches actuellement en cours de traitement par service est de :")
        pprint(services_list)
        pprint(ListRunningCount)

if __name__ == '__main__':
    get_current_running_tasks()
