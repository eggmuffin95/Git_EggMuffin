#!/bin/bash

# Date: 24 Fev 2016
# Version 1.0
# Script de suppression automatisé des snapshots EBS
# Yann DANIEL - Bayard Presse
region=("eu-west-1")

purge_EBS_Snapshots() {
  # snapshot_purge_allowed is a string containing the SnapshotIDs of snapshots
  # that contain a tag with the key value/pair PurgeAllow=true
  snapshot_purge_allowed=$(aws ec2 describe-snapshots --region $region --filters Name=tag:PurgeAllow,Values=true --output text --query 'Snapshots[*].SnapshotId')

  for snapshot_id_evaluated in $snapshot_purge_allowed; do
    #gets the "PurgeAfterFE" date which is in UTC with UNIX Time format (or xxxxxxxxxx / %s)
    purge_after_fe=$(aws ec2 describe-snapshots --region $region --snapshot-ids $snapshot_id_evaluated --output text | grep ^TAGS.*PurgeAfterFE | cut -f 3)
    #if purge_after_date is not set then we have a problem. Need to alert user.
    if [[ -z $purge_after_fe ]]; then
      #Alerts user to the fact that a Snapshot was found with PurgeAllow=true but with no PurgeAfterFE date.
      echo "Snapshot with the Snapshot ID \"$snapshot_id_evaluated\" has the tag \"PurgeAllow=true\" but does not have a \"PurgeAfterFE=xxxxxxxxxx\" key/value pair. $app_name is unable to determine if $snapshot_id_evaluated should be purged." 1>&2
    else
      # if $purge_after_fe is less than $current_date then
      # PurgeAfterFE is earlier than the current date
      # and the snapshot can be safely purged
      if [[ $purge_after_fe < $current_date ]]; then
        echo "Snapshot \"$snapshot_id_evaluated\" with the PurgeAfterFE date of \"$purge_after_fe\" will be deleted."
        aws_ec2_delete_snapshot_result=$(aws ec2 delete-snapshot --region $region --snapshot-id $snapshot_id_evaluated --output text 2>&1)
      fi
    fi
  done
