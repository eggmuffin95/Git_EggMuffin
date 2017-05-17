#!/usr/local/bin/python3.6

import boto3
import json
from pprint import pprint,pformat

ecs = boto3.client('ecs')
clusters = ecs.list_clusters()['clusterArns']

for cluster in clusters:
    cluster_info = ecs.describe_clusters(clusters=[cluster])['clusters'][0]

#print(clusters)
    #print(json.dumps(cluster_info))
    pprint(cluster_info)
