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

