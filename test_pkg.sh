#!/bin/sh
set -e

rm -f freebsd-*.pkg
mix deps.get
mix freebsd.pkg
pkg install -y freebsd-*.pkg

echo "Enabling service..."
service freebsd enable

echo "Checking status..."
set +e
service freebsd status
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "Status should exit 1 when not running; Got $result instead"
    exit 1
fi

echo "Starting service..."
service freebsd start
sleep 1
echo "Checking status..."
service freebsd status
result=$?
if [ $result -ne 0 ]
then
    echo "Status should exit 0 when running; Got $result instead"
    exit 1
fi

echo "Stopping service..."
service freebsd stop
sleep 1
echo "Checking status..."
set +e
service freebsd status
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "Status should exit 1 when not running; Got $result instead"
    exit 1
fi

echo "Retarting service..."
service freebsd restart
sleep 1
echo "Checking status..."
service freebsd status
result=$?
if [ $result -ne 0 ]
then
    echo "Status should exit 0 when running; Got $result instead"
    exit 1
fi

echo "All systems go!"
