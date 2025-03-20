# Specify the username for your new user account
username=ollie
# Specify that the user login shell will be zsh
user_shell=$(which zsh)
# Add any group where the kali user is a member
groups=$(grep -E '\:kali$' /etc/group | cut -d ':' -f 1 | sed -z 's/\n/,/g;s/,$/\n/')
# Create the new user account
sudo useradd -m -G $groups -s $user_shell $username
# Change the new user's password
sudo passwd $username

#Login as the other user and delete the kali user
userdel -r kali