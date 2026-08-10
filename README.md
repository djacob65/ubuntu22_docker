## Purpose

Automating the creation of a virtual machine (VM) from a Vagrant box, including Docker software.

* based on [ubuntu 22.04 LTS](https://releases.ubuntu.com/jammy/)
* with the help of _Vagrant_ and _Ansible_ tools 
* for using with _VirtualBox_ or _OpenStack_.

The VM is generic enough to allow the installation of any application from a Docker image. Two examples are provided :
* NMRProcFlow : see the [rq1d](https://github.com/djacob65/ubuntu22_docker/tree/main/ansible/roles/rq1d) Ansible role and https://nmrprocflow.org/
* RnmrQuant1D UI : see the [npflow](https://github.com/djacob65/ubuntu22_docker/tree/main/ansible/roles/npflow) Ansible role and https://github.com/djacob65/RnmrQuant1D_UI 


For more details on the whole process, see https://inrae.github.io/jupyterhub-vm/

### Creation and configuration of a virtual machine

Requires [VirtualBox](https://www.virtualbox.org/), [Vagrant](https://www.vagrantup.com/) to be installed beforehand.

* **VirtualBox**: this is what we call the [provider](https://www.vagrantup.com/docs/providers). If the objective is to use the VM on his desktop computer, then the VM will have to run in _VirtualBox_. If the objective is to use the VM in the cloud (_OpenStack_ for example), then _VirtualBox_ is only used here as an intermediary to build the VM.

* **Vagrant** : allows building virtual machines from basic building blocks called [boxes](https://developer.hashicorp.com/vagrant/docs/boxes) for [Providers](https://www.vagrantup.com/docs/providers) by [provisioning](https://www.vagrantup.com/docs/provisioning) them by _Provisioners_ such as [Ansible](https://docs.ansible.com/ansible/latest/index.html).

* **Ansible** which is a powerfull tool allowing to describe tasks using [Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html), then turn tough tasks into repeatable playbooks. It is **not necessary to install Ansible** beforehand. It will be installed temporarily on the virtual machine to proceed the [provisionning](https://www.vagrantup.com/docs/provisioning). It will be removed at the end of the VM creation.


<br>

### 1 - Get the Vagrant box

* The box was built on the _ubuntu 22.04_ operating system, with a _20 GB_ hard drive, and for the _VirtualBox_ provider, and was generated as described in this [github repository](https://github.com/inrae/jupyterhub-vm) by following the two first steps.

* As Vagrant Cloud is set to be discontinued (March 2027), we have chosen to store the Vagrant box on Google Drive. You therefore need to download it and save it in the _./builds_ folder. Link to download the box : https://drive.google.com/file/d/1QM-BXuCwH_YFc20jgtNXMYVH4hsqs1DE/view?usp=drive_link

* But if you have python already install on your machine, then :

     1 - install the Google tool "_gdown_" — written in _Python_ — as follows:

     ```
     pip3 install gdown
     ```


     2 - run the following command yo retrieve the box

     ```
     gdown -O ./builds/small-ubuntu2204.box  1QM-BXuCwH_YFc20jgtNXMYVH4hsqs1DE
     ```


### 2 - Create the VM

* The tested version is _Vagrant 2.4.9_

* Based on :
   * Vagrant box : the box file _small-ubuntu2204.box_ must be now stored in the _builds_ folder as described in the previous step
   * [Vagrantfile](Vagrantfile) : describes the type of the machine and how to configure and provision it. 
   * [ansible](ansible/playbook.yml) : configures the installation of the VM and the packages, modules, etc.

* You must first install the plugin corresponding to the provider (_VirtualBox_) if not yet done

* You have also to create a new [_VirtualBox Host-Only Ethernet Adapter_](images/vbox_network.png)

```
vagrant plugin install virtualbox
```

* Then, you can now build the final VM

```
time vagrant up | tee logs/vagrant.log
```

* At this stage, you can use the final VM given that it is running on the provider (_VirtualBox_). So you can connect on it using ssh command (login=_vagrant_, password=_vagrant_):

```
ssh -p 2222 vagrant@127.0.0.1
```

* **Note** : If you wish, you can add one or more SSH keys to the _scripts/ssh_keys_ file, which will then be associated with the root account. This will allow you to log in directly as root. Very practical in development mode but to be avoided in production mode, given that the _vagrant_ account already has full rights with the sudo mechanism.

<br>

### 3 - Export the VM

* Export the VM as a TAR archive (_tar.gz_ format). It will included the VMDK VM file (_ubuntu2204-disk001.vmdk_)

```
time vagrant package --output ./builds/ubuntu2204-box.tar.gz | tee -a ./logs/vagrant.log

```
<br>

### 4 - Upload the VM on an OpenStack cloud

* First you must extract the VMDK file of the virtual machine (_ubuntu2204-disk001.vmdk_) from the TAR archive. Put it under the same directory (i.e. _./builds_)

* Upload the VMDK file on a OpenStack cloud, based on :
    * [OpenStackClient](https://docs.openstack.org/python-openstackclient/latest/) (OSC) which must be installed
    * [clouds.yaml](openstack/README.md) : definition file of the openstack cloud (e.g. [GenOuest](https://www.genouest.org/2017/03/02/cluster/))
    * [openstack/push_cloud.sh](openstack/README.md) : shell script that does the job

* Note : Depending on your network connection, this may take a long time (from 2 min. up to 30 min.).

```
time sh ./openstack/push_cloud.sh -c genostack | tee ./logs/genostack.log
```

* You will be asked for a password

```
Please enter your OpenStack password, then [Enter] :
```

* **Note** : You can go further and automate the creation of a functional instance on the cloud. See [more details](openstack/README.md)

<br>

### 5 - Do the housework on your local disk


* Stop the VM if not yet done

```
vagrant halt -f default
```

* Remove the final VM from the provider (_VirtualBox_)

```
vagrant destroy -f default
```

* Remove the current virtual environment

```
rm -rf ./.vagrant
```

* Delete the files corresponding to the base box and the final virtual machine (under ./builds)

```
rm -f ./builds/*
```

* Optionally remove the base box from the local vagrant registry 

```
rm -rf $HOME/.vagrant.d/boxes/small-ubuntu2204
```

<br>

### Acknowledgements

We would like to thank the [IFB GenOuest bioinformatics](https://www.genouest.org/2017/03/02/cluster/) for providing storage and computing resources on its national life science Cloud.

<br>

### Funded by:

* 2026 : INRAE UR BIA-BIBS, Biopolymères Interactions Assemblage, plate-forme BIBS

<br>

### License

Copyright (C) 2026  Daniel Jacob - INRAE

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
