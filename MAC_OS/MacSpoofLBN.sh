#!/bin/bash
# Note : spoof the Mac Address of en0 only if APIPA's detected

CurrentIP="ipconfig getifaddr en0"

if [[ "$ipconfig"* == *"169.254"* ]]; then
  sudo ifconfig en0 ether ec:f4:bb:36:1f:68
  echo "L'adresse Mac est bien Spoofée"
else
	echo "L'adresse Mac est déjà Spoofée"
fi 

exit 0
