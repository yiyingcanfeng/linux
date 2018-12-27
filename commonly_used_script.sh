#!/bin/bash
hostnamectl set-hostname aaa 
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
setenforce 0
systemctl  stop firewalld
systemctl  disable  firewalld

#!/bin/bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache

yum install -y epel-release
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache

yum install -y bash-completion git wget vim yum-utils python34-pip screen lrzsz supervisor iotop ncdu pv htop net-tools sl iftop lynx links
#openjdk
yum install -y java-1.8.0-openjdk-devel.x86_64

#tomcat 
#https://tomcat.apache.org/download-90.cgi 注：请随时关注官网的最新版本，新版本发布后旧版本的链接会失效！
cd /usr
wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz
tar -zxvf apache-tomcat-9.0.14.tar.gz
touch /usr/lib/systemd/system/tomcat.service
cat > /usr/lib/systemd/system/tomcat.service <<- "EOF"
[Unit]  
Description=Tomcat9.0.14
After=syslog.target network.target remote-fs.target nss-lookup.target  
      
[Service]  
Type=forking
Environment='CATALINA_OPTS=-Xms128M -Xmx512M -server -XX:+UseParallelGC' 
WorkingDirectory=/usr/apache-tomcat-9.0.14

ExecStart=/usr/apache-tomcat-9.0.14/bin/startup.sh  
ExecReload=/bin/kill -s HUP $MAINPID  
ExecStop=/bin/kill -s QUIT $MAINPID  
PrivateTmp=true  
     
[Install]  
WantedBy=multi-user.target  

EOF
systemctl daemon-reload
systemctl start tomcat

#mysql  http://mirrors.tuna.tsinghua.edu.cn/mysql
touch /etc/yum.repos.d/mysql-community.repo
cat > /etc/yum.repos.d/mysql-community.repo <<- "EOF"
[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=http://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=http://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql57-community-el7
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql80-community]
name=MySQL 8.0 Community Server
baseurl=http://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql80-community-el7
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

EOF

yum install mysql-community-server
