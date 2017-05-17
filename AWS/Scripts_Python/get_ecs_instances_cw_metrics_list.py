#!/usr/local/bin/python3.6

import boto3
import json
import logging
from pprint import pprint,pformat

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_ecs_instances_cw_metrics_list(event,context):
    logger.info("Get ECS Instances Metrics INFO")

    ecs = boto3.client('ecs')
    if not ecs:
        logger.error("ecs_error")
        return False
    cw = boto3.client('cloudwatch')
    if not cw:
        logger.error("cw_error")
        return False

    clusters = ecs.list_clusters()['clusterArns']
    if not clusters:
        logger.error("No existing ECS cluster")
        return False

    for cluster in clusters:
        cluster_ec2 = ecs.list_container_instances(cluster = cluster)['containerInstanceArns']
        cluster_ec2_detail = ecs.describe_container_instances(cluster = cluster,containerInstances = cluster_ec2)

        for instance in cluster_ec2_detail['containerInstances']:
            cluster_ec2_metrics_list = cw.list_metrics(Dimensions = [{'Name' : 'InstanceId','Value' : instance['ec2InstanceId']}])
            print("La liste des métriques pour l'instance",instance['ec2InstanceId'],"sont :")

            for metrics in cluster_ec2_metrics_list['Metrics']:
                pprint(metrics['MetricName'])

if __name__ == '__main__':
    get_ecs_instances_cw_metrics_list(None,None)
