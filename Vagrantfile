# -*- mode: ruby -*-
# vi: set ft=ruby :

#######################################################################################
# This Vagrant file is to be used with VirtualBox only.
# Before using this Vagrant file: 
#  - Run a "ssh-keygen -q -t ecdsa -b 521 -C vagrant -f ./keys/vagrant"
#    and do not enter a passphrase
#######################################################################################

# This is a variable containing an installation script used on guest side to
#   - check whether already done, if not
#     - create a backup of authorized_keys
#     - add the necessary public_keys to the authorized_keys
$add_public_keys = <<-SCRIPT
pub_key=/vagrant/keys/vagrant.pub
original=/home/vagrant/.ssh/authorized_keys
backup=/home/vagrant/.ssh/authorized_keys_backup
if [ -f $backup ]
then
  echo "appending public_keys was already done"
else
  cp $original $backup
  chown vagrant.vagrant $backup
  cat $pub_key >> $original
  echo "appending public_keys is done"
fi
SCRIPT

# This is a variable containing an installation script to setup
# the guest in an raspbian lite like fashion
#   - check whether already done, if not
#     - allow password based ssh login by commenting out the appropriate line in /etc/ssh/sshd_config
#     - create a user 'pi' with password 'raspberry'
$setup_raspbian = <<-SCRIPT
if [ -f /home/pi ]
then
  echo "pi environment already created"
else
  sudo sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
  sudo service sshd restart
  useradd -m -s /bin/bash pi
  echo 'pi:raspberry' | chpasswd
  echo "created pi environment"
fi
SCRIPT

# This is a variable containing an installation script to setup
# the guest in an armbian lite like fashion
#   - allow password based ssh login by commenting out the appropriate line in /etc/ssh/sshd_config
#   - allow root login with password by changing the appropriate line in /etc/ssh/sshd_config
#   - set root's password '1234' and force to change it at next login
# TODO: - enforce creation of a user for daily work
$setup_armbian = <<-SCRIPT
sudo sed -i 's/PasswordAuthentication/#PasswordAuthentication/g' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo service sshd restart
echo 'root:1234' | chpasswd
chage -d 0 root
echo "created environment"
SCRIPT

# using debian buster as base image for all vm's. 
# Can be changed globally here or individually within a specific vm's section
# For versions buster and below use debian/contrib-...64 with vboxfs kernel
# From bullsey on the modules are already included in debian/..64
BASE_IMAGE = "debian/contrib-buster64"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if Vagrant.has_plugin?("vagrant-vbguest")
    # globally disable an eventually existing vbguest plugin
    config.vbguest.auto_update = false
  end

  # --- The ansible server
  config.vm.define "ansible", primary: true, autostart: true do |ansible|
    ansible.vm.hostname = "ansible"
    ansible.vm.box = BASE_IMAGE
    ansible.vm.network :private_network, ip: "192.168.60.3"
    # ensure to remove key from known hosts after destroy
    # so we won't have an issue with old key after rebuild
    ansible.trigger.after :destroy do |trigger|
      trigger.run = { inline: "ssh-keygen -R 192.168.60.3" }
    end
    ansible.vm.synced_folder ".", "/vagrant", create: true, disabled: false
    # provide the private ssh key on that server
    ansible.vm.provision "file", source: "./keys/vagrant", destination: "/home/vagrant/.ssh/id_rsa"
    ansible.vm.provision "shell", inline: "chmod 0600 /home/vagrant/.ssh/id_rsa"
    # add public ssh keys to authorized_hosts
    ansible.vm.provision "shell", inline: $add_public_keys
    # Get ansible installed on this box and do automatic provisioning of this box only
    # No automatic provisioning of any of the other boxes from here!
    ansible.vm.provision "ansible", type: "ansible_local" do |provisioner|
      #provisioner.verbose = 'vvv'
      provisioner.install = true
      provisioner.playbook = "playbook.yml"
      # explicitly setting these two variables allows to use those files also they are in "public" directories
      provisioner.config_file = "/vagrant/ansible.cfg"
      provisioner.inventory_path = "/vagrant/hosts.ini"
      # ensure that only the ansible server is provisioned
      provisioner.limit = "ansible"
    end
  end

  # --- A raspbian-lite like target, not automatically started
  config.vm.define "raspbian", autostart: false do |raspbian|
    raspbian.vm.hostname = "raspbian"
    raspbian.vm.box = BASE_IMAGE
    raspbian.vm.network :private_network, ip: "192.168.60.4"
    # ensure to remove key from known hosts after destroy
    # so we won't have an issue with old key after rebuild
    raspbian.trigger.after :destroy do |trigger|
      trigger.run = { inline: "ssh-keygen -R 192.168.60.4" }
    end
    # setup in raspbian style
    raspbian.vm.provision "shell", inline: $setup_raspbian
  end

  # --- An armbian-lite like target, not automatically started
  config.vm.define "armbian", autostart: false do |armbian|
    armbian.vm.hostname = "armbian"
    armbian.vm.box = BASE_IMAGE
    armbian.vm.network :private_network, ip: "192.168.60.5"
    # ensure to remove key from known hosts after destroy
    # so we won't have an issue with old key after rebuild
    armbian.trigger.after :destroy do |trigger|
      trigger.run = { inline: "ssh-keygen -R 192.168.60.5" }
    end
    # setup in armbian style
    armbian.vm.provision "shell", inline: $setup_armbian
  end
end
