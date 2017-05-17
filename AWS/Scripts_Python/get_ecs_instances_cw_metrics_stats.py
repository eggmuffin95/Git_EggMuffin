#!/usr/local/bin/python3.6

import boto3
import json
import logging
from datetime import datetime, timedelta
from pprint import pprint,pformat

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_ecs_instances_cw_metrics_stats(event,context):
    logger.info("CloudWatch Logs INFO")

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
        logger.error("No existing ECS Cluster")
        return False

    for cluster in clusters:
        cluster_ec2 = ecs.list_container_instances(cluster = cluster)['containerInstanceArns']
        cluster_ec2_detail = ecs.describe_container_instances(cluster = cluster,containerInstances = cluster_ec2)['containerInstances'][0]['ec2InstanceId']

        cluster_ec2_metrics_list = cw.list_metrics(Dimensions = [{'Name' : 'InstanceId','Value' : cluster_ec2_detail}])['Metrics']

        for metric in cluster_ec2_metrics_list:

            cluster_ec2_metrics_stats = cw.get_metric_statistics(
                Namespace = metric['Namespace'],
                MetricName = metric['MetricName'],
                Dimensions= metric['Dimensions'],
                StartTime = datetime(2017, 3, 25),
                EndTime = datetime(2017, 3, 28),
                Period = 300,
                Statistics = ['Average']
            )
            pprint(cluster_ec2_metrics_stats)

if __name__ == '__main__':
    get_ecs_instances_cw_metrics_stats(None,None)
