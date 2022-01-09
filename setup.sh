#!/bin/sh
# Created by ByteProTips (www.byteprotips.com)
# Prep the system to run the Ansible playbook
# Tested on CentOS 7, RHEL 7, Oracle Linux 7, Rocky Linux 8, RHEL 8, Oracle Linux 8

# Determine the location of setup.sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Download mysql_secure_installation.py for Ansible playbook
curl https://raw.githubusercontent.com/eslam-gomaa/mysql_secure_installation_Ansible/master/library/mysql_secure_installation.py > $SCRIPT_DIR/library/mysql_secure_installation.py

redhat_release=`rpm -qf /etc/redhat-release` 2>/dev/null

#Prep CentOS 7
if grep -q -i "release 7" /etc/centos-release 2>/dev/null
then
	echo "Detected CentOS 7"
	yum install -y epel-release
	yum install -y ansible
fi

#Prep RHEL 7
if `grep -q -i "release 7" /etc/redhat-release` &&  `grep -q 'redhat' <<< $redhat_release`
then
	echo "Detected RHEL 7"
	subscription-manager repos --enable rhel-7-server-optional-rpms #
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
	yum install -y ansible
fi

#Prep Oracle Linux 7
if `grep -q -i "release 7" /etc/redhat-release` && `grep -q 'oraclelinux' <<< $redhat_release`
then
	echo "Detected Oracle Linux 7"
	yum-config-manager --enable ol7_optional_latest
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
	yum install -y ansible
fi

#Prep CentOS 8, Rocky 8, etc.
if grep -q -i "release 8" /etc/centos-release 2>/dev/null
then
	echo "Detected non Red Hat EL 8 variant (CentOS, Rocky, Oracle, etc)"
	dnf install -y epel-release
	dnf install -y ansible
fi

#Prep RHEL 8
if `grep -q -i "release 8" /etc/redhat-release` && `grep -q 'redhat' <<< $redhat_release`
then
	echo "Detected RHEL 8"
	subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
	dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
	dnf --enablerepo=epel --setopt=epel.module_hotfixes=true install -y libssh2 libssh2-devel
	dnf install -y ansible
fi

#Prep Oracle Linux 8
if `grep -q -i "release 8" /etc/redhat-release` && `grep -q 'oraclelinux' <<< $redhat_release`
then
	echo "Detected Oracle Linux 8"
	dnf config-manager --set-enabled ol8_codeready_builder # For Oracle Linux
	dnf install -y oracle-epel-release-el8
	dnf install -y ansible
fi

ansible-galaxy collection install community.mysql community.general ansible.posix

ansible-playbook playbook.yaml