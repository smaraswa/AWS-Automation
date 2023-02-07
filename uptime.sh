#! /bin/bash
port=443

for i in `cat instanceids.txt`; do
  nc -zv $server $port
done

