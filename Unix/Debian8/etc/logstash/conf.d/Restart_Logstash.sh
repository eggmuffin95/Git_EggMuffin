#Ce script permet de récupérer le PID de logstash, de quitter Logstash et de relancer Logstash
#Récupération du PID logstash
"logstashPID" = ps lax |grep logstash | grep -v grep |awk '{print $3}'
# Puis on Kill le PID
kill $(logstashPID)
# Ensuite on va dans le directory Logstash
cd /opt/logstash
# Et on start logstash avec 2 threads
./bin/logstash -w 2 -f /etc/logstash/conf.d/logstash.conf &

exit 0
