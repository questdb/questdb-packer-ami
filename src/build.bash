#!/usr/bin/env bash

set -euxo pipefail

ls /tmp
ls /tmp/assets

# Setup CloudWatch
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
rm ./amazon-cloudwatch-agent.rpm
sudo mkdir /etc/questdb
sudo mv /tmp/assets/cloudwatch.json /etc/questdb/
sudo mv /tmp/scripts/per-boot.sh /var/lib/cloud/scripts/per-boot/

# Install dependencies
sudo yum update -y -q
sudo yum install -y -q \
    java-11-amazon-corretto-headless \
    ec2-instance-connect \
    amazon-ssm-agent

# Amend bashrc
sudo cat /tmp/assets/bashrc >> /etc/bashrc
. /tmp/assets/bashrc

# Configure logrotate
sudo mkdir /var/log/questdb
sudo mv /tmp/assets/rsyslog.conf /etc/rsyslog.d/questdb.conf
sudo mv /tmp/assets/logrotate.conf /etc/logrotate.d/questdb
sudo chown root:root /etc/logrotate.d/questdb
echo "*/5 * * * * /etc/cron.daily/logrotate" | sudo crontab -

# Setup systemd
echo "SystemMaxUse=1G" | sudo tee -a /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
sudo mv /tmp/assets/systemd.service /usr/lib/systemd/system/questdb.service
sudo systemctl enable questdb

# Install QuestDB
curl -s https://dl.questdb.io/snapshots/questdb-latest-no-jre-bin.tar.gz -o questdb.tar.gz
mkdir binary
tar xf questdb.tar.gz -C binary --strip-components 1
mv binary/questdb.jar /usr/local/bin/
sudo mkdir -p /var/lib/questdb/conf
sudo cp /tmp/config/server.conf /var/lib/questdb/conf/server.conf

# Cleanup
rm questdb.tar.gz
rm -r binary
rm -r /tmp/assets
rm -r /tmp/config
sudo yum clean all
sudo rm -rf /var/cache/yum
