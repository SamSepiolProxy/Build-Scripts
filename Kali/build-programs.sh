#!/bin/bash

toolsdir="/opt"
user="test"

if [[ $EUID -ne 0 ]]; then
  echo "Script must be run as a root user" 2>&1
  exit 1
fi

cd /tmp

mkdir "$toolsdir/tools"

#Set timezone
timedatectl set-timezone Europe/London

#updates and upgrades
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/debian bullseye stable" | sudo tee  /etc/apt/sources.list.d/docker.list
apt-get update && apt-get upgrade -y
apt-get dist-upgrade -y

#basic toolset
apt-get install powershell libxml2-dev libxslt1-dev sipcalc rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev build-essential nfs-common rsh-client python3-pip python2 seclists tmux gobuster docker-ce docker-ce-cli containerd.io pipx -y

#pip2 install
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python2 /tmp/get-pip.py

cd "$toolsdir/tools"

#mspsray
git clone https://github.com/SecurityRiskAdvisors/msspray.git

#Impacket
python3 -m pipx install impacket

#Enum4linux-ng
apt-get install smbclient python3-ldap3 python3-yaml python3-impacket -y
git clone https://github.com/cddmp/enum4linux-ng.git

#testssl
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

#Powersploit 
git clone https://github.com/SamSepiolProxy/PowerSploit.git
 
#Winpeas and Linpeas
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git

#Linenum 
git clone https://github.com/rebootuser/LinEnum.git

#Responder
git clone https://github.com/lgandx/Responder.git

#dnscan
git clone https://github.com/rbsec/dnscan.git
pip3 install -r "$toolsdir/tools/dnscan/requirements.txt"

#Pcredz
apt-get install libpcap-dev -y
pip3 install Cython
pip3 install python-libpcap
git clone https://github.com/lgandx/PCredz.git

#ADModule
git clone https://github.com/samratashok/ADModule.git

#winrm
gem install evil-winrm

#kerbrute
mkdir kerberute
cd kerberute
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64
cd "$toolsdir/tools"

#ldapnomnom
mkdir ldapnomnom
cd ldapnomnom
wget https://github.com/lkarlslund/ldapnomnom/releases/download/v1.3.0/ldapnomnom-linux-x64
cd "$toolsdir/tools"

#sharphound3
mkdir sharphound
cd sharphound
wget https://github.com/BloodHoundAD/SharpHound/releases/download/v2.3.3/SharpHound-v2.3.3.zip
wget https://github.com/BloodHoundAD/AzureHound/releases/download/v2.1.7/azurehound-windows-amd64.zip
wget https://github.com/BloodHoundAD/AzureHound/releases/download/v2.1.7/azurehound-linux-amd64.zip
cd "$toolsdir/tools"

#Bloodhound
pip3 install bloodhound
mkdir bloodhounddocker
cd bloodhounddocker
wget https://raw.githubusercontent.com/SpecterOps/BloodHound/main/examples/docker-compose/docker-compose.yml
cd "$toolsdir/tools"

#statistically-likely-usernames
git clone https://github.com/insidetrust/statistically-likely-usernames.git

#pywerview
pip3 install pywerview

#Custom Scripts
git clone https://github.com/SamSepiolProxy/Scripts.git

#updog
pip3 install updog

#usernames list
git clone https://github.com/insidetrust/statistically-likely-usernames.git

#coercer
python3 -m pip install coercer

#enable xrdp
#apt install xrdp -y
#sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini
#systemctl start xrdp
#systemctl start xrdp-sesman
#systemctl enable xrdp
#systemctl enable xrdp-sesman

#enable ssh
systemctl enable ssh
service ssh start
#Add audit for root in /var/log/commands.log 
cat <<EOF >> /etc/rsyslog.conf
local6.*    /var/log/commands.log
EOF

cat <<EOF >> /root/.zshrc
precmd() { eval 'RETRN_VAL=$?;logger -p local6.debug "\$(whoami) [\$\$]: \$(history | tail -n1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [\$RETRN_VAL]"' }
EOF

cat <<EOF >> /home/$user/.zshrc
precmd() { eval 'RETRN_VAL=$?;logger -p local6.debug "\$(whoami) [\$\$]: \$(history | tail -n1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [\$RETRN_VAL]"' }
EOF

cat <<EOF >> /root/.bashrc
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "\$(whoami) [\$\$]: \$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [\$RETRN_VAL]"'
EOF

cat <<EOF >> /home/$user/.bashrc
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "\$(whoami) [\$\$]: \$(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [\$RETRN_VAL]"'
EOF

msfdb init
systemctl enable postgresql

echo "Done"
