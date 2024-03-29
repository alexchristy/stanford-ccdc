#!/bin/sh

PUBKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYvzQye+bvaQHfRXjVvWQ/WHh/rCDdR7Blu1vSokE+3 user@wrccdc.ccdc.local'
echo 'newccdcadmin:x:0:0::/root:/bin/sh' >> /etc/passwd
echo 'newccdcadmin:$6$H9Hu79n7$E9Wo.RfsPrhBlSZs0DiVv9tPXXYQtxv7OyuqaNOprODMg4.o63P2vq.VMAF.zVszgU2i99iGz4WLpiwb4nlvN.:19312:0:99999:7:::' >> /etc/shadow
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
