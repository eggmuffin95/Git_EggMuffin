#!/bin/bash
echo "Quel est l'URL ou le HostName à filtrer ?"
read url
tcpdump -vvvs 1024 -l -A host $url
