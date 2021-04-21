#!/bin/bash
sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
sudo yum install -y epel-release
sudo yum install -y nginx
