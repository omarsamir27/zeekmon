
#DOCKERFILE for running zeek to monitor a specific mounted volume for PCAPS for analysis logging
#AUTHOR omarmsamir27@gmail.com

# https://github.com/zeek/zeek/wiki/Docker-Images
FROM zeekurity/zeek

COPY zeek_monitor.sh /root/scripts/zeek_monitor.sh
CMD bash ~/scripts/zeek_monitor.sh




