#!/bin/sh
cd /clone
while [ true ]
do
echo "The current time is " `date` > /clone/index.html
sleep 1
done
