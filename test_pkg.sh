#!/bin/sh
set -e

basic_env="/usr/local/etc/freebsd_basic.d/freebsd_basic.env"
user_env="/usr/local/etc/freebsd_user.d/freebsd_user.env"

if [ -f /usr/local/bin/bash ]
then
    echo "bash should not be installed yet (it's a package dependency)"
    exit 1
fi

if [ -f $basic_env ]; then
    echo "${basic_env} should not exist yet"
    exit 1
fi

echo "# Testing basic package"
cd test/support/basic >/dev/null

rm -f freebsd_basic-*.pkg
mix local.hex --if-missing --force
mix deps.get
mix release --overwrite
mix freebsd.pkg
pkg install -y freebsd_basic-*.pkg

if [ ! -f /usr/local/bin/bash ]
then
    echo "bash should have been installed as a package dependency"
    exit 1
fi

if [ ! -f $basic_env ]; then
    echo "${basic_env} should have been installed"
    exit 1
fi

set +e
ls -l $basic_env | awk '{print $3}' | grep root
result=$?
set -e
if [ $result -ne 0 ]; then
    echo "${basic_env} should be owned by root"
    exit 1
fi

echo "## Enabling service..."
service freebsd_basic enable

echo "## Checking status..."
set +e
service freebsd_basic status
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "Status should exit 1 when not running; Got $result instead"
    exit 1
fi

if [ -f /var/log/freebsd_basic.log ]
then
    echo "Log file should not exist yet"
    exit 1
fi

echo "## Starting service..."
service freebsd_basic start
sleep 1
echo "## Checking status..."
service freebsd_basic status
result=$?
if [ $result -ne 0 ]
then
    echo "Status should exit 0 when running; Got $result instead"
    exit 1
fi

set +e
echo "## Checking that user is root"
app_pid=`cat /var/run/freebsd_basic.pid`
ps -p "${app_pid}" -o user | grep root
result=$?
set -e
if [ $result -ne 0 ]
then
    echo "Process should be running as root"
    exit 1
fi

if [ ! -f /var/log/freebsd_basic.log ]
then
    echo "Log file should exist"
    exit 1
fi

echo "## Stopping service..."
service freebsd_basic stop
sleep 1
echo "## Checking status..."
set +e
service freebsd_basic status
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "Status should exit 1 when not running; Got $result instead"
    exit 1
fi

echo "## Restarting service..."
service freebsd_basic restart
sleep 1
echo "## Checking status..."
service freebsd_basic status
result=$?
if [ $result -ne 0 ]
then
    echo "Status should exit 0 when running; Got $result instead"
    exit 1
fi

service freebsd_basic stop

cd -


echo
echo "# Testing user package"
cd test/support/user >/dev/null

echo "## Checking pre-install user..."
set +e
id appuser >/dev/null
result=$?
set -e
if [ $result -ne 1 ]
then
    echo "User should not exist before installing package"
    exit 1
fi

if [ -f $user_env ]; then
    echo "${user_env} should not exist yet"
    exit 1
fi

rm -f freebsd_user-*.pkg
mix local.hex --if-missing --force
mix deps.get
mix release --overwrite
mix freebsd.pkg
pkg install -y freebsd_user-*.pkg

echo "## Checking user..."
set +e
id appuser >/dev/null
result=$?
set -e
if [ $result -ne 0 ]
then
    echo "User should exist after installing package"
    exit 1
fi

if [ ! -f $user_env ]; then
    echo "${user_env} should have been installed"
    exit 1
fi

set +e
ls -l $user_env | awk '{print $3}' | grep appuser
result=$?
set -e
if [ $result -ne 0 ]; then
    echo "${user_env} should be owned by appuser"
    exit
fi

echo "## Enabling service..."
service freebsd_user enable

if [ -f /var/log/freebsd_user.log ]
then
    echo "Log file should not exist yet"
    exit 1
fi

echo "## Starting service..."
service freebsd_user start
sleep 1

echo "## Checking service status..."
service freebsd_user status
result=$?
if [ $result -ne 0 ]
then
    echo "Status should exit 0 when running; Got $result instead"
    exit 1
fi

set +e
echo "## Checking that user is not root"
app_pid=`cat /var/run/freebsd_user.pid`
ps -p "${app_pid}" -o user | grep appuser
result=$?
set -e
if [ $result -ne 0 ]
then
    echo "Process should be running as appuser"
    exit 1
fi

if [ ! -f /var/log/freebsd_user.log ]
then
    echo "Log file should exist"
    exit 1
fi

set +e
ls -l /var/log/freebsd_user.log | awk '{print $3}' | grep root
result=$?
set -e
if [ $result -ne 0 ]; then
    echo "freebsd_user.log should be owned by root"
    exit
fi

if [ ! -d /var/run/freebsd_user ]; then
    echo "/var/run/freebsd_user should exist"
    exit 1
fi

set +e
ls -ld /var/run/freebsd_user | awk '{print $3}' | grep appuser
result=$?
set -e
if [ $result -ne 0 ]; then
    echo "/var/run/freebsd_user should be owned by appuser"
    exit
fi

service freebsd_user stop

cd -

echo "All systems go!"
