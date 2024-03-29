#!/bin/sh
#
# MAKE SURE THIS WORKS ON EVERY DISTRO EVER, ESPECIALLY THE IP TABLES BITS

# USAGE: bash spray_linux.sh NEW_DEFAULT_PASSWORD DEFAULT_SUDO_USER (optional)
# TEST CONDUCTED USING HARDCODED DEFUALT PASSWORD


# Nothing appears in history
set +o history

# TODO MAKE SURE WE CAN FIND IPTABLES ON DEBIAN BASED SYSTEMS

# Global variables
# UPDATE THIS PUBKEY WITH EVERY NEW PUBLIC RELEASE
PUBKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII60R2wnE2PGLBDUXhhqLoylh3qjAJrVyYItQT8N0Ty+ root@salt'

# Roll default admin and root creds to new default passsword
echo root:$1 | chpasswd
if [[ -n $SUDO_USER ]]; then
    echo $SUDO_USER:$1 | chpasswd # TODO, MAKE SURE THIS LOGIC WORKS
fi
if [[ -n $2 ]]; then
    echo $2:$1 | chpasswd
fi
# TODO MAYBE I CAN SHORTEN THIS

# Add our pubkey to root
mkdir -p /root/.ssh/
echo $PUBKEY > /root/.ssh/authorized_keys # probably have to fix the permissions here

# Make sure pubkey has correct permissions
# TODO, VALIDATE THIS RANDOM BS I FOUND ON STACKOVERFLOW
chown root:root /root/.ssh/authorized_keys
chmod u+rwX,go-rwX,-t /root/.ssh/authorized_keys
chmod go-w /root/

# allow root ssh login
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# apply ssh settings
systemctl restart sshd || service ssh restart

# backup the firewall, do not clobber old backups
if ! [ -f /tmp/iptables_backup ]; then
    iptables-save > /tmp/iptables_backup
fi

# check if UFW is installed and disable if installed
if which ufw >/dev/null 2>&1; then
    ufw disable
fi

# check if firewalld is installed and disable if installed
if which firewalld >/dev/null 2>&1; then
    systemctl stop firewalld
    systemctl disable firewalld
fi

# save all listening and established connections at start
lsof -Pni >/tmp/existing_connections 2>&1

# Make sure we don't get locked out while the rest of the script runs
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# toss all existing firewall rules
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
# TODO, TEST THIS GIVEN THAT LINUX IS A DEPENDENCY OF OTHER STUFF
# TODO CHECK INTERACTION WITH NFTABLES

# Allow eveerything from localhost
iptables -A INPUT -s 127.0.0.1/32 -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow related connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

#allow global inbound from service ports including ssh
iptables -A INPUT -p tcp -m multiport --dports 21,22,25,53,80,110,143,389,443,465,993,995,8080,8443 -j ACCEPT

# allow ccs client
iptables -A OUTPUT -p tcp -d 10.120.0.111 -m multiport --dports 80,443 -j ACCEPT

# respond to pings
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT

# Retrieve the primary network interface
INTERFACE=$(ip route | awk '/default/ { print $5; exit }')

# Retrieve the subnet of the primary network interface
SUBNET=$(ip -o -f inet addr show dev $INTERFACE | awk '/inet/ { print $4 }')

# allow outbound to local subnet
iptables -A OUTPUT -p tcp -d $SUBNET -j ACCEPT

# allow inbound from local subnet to 3306, 5432
iptables -A INPUT -p tcp -s $SUBNET -m multiport --dports 3306,5432 -j ACCEPT

# default deny everything
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# TODO, IS THIS A GOOD IDEA?
# retrieve network_killer
#chmod +x /root/network_killer

# I don't think this does anything but just to be safe
history -c
