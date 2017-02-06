#!/bin/sh
git clone ${HTTPS_REPO} /clone
if [ $? ] ; then
cd /clone
while [ true ]
do
git pull
sleep 60
done
else
echo '<H1>Clone Operation Failed</H1>' > /clone/index.html
fi
