# Ansible Development Environment

This repository contains an ansible development environment based on Vagrant and VirtualBox, inspired through the book [Ansible for DevOps](https://www.ansiblefordevops.com/) by [Jeff Geerling](https://www.jeffgeerling.com/).

This environment is still under construction but works on Windows machines.

On your workstation you need to download and install (if not already done)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads)
- An ssh environment like [OpenSSH](https://www.openssh.com/).<br>
[How to install OpenSSH on Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)

<br>
Before using this environment you need to generate a pair of ssh-keys for the user vagrant.
Therefore change into this environments root directory and run <br>
<code>C:\Users\...\ansible-dev-env> ssh-keygen -q -t ecdsa -b 521 -C ansible -f ./ansible/id_ecdsa</code>
<br>For simplicity do not enter a password.<br>
<br>
To start the ansible server run<br>
<code>C:\Users\...\ansible-dev-env> vagrant up</code>
or
<code>C:\Users\...\ansible-dev-env> vagrant up ansible</code>
<br>
To start the raspi-like server run<br>
<code>C:\Users\...\ansible-dev-env> vagrant up raspbian</code>
<br>
To start the armbian(debian)-like server run<br>
<code>C:\Users\...\ansible-dev-env> vagrant up armbian</code>
<br>
To start all of them run<br>
<code>C:\Users\...\ansible-dev-env> vagrant up ansible raspbian armbian</code>
<br>
You can log into the ansible server with 'ssh ansible@192.168.60.3', password is 'ansible'