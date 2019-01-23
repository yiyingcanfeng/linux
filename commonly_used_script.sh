#!/bin/bash
# curl http://example.com/common-config.sh | bash

# 修改主机名
#hostnamectl set-hostname aaa
# 禁用selinux
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
# 修改开机引导等待时间
sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
# 请根据具体情况来决定是否关闭防火墙
systemctl  stop firewalld
systemctl  disable  firewalld

#更换基础yum源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache

#更换EPEL yum源
#EPEL (Extra Packages for Enterprise Linux) 是由 Fedora Special Interest Group 为企业 Linux 创建、维护和管理的一个高质量附加包集合，适用于但不仅限于 Red Hat Enterprise Linux (RHEL), CentOS, Scientific Linux (SL), Oracle Linux (OL)
yum install -y epel-release
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

#配置ius源
#IUS只为RHEL和CentOS这两个发行版提供较新版本的rpm包。如果在os或epel找不到某个软件的新版rpm，软件官方又只提供源代码包的时候，可以来ius源中找，几乎都能找到。比如，python3.6(包括对应版本的pip，epel源里有python3.6但没有对应版本的pip),php7.2,redis5等等
cat > /etc/yum.repos.d/ius.repo <<- "EOF"
[ius]
name=ius
baseurl=https://mirrors.aliyun.com/ius/stable/CentOS/7/$basearch
gpgcheck=0
enable=1

EOF
yum makecache
yum update -y


#一些实用工具,这些大部分在EPEL源里
yum install -y bash-completion git wget vim nano yum-utils unar screen lrzsz supervisor iotop iftop jnettop mytop apachetop atop htop ncdu nmap pv net-tools sl lynx links crudini the_silver_searcher tig cloc nload w3m axel tmux mc glances multitail
# python3.6,包括对应版本的pip,php72
yum install python36u-pip php72u redis5 -y
# 使用国内pypi源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<- "EOF"
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com

EOF
# 一些基于python的实用或者有意思的工具
pip3.6 install mycli icdiff you-get lolcat youtube-dl

#配置nodejs10的yum源，安装 nodejs 10(epel源里有nodejs，但版本比较老)
yum install https://mirrors.tuna.tsinghua.edu.cn/nodesource/rpm_10.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm -y
cat > /etc/yum.repos.d/nodesource-el7.repo <<- "EOF"
[nodesource]
name=Node.js Packages for Enterprise Linux 7 - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/nodesource/rpm_10.x/el/7/$basearch
enabled=1
gpgcheck=0

[nodesource-source]
name=Node.js for Enterprise Linux 7 - $basearch - Source
baseurl=https://mirrors.tuna.tsinghua.edu.cn/nodesource/rpm_10.x/el/7/SRPMS
enabled=0
gpgcheck=1

EOF
yum makecache
yum install nodejs -y
# 更换国内npm源
npm config set registry https://mirrors.huaweicloud.com/repository/npm/
npm cache clean -f
# 一些基于nodejs的实用或者有意思的工具
npm install --global get-port-cli hasha-cli http-server

# 2048游戏的shell实现
curl https://raw.githubusercontent.com/mydzor/bash2048/master/bash2048.sh -o 2048.sh && chmod 755 2048.sh
# 扫雷游戏的shell实现
curl https://raw.githubusercontent.com/feherke/Bash-script/master/minesweeper/minesweeper.sh -o minesweeper.sh && chmod 755 minesweeper.sh
# 命令行下的俄罗斯方块游戏
git clone https://github.com/uuner/sedtris.git
chmod 755 sedtris/*
# ./sedtris/sedtris.sh
#安装openjdk
yum install java-1.8.0-openjdk-devel.x86_64 -y

#或者 oraclejdk
# wget https://mirrors.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz
# tar -zxvf jdk-8u202-linux-x64.tar.gz -C /usr/
# cat >> /etc/profile <<- "EOF"
# export JAVA_HOME=/usr/jdk1.8.0_202
# export PATH=$JAVA_HOME/bin:$PATH
# export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

# EOF
# source /etc/profile

#安装tomcat 
#https://tomcat.apache.org/download-90.cgi 注：请随时关注官网的最新版本，新版本发布后旧版本的链接会失效！
cd /usr
wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v9.0.14/bin/apache-tomcat-9.0.14.tar.gz
tar -zxf apache-tomcat-9.0.14.tar.gz
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

#安装mysql5.7 http://mirrors.tuna.tsinghua.edu.cn/mysql
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

yum install mysql-community-server -y
#mysql配置
MYSQL_PASSWORD=1111 #root用户密码
systemctl start mysqld
systemctl enable mysqld
passlog=$(grep 'temporary password'  /var/log/mysqld.log)
pass=${passlog:${#passlog}-12:${#passlog}}
mysql -uroot -p"${pass}" -e"alter user root@localhost identified by 'QQQqqq111...' " --connect-expired-password
pass=QQQqqq111...
mysql -uroot -p"${pass}" -e"set global validate_password_policy=0;" --connect-expired-password
mysql -uroot -p"${pass}" -e"set global validate_password_length=4;" --connect-expired-password
mysql -uroot -p"${pass}" -e"set global validate_password_mixed_case_count=0;" --connect-expired-password
mysql -uroot -p"${pass}" -e"set global validate_password_number_count=0;" --connect-expired-password
#echo 'enter your mysql password'
#read password
mysql -uroot -p"${pass}" -e"set password=password('${MYSQL_PASSWORD}');" --connect-expired-password
mysql -uroot -p"${MYSQL_PASSWORD}" -e"update mysql.user set host='%' where user='root';" --connect-expired-password
mysql -uroot -p"${MYSQL_PASSWORD}" -e"flush privileges;" --connect-expired-password

#安装mongodb
echo "" > /etc/yum.repos.d/mongodb.repo
for version in "3.0" "3.2" "3.4" "3.6" "4.0"; do
cat >> /etc/yum.repos.d/mongodb.repo <<- EOF
[mongodb-org-$version]
name=MongoDB Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mongodb/yum/el7-$version/
gpgcheck=0
enabled=1

EOF
done
yum makecache
yum install mongodb-org -y

#安装docker
cat > /etc/yum.repos.d/docker-ce.repo <<- "EOF"
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/debug-$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/source/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-edge]
name=Docker CE Edge - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/$basearch/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-edge-debuginfo]
name=Docker CE Edge - Debuginfo $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/debug-$basearch/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-edge-source]
name=Docker CE Edge - Sources
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/source/edge
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-test-debuginfo]
name=Docker CE Test - Debuginfo $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/debug-$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/source/test
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-nightly]
name=Docker CE Nightly - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-nightly-debuginfo]
name=Docker CE Nightly - Debuginfo $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/debug-$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

[docker-ce-nightly-source]
name=Docker CE Nightly - Sources
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/source/nightly
enabled=0
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg

EOF
yum install docker-ce -y
systemctl start docker
#配置国内docker加速器
cat >  /etc/docker/daemon.json <<- "EOF"
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
systemctl restart docker
