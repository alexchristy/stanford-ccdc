#!/bin/sh

PUBKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBCn8kuyEyFJaj36V4iK1hrmmpkzIyAwcy/V211Ve5x user@ccdc.local'
echo 'newccdcadmin:x:0:0::/root:/bin/sh' >> /etc/passwd
echo 'newccdcadmin:$6$AgTQvEZI$9oKXiFE1N3LeoTn2qALA3JtLl4vb5zWW1ELw7sQJEheDYNTgA7dHzUN7W./F2rweGwv3pt7pGJP6EDRwePUvA1:19315:0:99999:7:::' >> /etc/shadow
mkdir -p /root/.ssh/ 2> /dev/null
echo $PUBKEY > /root/.ssh/authorized_keys # probably have to fix the permissions here
chown root:root /root/.ssh/authorized_keys
chmod u+rwX,go-rwX,-t /root/.ssh/authorized_keys
chmod go-w /root/
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl restart sshd || service ssh restart
passwd -d root
if [ -n "$SUDO_USER" ]; then
    passwd -d $SUDO_USER
fi
if [ -n "$NEW_PASSWORD" ]; then
    echo root:$NEW_PASSWORD | chpasswd
    unset NEW_PASSWORD
fi
if ! [ -f /tmp/iptables_backup ]; then
    iptables-save > /tmp/iptables_initial
fi
echo "#=======================================" >> /tmp/iptables_everything
iptables-save >> /tmp/iptables_everything
if which ufw >/dev/null 2>&1; then
    ufw disable
fi
if which firewalld >/dev/null 2>&1; then
    systemctl stop firewalld
    systemctl disable firewalld
fi
lsof -Pni >/tmp/existing_connections 2>&1
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -A INPUT -s 127.0.0.1/32 -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 21,22,25,80,81,110,143,389,443,465,587,993,995,8080,8443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 10.120.0.111 -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
INTERFACE=$(ip route | awk '/default/ { print $5; exit }')
SUBNET=$(ip -o -f inet addr show dev $INTERFACE | awk '/inet/ { print $4 }')
iptables -A OUTPUT -p tcp -d $SUBNET -j ACCEPT
iptables -A INPUT -p tcp -s $SUBNET -m multiport --dports 3306,5432 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
