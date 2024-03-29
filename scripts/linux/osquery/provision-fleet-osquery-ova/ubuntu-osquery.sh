#!/bin/bash -eux

# RUN AS ROOT

apt -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update

apt -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable"

apt -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update

apt -yqq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install mysql-server redis docker-ce

systemctl enable --now redis-server
systemctl enable --now mysql

# MYSQL SETUP
mysql -u root < fleetsetup.sql
systemctl restart mysql

wget -O fleet.tar.gz "https://github.com/fleetdm/fleet/releases/download/fleet-v4.23.0/fleet_v4.23.0_linux.tar.gz"
wget -O fleetctl.tar.gz https://github.com/fleetdm/fleet/releases/download/fleet-v4.23.0/fleetctl_v4.23.0_linux.tar.gz
tar xvf fleet.tar.gz
tar xvf fleetctl.tar.gz
mkdir /opt/fleet/
cp fleet_v4.23.0_linux/fleet /opt/fleet
cp fleetctl_v4.23.0_linux/fleetctl /opt/fleet

/usr/local/bin/fleet prepare db \
    --mysql_address=127.0.0.1:3306 \
    --mysql_database=fleet \
    --mysql_username=root \
    --mysql_password='PASTE_YOUR_PASSWORD_HERE'

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout /opt/fleet/server.key -out /opt/fleet/server.cert \
    -subj "/CN=fleet.ccdc.local" -addext "subjectAltName=DNS:fleet.ccdc.local"

cp fleet.service /etc/systemd/system/
systemctl enable --now fleet

# FIRST TIME SETUP: create a user account on https://fleet.ccdc.local
# Click Add Hosts, get the enroll secret from the commands, run the commands below for DEB/EXE/RPM (put the enroll secret in quotes)
# /opt/fleet/fleetctl package --type=deb --fleet-url=https://fleet.ccdc.local --enroll-secret="ENROLL_SECRET" --insecure --service --disable-updates
# /opt/fleet/fleetctl package --type=rpm --fleet-url=https://fleet.ccdc.local --enroll-secret="ENROLL_SECRET" --insecure --service --disable-updates
# /opt/fleet/fleetctl package --type=msi --fleet-url=https://fleet.ccdc.local --enroll-secret="ENROLL_SECRET" --insecure --service --disable-updates
# then, export the packages, put in GitHub, use with Ansible
# note: requires setting fleet.ccdc.local in hosts file per client