#!/bin/sh

set +e
which bash
result=$?
if [ $result -ne 1 ]
then
    echo "bash should not be installed yet (it's a package dependency)"
fi
set -e

rm -f freebsd-*.pkg
mix deps.get
mix release
mix freebsd.pkg
pkg install -y freebsd-*.pkg

set +e
which bash
result=$?
if [ $result -ne 0 ]
then
    echo "bash should have been installed as a package dependency"
fi
set -e

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

set +e
ls /var/log/freebsd.log
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "Log file should not exist yet"
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

set +e
ls /var/log/freebsd.log
result=$?
set -e
if [ $result -ne 0 ]
then
    echo "Log file should exist"
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
