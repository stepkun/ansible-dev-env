# -*- mode: ruby -*-
# vi: set ft=ruby :

#################################################################################
# This Vagrant file is to be used with VirtualBox only.
# Before using this Vagrant file: 
#  - Do a "vagrant plugin install vagrant-vbguest"
#  - run a "ssh-keygen -q -t ecdsa -b 521 -C vagrant -f ./keys/vagrant"
#    and do not enter a passphrase
#################################################################################

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

# This is a variable containing an installation script used on guest side to
#   - check whether already done, if not
#     - create a user 'pi' with password 'raspberry'
#     - allow password based ssh login by commenting out the appropriate line in /etc/ssh/sshd_config
$create_pi = <<-SCRIPT
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


VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  if Vagrant.has_plugin?("vagrant-vbguest")
    # Update Guest Additions in VirtualBox
    #   - Set auto_update to false for a maachine, if you do NOT want to check the correct 
    #     VirtualBox Guest Additions version when booting a machine
    config.vbguest.auto_update = true
    #   - Do NOT download the iso file from a webserver, use the local one
    config.vbguest.no_remote = true
  end

  # --- The ansible server
  config.vm.define "ansible", primary: true, autostart: true do |ansible|
    ansible.vm.hostname = "ansible"
    ansible.vm.box = "ubuntu/focal64"
    ansible.vm.network :private_network, ip: "192.168.60.3"
    # remove key from known hosts after destroy
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
    raspbian.vm.box = "debian/bullseye64"
    raspbian.vm.network :private_network, ip: "192.168.60.4"
    # remove key from known hosts after destroy
    raspbian.trigger.after :destroy do |trigger|
      trigger.run = { inline: "ssh-keygen -R 192.168.60.4" }
    end
    if Vagrant.has_plugin?("vagrant-vbguest")
      raspbian.vbguest.auto_update = false
    end
    # create raspbian default user "pi" with password "raspberry"
    raspbian.vm.provision "shell", inline: $create_pi
  end
end
