#!/bin/bash
# curl https://yiycf.com/centos-init.sh | bash
# 可选参数base kernel python php nodejs cmd_game jdk mysql57 mysql8 mongodb docker
# 比如
# curl https://yiycf.com/centos-init.sh | bash -s base
# curl https://yiycf.com/centos-init.sh | bash -s python php nodejs cmd_game jdk mysql8 mongodb docker

function system_config() {
    # 修改主机名
    #hostnamectl set-hostname aaa
    # 禁用selinux
    sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
    setenforce 0
    # 修改开机引导等待时间
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/g' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    # 请根据具体情况来决定是否关闭防火墙
    systemctl stop firewalld
    systemctl disable  firewalld
}

function config_mirror_and_update() {
    MIRROR="https://mirrors.huaweicloud.com"
    #更换yum源
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    #curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    sed -i "s@#baseurl@baseurl@g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s@mirrorlist=http@#mirrorlist=http@g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i "s@baseurl=.*/centos@baseurl=$MIRROR/centos@g" /etc/yum.repos.d/CentOS-Base.repo
    yum makecache

    #同步时间
    yum install -y ntpdate
    ntpdate time.windows.com

    #配置EPEL源
    #EPEL (Extra Packages for Enterprise Linux) 是由 Fedora Special Interest Group 为企业 Linux 创建、维护和管理的一个高质量附加包集合，适用于但不仅限于 Red Hat Enterprise Linux (RHEL), CentOS, Scientific Linux (SL), Oracle Linux (OL)
    yum install -y epel-release
    cp /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
    mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
    # curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    sed -i "s@#baseurl@baseurl@g" /etc/yum.repos.d/epel.repo
    sed -i "s@metalink@#metalink@g" /etc/yum.repos.d/epel.repo
    sed -i "s@baseurl.*=.*/epel@baseurl=$MIRROR/epel@g" /etc/yum.repos.d/epel.repo

#配置ius源  https://ius.io/
#IUS只为RHEL和CentOS这两个发行版提供较新版本的rpm包。如果在os或epel找不到某个软件的新版rpm，软件官方又只提供源代码包的时候，可以来ius源中找，几乎都能找到。比如，python3.6(包括对应版本的pip，epel源里有python3.6但没有对应版本的pip),php7.2,redis5等等
# https://mirrors.aliyun.com  https://mirrors.tuna.tsinghua.edu.cn
    IUS_MIRROR=https://mirrors.aliyun.com/ius
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    sed -i "s@baseurl.*=.*/7@baseurl=$IUS_MIRROR/7@g" /etc/yum.repos.d/ius.repo
    yum makecache
    yum update -y
#一些实用工具,这些大部分在EPEL源里
    yum install -y bash-completion git2u wget hdparm tree zip unzip vim emacs nano yum-utils unar screen lrzsz supervisor iotop iftop jnettop apachetop atop htop ncdu nmap pv net-tools sl lynx links crudini the_silver_searcher tig cloc nload w3m axel tmux mc glances multitail redis5 lftp vsftpd
    cat >> ~/.bashrc  <<- "EOF"
alias top='top -c'
alias historygrep='history|grep $1'
alias port='netstat -apn|grep $1'
alias iftop='iftop -B'
EOF
    source ~/.bashrc
}

# 更新内核为主分支ml(mainline)版本
function update_kernel() {
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
    sed -i "s/mirrorlist=http/#mirrorlist=http/g" /etc/yum.repos.d/elrepo.repo
    crudini --set /etc/yum.repos.d/elrepo.repo elrepo baseurl "https://mirrors.tuna.tsinghua.edu.cn/elrepo/elrepo/el7/\$basearch"
    crudini --set /etc/yum.repos.d/elrepo.repo elrepo-testing baseurl "https://mirrors.tuna.tsinghua.edu.cn/elrepo/testing/el7/\$basearch"
    crudini --set /etc/yum.repos.d/elrepo.repo elrepo-kernel baseurl "https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/\$basearch/"
    crudini --set /etc/yum.repos.d/elrepo.repo elrepo-extras baseurl "https://mirrors.tuna.tsinghua.edu.cn/elrepo/extras/el7/\$basearch/"
    yum-config-manager --enable elrepo-kernel
    yum install kernel-ml-devel kernel-ml -y
    KERNEL_VERSION=$(yum list kernel-ml | grep kernel.*@elrepo-kernel |  awk -F ' ' '{print $2}')
    GRUB_ITEM=$(awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg | grep ${KERNEL_VERSION})
    grub2-set-default '${GRUB_ITEM}'
    echo '请重启后执行uname -r查看是否生效'
}

