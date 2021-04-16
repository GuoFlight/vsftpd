#!/bin/bash

# If no env var for FTP_USER has been specified, use 'admin':
if [ "$FTP_USER1" = "**String**" ]; then
    export FTP_USER1='admin'
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS1" = "**Random**" ]; then
    export FTP_PASS1=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
fi

# Do not log to STDOUT by default:
if [ "$LOG_STDOUT" = "**Boolean**" ]; then
    export LOG_STDOUT=''
else
    export LOG_STDOUT='Yes.'
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER1}"
chown -R ftp:ftp /home/vsftpd/
echo -e "${FTP_USER1}\n${FTP_PASS1}" > /etc/vsftpd/virtual_users.txt

if [ "$FTP_USER2" != "**String**" ]; then
    mkdir -p "/home/vsftpd/${FTP_USER2}"
    chown -R ftp:ftp /home/vsftpd/
    echo -e "${FTP_USER2}\n${FTP_PASS2}" >> /etc/vsftpd/virtual_users.txt
fi
if [ "$FTP_USER3" != "**String**" ]; then
    mkdir -p "/home/vsftpd/${FTP_USER3}"
    chown -R ftp:ftp /home/vsftpd/
    echo -e "${FTP_USER3}\n${FTP_PASS3}" >> /etc/vsftpd/virtual_users.txt
fi

/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

if [ ${LISTEN_PORT} != 21 ];then
    echo "listen_port=${LISTEN_PORT}" >> /etc/vsftpd/vsftpd.conf
fi 
echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf
echo "xferlog_std_format=${XFERLOG_STD_FORMAT}" >> /etc/vsftpd/vsftpd.conf
echo "reverse_lookup_enable=${REVERSE_LOOKUP_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_promiscuous=${PASV_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf
echo "port_promiscuous=${PORT_PROMISCUOUS}" >> /etc/vsftpd/vsftpd.conf

# Get log file path
export LOG_FILE=`grep xferlog_file /etc/vsftpd/vsftpd.conf|cut -d= -f2`

# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
	*************************************************
	*                                               *
	*    Docker image: fauria/vsftpd                *
	*    https://github.com/fauria/docker-vsftpd    *
	*                                               *
	*************************************************
	SERVER SETTINGS
	---------------
	· FTP User1: $FTP_USER1
	· FTP Password(User1): $FTP_PASS1
	· Log file: $LOG_FILE
	· Redirect vsftpd log to STDOUT: No.
EOB
else
    /usr/bin/ln -sf /dev/stdout $LOG_FILE
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
