#!/bin/bash
#
# - check whether already done, if not
#   - allow password based ssh login by commenting out the appropriate line in /etc/ssh/sshd_config
#   - create a user 'ansible' with password 'ansible'
USER=ansible
PASSWORD=ansible
if [ -d /home/$USER ]
then
  echo "$USER's environment already created"
else
  sudo sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
  sudo service sshd restart
  useradd -m -s /bin/bash $USER
  adduser $USER sudo
  echo $USER:$PASSWORD | chpasswd
  mkdir /home/$USER/.ssh
  chown $USER.$USER /home/$USER/.ssh
  cp /vagrant/ansible/id_ecdsa* /home/$USER/.ssh/
  # everything in the .ssh dir should only be accessible by the user
  chown $USER.$USER /home/$USER/.ssh/*
  chmod 0600 /home/$USER/.ssh/*
  echo "created $USER's environment"
fi