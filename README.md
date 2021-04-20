# 简介

制作vsftpd4的Docker镜像
支持最多3个ftp用户
喜欢的请点Star。也可以联系我```guoofei@outlook.com```

# 制作镜像

```sh
docker build -t guofei/vsftpd:v1
```

# 启动示例

```sh
curIP="192.168.191.128"     #本机ip
ftpDir="/root/vsftpd" && mkdir -p $ftpDir       #ftp目录
logDir="/root/log_vsftpd" && mkdir -p $logDir  #日志目录
docker run -d \
    -v $ftpDir:/home/vsftpd \
    -v $logDir:/var/log/vsftpd/ \
    -e LOG_STDOUT=1 \
    -e LISTEN_PORT=3100 \
    -e FTP_USER1="user1" -e FTP_PASS1="passwd1" \
    -e FTP_USER2="user2" -e FTP_PASS2="passwd2" \
    -e PASV_ADDRESS=$curIP \
    -e PASV_MIN_PORT=3000 -e PASV_MAX_PORT=3099 \
    -p 3100:3100 -p 3000-3099:3000-3099 \
    --name ftp1 \
    guofei/vsftpd:v1

```

环境变量
----

This image uses environment variables to allow the configuration of some parameters at run time:

* 变量名称：`LISTEN_PORT`
* 默认值：21
* 作用：指定ftp协议的控制端口

----

* 变量名称: `FTP_USER1`、`FTP_USER2`、`FTP_USER3`
* 默认值: 默认生成`FTP_USER1`用户，值为admin
* 说明：最多支持3个用户

----

* 变量名称: `FTP_PASS1`、`FTP_PASS2`、`FTP_PASS3`
* 默认值: `FTP_PASS1`的默认值是随机生成的，该密码可以在日志文件中看到。
* 说明：`FTP_PASS1`、`FTP_PASS2`、`FTP_PASS3`分别是`FTP_USER1`、`FTP_USER2`、`FTP_USER3`的密码

----

* Variable name: `PASV_ADDRESS`
* Default value: Docker host IP / Hostname.
* Accepted values: Any IPv4 address or Hostname (see PASV_ADDRESS_RESOLVE).
* Description: If you don't specify an IP address to be used in passive mode, the routed IP address of the Docker host will be used. Bear in mind that this could be a local address.

----

* Variable name: `PASV_ADDR_RESOLVE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the PASV_ADDRESS option.

----

* Variable name: `PASV_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to disallow the PASV method of obtaining a data connection.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: `XFERLOG_STD_FORMAT`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want the transfer log file to be written in standard xferlog format.

----

* Variable name: `LOG_STDOUT`
* Default value: Empty string.
* Accepted values: Any string to enable, empty string or not defined to disable.
* Description: Output vsftpd log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/engine/reference/commandline/container_logs).

----

* Variable name: `FILE_OPEN_MODE`
* Default value: 0666
* Accepted values: File system permissions.
* Description: The permissions with which uploaded files are created. Umasks are applied on top of this value. You may wish to change to 0777 if you want uploaded files to be executable.

----

* Variable name: `LOCAL_UMASK`
* Default value: 077
* Accepted values: File system permissions.
* Description: The value that the umask for file creation is set to for local users. NOTE! If you want to specify octal values, remember the "0" prefix otherwise the value will be treated as a base 10 integer!

----

* Variable name: `REVERSE_LOOKUP_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to avoid performance issues where a name server doesn't respond to a reverse lookup.

----

* Variable name: `PASV_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PASV security check that ensures the data connection originates from the same IP address as the control connection. Only enable if you know what you are doing! The only legitimate use for this is in some form of secure tunnelling scheme, or perhaps to facilitate FXP support.

----
* Variable name: `PORT_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PORT security check that ensures that outgoing data connections can only connect to the client. Only enable if you know what you are doing! Legitimate use for this is to facilitate FXP support.

----

Exposed ports and volumes
----

The image exposes ports `20` and `21`. Also, exports two volumes: `/home/vsftpd`, which contains users home directories, and `/var/log/vsftpd`, used to store logs.

When sharing a homes directory between the host and the container (`/home/vsftpd`) the owner user id and group id should be 14 and 50 respectively. This corresponds to ftp user and ftp group on the container, but may match something else on the host.
