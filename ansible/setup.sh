#!/bin/bash
#
# - check whether already done, if not
#   - allow password based ssh login by commenting out the appropriate line in /etc/ssh/sshd_config
#   - create a user 'ansible' with password 'ansible'
user=ansible
password=ansible
if [ -f /home/$user ]
then
  echo "$user's environment already created"
else
  sudo sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
  sudo service sshd restart
  useradd -m -s /bin/bash $user
  adduser $user sudo
  echo $user:$password | chpasswd
  mkdir /home/$user/.ssh
  chown $user.$user /home/$user/.ssh
  cp /vagrant/ansible/id_ecdsa* /home/$user/.ssh/
  # everything in the .ssh dir should only be accessible by the user
  chown $user.$user /home/$user/.ssh/*
  chmod 0600 /home/$user/.ssh/*
  echo "created $user's environment"
fi