function install_python() {
    # python3.6,包括对应版本的pip
    yum install python36u-pip -y
    # 使用国内pypi源,使用阿里云的源
    # 备选：http://pypi.douban.com/simple/  https://pypi.tuna.tsinghua.edu.cn/simple/  https://mirrors.aliyun.com/pypi/simple/
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf <<- "EOF"
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com

EOF
    pip3.6 install --upgrade pip
    # 一些基于python的实用或者有意思的工具
    pip3.6 install cheat mycli icdiff you-get lolcat youtube-dl speedtest-cli supervisor gixy

}

function install_php() {
    yum install php72u* nginx -y
    systemctl start php-fpm.service
    systemctl enable php-fpm.service
}

function install_nodejs_and_config() {
#配置nodejs的yum源，安装 nodejs (epel源里有nodejs，但版本比较老),使用清华大学的源
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
    # 备选：npm config set registry https://mirrors.huaweicloud.com/repository/npm/
    # npm config set registry https://registry.npm.taobao.org/
    npm cache clean -f
    # 一些基于nodejs的实用或者有意思的工具
    npm install n npm get-port-cli hasha-cli http-server live-server -g

}

#命令行小游戏
function install_cmd_game() {
    # 2048
    curl https://raw.githubusercontent.com/mydzor/bash2048/master/bash2048.sh -o 2048.sh && chmod 755 2048.sh
    # 扫雷
    curl https://raw.githubusercontent.com/feherke/Bash-script/master/minesweeper/minesweeper.sh -o minesweeper.sh && chmod 755 minesweeper.sh
    # 俄罗斯方块
    git clone https://github.com/uuner/sedtris.git
    chmod 755 sedtris/*
    # ./sedtris/sedtris.sh
}

#安装jdk和tomcat
function install_jdk_and_tomcat() {
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

#安装tomcat9
#https://tomcat.apache.org/download-90.cgi 注：请随时关注官网的最新版本，新版本发布后旧版本的链接会失效！
    cd /usr
    TOMCAT_VERSION=$(lftp https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/ -e "cls;bye" | awk -F '/' '{print $1}' | awk -F 'v' '{print $2}' | xargs | awk -F ' ' '{print $2}')
    if [[ -z ${TOMCAT_VERSION} ]]; then
        TOMCAT_VERSION=$(lftp https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/ -e "cls;bye" | awk -F '/' '{print $1}' | awk -F 'v' '{print $2}' | xargs | awk -F ' ' '{print $1}')
    fi

    wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
    tar -zxf apache-tomcat-${TOMCAT_VERSION}.tar.gz
    cat > /usr/lib/systemd/system/tomcat.service <<- "EOF"
[Unit]
Description=Tomcat-9.0.17
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
Environment='CATALINA_OPTS=-Xms128M -Xmx512M -server -XX:+UseParallelGC'
WorkingDirectory=/usr/apache-tomcat-9.0.17

ExecStart=/usr/apache-tomcat-9.0.17/bin/startup.sh
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF
    sed -i "s:Description=Tomcat-.*:Description=Tomcat-${TOMCAT_VERSION}:g" /usr/lib/systemd/system/tomcat.service
    sed -i "s:WorkingDirectory=/usr/apache-tomcat-.*:WorkingDirectory=/usr/apache-tomcat-${TOMCAT_VERSION}:g" /usr/lib/systemd/system/tomcat.service
    sed -i "s:ExecStart=/usr/apache-tomcat-.*:ExecStart=/usr/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh:g" /usr/lib/systemd/system/tomcat.service
    systemctl daemon-reload
    systemctl start tomcat
    #安装maven
    MAVEN_VERSION=$(lftp https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/ -e "cls;bye" | sort -rV | xargs | awk -F ' ' '{print $1}' | awk -F '/' '{print $1}')
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz
    cat >> /etc/profile <<- "EOF"
export M2_HOME=/usr/apache-maven-3.6
export PATH=$M2_HOME/bin:$PATH
EOF
    sed -i "s:M2_HOME=.*:M2_HOME=/usr/apache-maven-${MAVEN_VERSION}:g" /etc/profile
    source /etc/profile
    mvn
    mkdir -p ~/.m2
    # 创建maven配置文件，并配置阿里云的maven源
    cat > ~/.m2/settings.xml <<- "EOF"
<?xml version="1.0" encoding="UTF-8"?>
<settings
    xmlns="http://maven.apache.org/SETTINGS/1.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <pluginGroups></pluginGroups>
    <proxies></proxies>
    <servers></servers>
    <mirrors>
        <mirror>
            <id>alimaven</id>
            <name>aliyun maven</name>
            <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
    <profiles></profiles>
</settings>
EOF

}

#安装mysql5.7 http://mirrors.tuna.tsinghua.edu.cn/mysql,使用清华大学的源
function install_mysql57_and_config() {
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
    if [[ "${MYSQL_PASSWORD}" == "" ]];then
    #root用户密码
    MYSQL_PASSWORD=1111
    fi
    systemctl start mysqld
    systemctl enable mysqld
    passlog=$(grep 'temporary password'  /var/log/mysqld.log)
    pass=${passlog:${#passlog}-12:${#passlog}}
    mysql -uroot -p"${pass}" -e"alter user root@localhost identified by 'QQQqqq111...' " --connect-expired-password
    pass=QQQqqq111...
    mysql -uroot -p"${pass}" -e"set global validate_password_policy=0;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password.policy=0;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password_length=4;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password.length=4;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password_mixed_case_count=0;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password.mixed_case_count=0;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password_number_count=0;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password.number_count=0;" --connect-expired-password
    echo 'enter your mysql password'
    #read password
#    mysql -uroot -p"${pass}" -e"set password=password('${MYSQL_PASSWORD}');" --connect-expired-password
    mysql -uroot -p"${pass}" -e"alter user 'root'@'localhost' identified with mysql_native_password by '${MYSQL_PASSWORD}';" --connect-expired-password
    mysql -uroot -p"${MYSQL_PASSWORD}" -e"update mysql.user set host='%' where user='root';" --connect-expired-password
    mysql -uroot -p"${MYSQL_PASSWORD}" -e"flush privileges;" --connect-expired-password

}

#安装mysql8 http://mirrors.tuna.tsinghua.edu.cn/mysql,使用清华大学的源
function install_mysql8_and_config() {
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
enabled=0
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

[mysql80-community]
name=MySQL 8.0 Community Server
baseurl=http://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql80-community-el7
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql

EOF

    yum install mysql-community-server -y
    #mysql配置
    if [[ "${MYSQL_PASSWORD}" == "" ]];then
    #root用户密码
    MYSQL_PASSWORD=1111
    fi
    systemctl start mysqld
    systemctl enable mysqld
    passlog=$(grep 'temporary password'  /var/log/mysqld.log)
    pass=${passlog:${#passlog}-12:${#passlog}}
    mysql -uroot -p"${pass}" -e"alter user root@localhost identified by 'QQQqqq111...' " --connect-expired-password
    pass=QQQqqq111...
    #mysql -uroot -p"${pass}" -e"set global validate_password_policy=0;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password.policy=0;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password_length=4;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password.length=4;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password_mixed_case_count=0;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password.mixed_case_count=0;" --connect-expired-password
#    mysql -uroot -p"${pass}" -e"set global validate_password_number_count=0;" --connect-expired-password
    mysql -uroot -p"${pass}" -e"set global validate_password.number_count=0;" --connect-expired-password
    #echo 'enter your mysql password'
    #read password
#    mysql -uroot -p"${pass}" -e"set password=password('${MYSQL_PASSWORD}');" --connect-expired-password
    mysql -uroot -p"${pass}" -e"alter user 'root'@'localhost' identified with mysql_native_password by '${MYSQL_PASSWORD}';" --connect-expired-password
    mysql -uroot -p"${MYSQL_PASSWORD}" -e"update mysql.user set host='%' where user='root';" --connect-expired-password
    mysql -uroot -p"${MYSQL_PASSWORD}" -e"flush privileges;" --connect-expired-password

}

#安装mongodb,使用阿里云的源
function install_mongodb() {
    echo "" > /etc/yum.repos.d/mongodb.repo
    for version in "3.6" "3.7" "4.0" "4.1"; do
    cat >> /etc/yum.repos.d/mongodb.repo <<- EOF
[mongodb-org-$version]
name=MongoDB Repository
baseurl=https://mirrors.aliyun.com/mongodb/yum/redhat/7/mongodb-org/$version/x86_64
gpgcheck=0
enabled=1

EOF
    done
    yum makecache
    yum install mongodb-org -y

}

#安装docker
function install_docker() {
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sed -i "s@https://download.docker.com@https://mirrors.aliyun.com/docker-ce@g"  /etc/yum.repos.d/docker-ce.repo
    yum install docker-ce -y
    systemctl start docker
#配置国内docker加速器
cat > /etc/docker/daemon.json <<- "EOF"
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
    systemctl restart docker
}

# 如果不指定参数，则执行所有功能模块
if [[ -z $* ]]; then
    echo "脚本执行后会：
修改yum源 (base源和epel源默认为 https://mirrors.huaweicloud.com
其他源是 https://mirrors.tuna.tsinghua.edu.cn
)
安装一些生产环境可能必备的软件：
OpenJDK 1.8
Apache Tomcat 9
MySQL 8(不加参数默认为8)
mongodb-org 4
Redis 5
docker-ce
Python36-pip(python3.6会作为依赖被安装)
PHP 7.2(Apache httpd会作为依赖被安装)

配置MySQL
默认开启远程访问，root默认密码为1111
如需修改默认密码，执行之前修改脚本中的MYSQL_PASSWORD变量的值即可
或者执行前先导入MYSQL_PASSWORD变量

export MYSQL_PASSWORD=your_password

将pip源更换成国内源
默认是 http://mirrors.aliyun.com/pypi/simple/

将npm源更换成国内源
默认是 淘宝 NPM 镜像

修改docker镜像源
默认是 https://registry.docker-cn.com

安装一些实用的命令行工具：
通过yum安装的：

bash-completion git wget vim nano yum-utils unar screen lrzsz supervisor iotop iftop jnettop mytop apachetop atop htop ncdu nmap pv net-tools sl lynx links crudini the_silver_searcher tig cloc nload w3m axel tmux mc glances multitail
通过pip安装的：

cheat mycli icdiff you-get lolcat youtube-dl
通过npm安装的：

get-port-cli hasha-cli http-server

安装几个基于命令行的小游戏：
2048
扫雷
俄罗斯方块
"
    echo "可选参数 all(执行所有模块) base kernel python php nodejs cmd_game jdk mysql57 mysql8 mongodb docker"

else
system_config
config_mirror_and_update
for arg in $* ; do
    case ${arg} in
    all)
    config_mirror_and_update
    update_kernel
    install_python
    install_php
    install_nodejs_and_config
    install_cmd_game
    install_jdk_and_tomcat
    install_mysql8_and_config
    install_mongodb
    install_docker
    ;;
    base)
    config_mirror_and_update
    ;;
    kernel)
    update_kernel
    ;;
    python)
    install_python
    ;;
    php)
    install_php
    ;;
    nodejs)
    install_nodejs_and_config
    ;;
    cmd_game)
    install_cmd_game
    ;;
    jdk)
    install_jdk_and_tomcat
    ;;
    mysql57)
    install_mysql57_and_config
    ;;
    mysql8)
    install_mysql8_and_config
    ;;
    mongodb)
    install_mongodb
    ;;
    docker)
    install_docker
    ;;
    esac
done

fi

