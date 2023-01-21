# Deploying Remote Packet Capture and Analysis Enviroment

## Remote Capture

### Requirements :

- Target machine with SSH enabled , username and password/key 

- Remote user must have sudo rights to enable packet capture rights

- tcpdump installed on target machine

### Steps :

- Execute `monitor.sh` 
- Supply Remote machine IP address and Interface to monitor
- When you are done with packet capturing session , Press CTRL + C to end the script and save the PCAP file

### Notes :

- PCAPS are saved under $HOME/PCAPS
- PCAPS name format : RemoteIP DATEandTIME

`monitor.sh`

```bash
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
```

---

## Analysis

### Requirements

- Docker installed on local machine
- `PCAPS` and `ANALYSIS` Folders on home directory

### Steps

- Create a docker container from supplied image `zeek_monitor`

- Start container with bind mounts : PCAPS:/PCAPS and ANALYSIS:/ZEEK_OUT
  
  ```docker
  docker run -d -it --name $CONTAINER_NAME  --mount type=bind,source=$HOME/PCAPS/,target=/PCAPS --mount type=bind,source=$HOME/A
  NALYSIS,target=/ZEEK_OUT zeek_monitor:latest`
  ```

- Start packet capturing as in first sectioning , when the PCAP is exported to PCAPS folder , zeek will automatically process it and output the logs in a folder with the same name as the packet in `ANALYSIS` folder.

### Extra

#### Building the Zeek Image

`Dockerfile`

```dockerfile
#DOCKERFILE for running zeek to monitor a specific mounted folder for PCAPS for analysis logging
#AUTHOR omarmsamir27@gmail.com

# https://github.com/zeek/zeek/wiki/Docker-Images
FROM zeekurity/zeek

COPY zeek_monitor.sh /root/scripts/zeek_monitor.sh
CMD bash ~/scripts/zeek_monitor.sh
```

`zeek_monitor.sh`

```bash
#!/bin/bash

function latest_file() {
    ls -t --time=ctime  $1 | head -n1
}

PCAPS=/PCAPS
ZEEK_OUT=/ZEEK_OUT

latest_added=$(latest_file $PCAPS)


while  [ -z "$latest_added" ]
        do
          latest_added=$(latest_file $PCAPS)
          sleep 5
        done

cd $ZEEK_OUT


last_processed=''

while true
  latest_added=$(latest_file $PCAPS)
  do
    if [ "$latest_added" == "$last_processed" ]
     then
        continue
    else
          mkdir "$latest_added"
          cd "$latest_added"
          cp "$PCAPS/$latest_added" .
          zeek -r "$latest_added"
          rm "$latest_added"
          last_processed=$latest_added
          cd $ZEEK_OUT
    fi
    latest_added=$(latest_file $PCAPS)
    sleep 5
  done
```
