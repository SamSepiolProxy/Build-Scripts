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
apt-get install powershell build-essential nfs-common python3-pip seclists tmux gobuster docker-ce docker-ce-cli containerd.io pipx -y

cd "$toolsdir/tools"

#mspsray
git clone https://github.com/SecurityRiskAdvisors/msspray.git

#Enum4linux-ng
apt-get install smbclient python3-ldap3 python3-yaml python3-impacket -y
git clone https://github.com/cddmp/enum4linux-ng.git

#testssl
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

#Powersploit 
git clone https://github.com/SamSepiolProxy/PowerSploit.git
 
#Winpeas and Linpeas
mkdir peas
cd peas
wget https://github.com/peass-ng/PEASS-ng/releases/download/20250202-a3a1123d/linpeas.sh
wget https://github.com/peass-ng/PEASS-ng/releases/download/20250202-a3a1123d/winPEAS.bat
wget https://github.com/peass-ng/PEASS-ng/releases/download/20250202-a3a1123d/winPEASx64.exe
cd "$toolsdir/tools"

#Linenum 
git clone https://github.com/rebootuser/LinEnum.git

#dnscan
git clone https://github.com/rbsec/dnscan.git
pip3 install -r "$toolsdir/tools/dnscan/requirements.txt"

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
wget https://github.com/lkarlslund/ldapnomnom/releases/download/v1.5.1/ldapnomnom-linux-x64
cd "$toolsdir/tools"

#sharphound3
mkdir sharphound
cd sharphound
wget https://github.com/SpecterOps/SharpHound/releases/download/v2.5.13/SharpHound-v2.5.13.zip
wget https://github.com/SpecterOps/AzureHound/releases/download/v2.2.1/azurehound-windows-amd64.zip
wget https://github.com/SpecterOps/AzureHound/releases/download/v2.2.1/azurehound-linux-amd64.zip
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
mkdir coercer
cd coercer
virtualenv venv
source venv/bin/activate
pip3 install coercer
deactivate
cd "$toolsdir/tools"

#certipy-ad
mkdir certipyad
cd certipyad
virtualenv venv
source venv/bin/activate
pip3 install certipy-ad
deactivate

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
