#!/bin/sh -
#Author: Rafael Lopes
#About: This tiny script installs Zabbix Agent for CentOS hosts
VERSION=1.0

flagFail=0
function chEC(){
	if [ $1 == 0 ]; then
		echo -e "\033[32mOk!\033[0m"
	else
		echo -e "\033[33mWarning at this step!\033[0m"
		flagFail=1
	fi
}
function copyBinaries(){
	echo "Copying binaries..."
	cp -fv bin/* /usr/local/bin/
	chEC $?
	cp -fv sbin/* /usr/local/sbin/
	chEC $?
}
function createConfigDir(){
	echo "Creating configuration directory..."
	mkdir -p /usr/local/etc/
	chEC $?
}
function addServices(){
	echo "Adding services do CentOS Services..."
	echo 'zabbix_agent 10050/tcp' >> /etc/services
	echo 'zabbix_trap 10051/tcp' >> /etc/services
	chEC $?
}
function copyConfigFiles(){
	echo "Copying configuration files..."
	cp -fv extra_files/zabbix_agent*.conf /usr/local/etc/
	chEC $?
}
function createZabbixUser(){
	echo "Adding Zabbix User..."
	useradd zabbix
	chEC $?
	echo "Adding Zabbix Group..."
	groupadd zabbix
	chEC $?
}
function createLogFile(){
	echo "Creating empty log file..."
	touch /var/log/zabbix_agentd.log
	chEC $?
	echo "Assigning correct permissions to log file..."
	chown zabbix:zabbix /var/log/zabbix_agentd.log
	chEC $?
}
function copyInitFiles(){
	echo "Copying init.d files..."
	cp -fv extra_files/zabbix_agentd /etc/init.d/zabbix_agentd
	chEC $?
	echo "Chmoding +x zabbix_agentd..."
	chmod +x /etc/init.d/zabbix_agentd
	chEC $?
}
function enableAgentOnBoot(){
	echo "Enabling zabbix_agentd on boot..."
	chkconfig zabbix_agentd on
	chEC $?
}
function startAgent(){
	echo "Starting Zabbix Agent..."
	service zabbix_agentd start
	chEC $?
}
function showMsg(){
	if [ $flagFail == "0" ];then
		echo -e "\033[32mSetup done! You can now monitor this host using Zabbix\033[0m"
	else
		echo -e "\033[31mYou got some warnings, please check...\033[0m"
	fi
}
function main(){
	copyBinaries
	createConfigDir
	addServices
	copyConfigFiles
	createZabbixUser
	createLogFile
	copyInitFiles
	enableAgentOnBoot
	startAgent
	showMsg
}	

main $1
