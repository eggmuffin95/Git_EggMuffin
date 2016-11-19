#!/bin/bash

aws ec2 describe-snapshots --filters "Name=volume-id,Values="Volume-ID""
