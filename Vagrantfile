# -*- mode: ruby -*-
# vi: set ft=ruby :

#######################################################################################
# This Vagrant file is to be used with VirtualBox only.
# Before using this Vagrant file: 
#  - Run a "ssh-keygen -q -t ecdsa -b 521 -C ansible -f ./ansible/id_ecdsa"
#    and do not enter a passphrase
#######################################################################################

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

# using debian buster as base image for all target vm's. 
# Can be changed globally here or individually within a specific vm's section
# For versions buster and below use debian/contrib-...64 with vboxfs kernel
# From bullsey on the modules are already included in debian/..64
BASE_IMAGE = "debian/contrib-buster64"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # globally disable an eventually existing vbguest plugin
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # --- The ansible server
  config.vm.define "ansible", primary: true, autostart: true do |ansible|
    ansible.vm.hostname = "ansible"
    # using ubuntu focal fossa as base allows simpler installation of ansible 
    ansible.vm.box = 'ubuntu/focal64'
    ansible.vm.network :private_network, ip: "192.168.60.3"
    # ensure to remove key from known hosts after destroy
    # so we won't have an issue with old key after rebuild
    ansible.trigger.after :destroy do |trigger|
      trigger.run = { inline: "ssh-keygen -R 192.168.60.3" }
    end
    ansible.vm.synced_folder ".", "/vagrant", create: true, disabled: false
    # Get ansible installed
    ansible.vm.provision "shell", inline: 'sudo apt-get install -y python3-software-properties'
    ansible.vm.provision "shell", inline: 'sudo apt-add-repository -y ppa:ansible/ansible'
    ansible.vm.provision "shell", inline: 'sudo apt-get install ansible -y'
    # create ansible admin user
    ansible.vm.provision "shell", path: './ansible/setup.sh'
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
