#!/bin/bash

function datetime(){
    date +"%F %T"
}


read -p "Remote Machine IP:"  REMOTE_IP

read -p "Remote User:" REMOTE_USER

read -p "Remote Interface" REMOTE_INTERFACE

# IP of first interface on this machine
LOCAL_IP=$(hostname -I | awk '{print $1}')

remote=$REMOTE_USER@$REMOTE_IP

ssh -t $remote "sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump"

now=$(datetime)

tcp="tcpdump -i $REMOTE_INTERFACE -U -w - not host $LOCAL_IP"

PCAP_NAME="$REMOTE_IP ${now}"

PCAP_DIR="$HOME/PCAPS"

cd "$PCAP_DIR"

ssh $remote $tcp  > ".$PCAP_NAME"

mv ".$PCAP_NAME" "$PCAP_NAME"