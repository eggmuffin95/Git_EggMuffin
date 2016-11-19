#!/usr/bin/php
<?php
# A simple PHP script to start all Amazon EC2 instances and Amazon RDS
# databases within all regions.
#
# USAGE: stopinator.php [-t stop-tags] [-nt exclude-tags]
#
# If no arguments are supplied, stopinator stops every Amazon EC2 and 
# Amazon RDS instance running in an account. 
#
# -t stop-tag: The tags to inspect to determine if a resource should be 
# shut down. Format must follow the same format used by the AWS CLI.
#
# -e exclude-id: The instance ID of an Amazon EC2 instance NOT to terminate. Useful
# when running the stopinator from an Amazon EC2 instance. 
#
# -p profile-name: The name of the AWS configuration section to use for 
# credentials. Configuration sections are defines in your .aws/credentials file. 
# If not supplied, will use the default profile. 
#
# -s start: If present, starts instead of stops instances.
# PREREQUISITES
# This app assumes that you have defined an .aws/credentials file. 

require 'vendor/autoload.php';
use Aws\Ec2\Ec2Client;

date_default_timezone_set('UTC');

# Obtain the profile name.
$profile = "default"; 
$opts = getopt('p::t::e::s::');
if (array_key_exists('p', $opts)) { $profile = $opts['p']; }

$excludeID = "";
if (array_key_exists('e', $opts)) {
	$excludeID = $opts['e'];
}

$start = false;
if (array_key_exists('s', $opts)) {
	$start = true;
}

$ec2DescribeArgs = array();
if (array_key_exists('t', $opts))
{
	$tagArray = array();
	foreach (explode(";", $opts['t']) as $pair) { 
                $nameVal = explode("=", $pair);
		array_push($tagArray, array(
			'Name' => "tag:" . $nameVal[0], 
			'Values' => array($nameVal[1])
			));
	}

	$ec2DescribeArgs['Filters'] = $tagArray; 
}

# Iterate through all available AWS regions.
$ec2 = Ec2Client::factory(array(
	'profile' =>$profile,
	'region' => 'us-east-1'
));

$regions = $ec2->describeRegions();
foreach ($regions['Regions'] as $region) {
	$instanceIds = array();

	# Find resources in each region. 
	echo 'Region is ' . $region['RegionName'] . "\n"; 
	$ec2Current = Ec2Client::factory(array( 
		'profile' => $profile, 
		'region' => $region['RegionName']
	));
	$result = $ec2Current->describeInstances($ec2DescribeArgs);
	foreach ($result['Reservations'] as $reservation) {
		foreach ($reservation['Instances'] as $instance) {
			# Check that this is not an excluded instance. 	
			if (strlen($excludeID) > 0 && $excludeID == $instance['InstanceId']) {
				echo "\tExcluding instance " . $instance['InstanceId'] . "\n";
			} else { 
				# Is it a running instance?
				if ($start) {
					if ($instance['State']['Code'] == 80) {
						array_push($instanceIds, $instance['InstanceId']);
						echo "\tIdentified instance " . $instance['InstanceId'] . "\n"; 
					} else {
						echo "\tInstance " . $instance['InstanceId'] . " - not stopped\n";  
					}
				} else {
					if ($instance['State']['Code'] == 16) {
						array_push($instanceIds, $instance['InstanceId']); 
						echo "\tIdentified instance " . $instance['InstanceId'] . "\n"; 
					} else {
						echo "\tInstance " . $instance['InstanceId'] . " - already stopped\n"; 
					}
				}
			}
		}
	} 

	if ($start) {
		if (count($instanceIds) > 0) { 
			echo "\n\tStarting identified instances in " . $region . "...\n"; 
			$ec2Current->startInstances(array(
				"InstanceIds" => $instanceIds
			));
		} else {
			echo "\n\tNo instances to start in " . $region . "\n";  
		} 
	} else { 
		# Stop all identified instances. 
		if (count($instanceIds) > 0) {
			echo "\n\tStopping identified instances in " . $region . "...\n";
			$ec2Current->stopInstances(array(
				"InstanceIds" => $instanceIds
			));
		} else {
			echo "\n\tNo instances to stop in " . $region . ".\n"; 
		}
	} 
}
?>
