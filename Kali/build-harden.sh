
#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Script must be run as a root user" 2>&1
  exit 1
fi


#Restrict SSH
#cat <<EOF >> /etc/hosts.allow
#sshd: 10.83.33.77/32, 10.63.152.9/32, 10.12.100.11/28, 10.82.192.0/28
#EOF

#cat <<EOF >> /etc/hosts.deny
#sshd: ALL
#EOF

apt-get install fail2ban -y
systemctl start fail2ban
systemctl enable fail2ban

apt-get install auditd audispd-plugins -y
service auditd start

apt-get install libpam-cracklib -y
cat <<EOF > /etc/pam.d/common-password
password        [success=1 default=ignore]      pam_unix.so obscure yescrypt
password        requisite                       pam_cracklib.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
password        required                        pam_permit.so
password        optional        pam_gnome_keyring.so
EOF

cat <<EOF > /etc/ssh/sshd_config
Banner /etc/issue.net
AllowTcpForwarding yes
ClientAliveInterval 300
ClientAliveCountMax 0
Compression no
LogLevel VERBOSE
MaxAuthTries 3
MaxSessions 10
PermitRootLogin no
TCPKeepAlive no
X11Forwarding no
AllowAgentForwarding no
PermitEmptyPasswords no
LoginGraceTime 60
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward

cat <<EOF > /etc/issue
		PRIVATE SYSTEM
		--------------

************************************************
* Unauthorised access or use of this equipment *
*   is prohibited and constitutes an offence   *
*     under the Computer Misuse Act 1990.      *
*    If you are not authorised to use this     *
*     system, terminate this session now.      *
************************************************
EOF

cat <<EOF > /etc/issue.net
		PRIVATE SYSTEM
		--------------

************************************************
* Unauthorised access or use of this equipment *
*   is prohibited and constitutes an offence   *
*     under the Computer Misuse Act 1990.      *
*    If you are not authorised to use this     *
*     system, terminate this session now.      *
************************************************
EOF

#enable ufw
apt install ufw -y
ufw allow ssh
#ufw allow in 3390
#ufw allow in 8834
ufw logging on
ufw enable

#enable unattended updates
apt install unattended-upgrades -y

echo done

reboot
