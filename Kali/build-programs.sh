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
apt-get update && apt-get upgrade -y
apt-get dist-upgrade -y

#basic toolset
apt-get install powershell libxml2-dev libxslt1-dev sipcalc rstat-client cifs-utils oscanner rusers filezilla ipmitool freeipmi htop iftop wondershaper libssl-dev libffi-dev python3-dev build-essential nfs-common rsh-client python3-pip python2 seclists tmux -y

#pip2 install
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python2 /tmp/get-pip.py

cd "$toolsdir/tools"

#spraying toolkit
git clone https://github.com/byt3bl33d3r/SprayingToolkit.git 
pip3 install -r "$toolsdir/tools/SprayingToolkit/requirements.txt"

#Enum4linux-ng
apt-get install smbclient python3-ldap3 python3-yaml python3-impacket -y
git clone https://github.com/cddmp/enum4linux-ng.git

#testssl
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

#Powersploit 
git clone https://github.com/PowerShellMafia/PowerSploit.git
 
#Impacket
git clone https://github.com/CoreSecurity/impacket.git
python3 "$toolsdir/tools/impacket/setup.py" install
 
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

#Covenant
apt-get install -y dotnet-sdk-3.1 -y
git clone --recurse-submodules https://github.com/cobbr/Covenant
dotnet build "$toolsdir/tools/Covenant/Covenant"

#winrm
gem install evil-winrm

#kerbrute
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64

#sharphound3
mkdir sharphound3
cd sharphound3
wget https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/AzureHound.ps1
wget https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe
wget https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.ps1

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
