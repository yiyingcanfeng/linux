#!/bin/bash
yum install -y epel-release
yum install -y python34-pip #epel源提供的pip3默认是3.4版本的
pip3 install shadowsocks
#可支持多个端口,如有需要，按照json格式自己修改
config_path=$(pwd)/ssconfig.json #配置文件目录,默认是当前目录
ss_port=45986                    #端口
ss_password=1234111              #密码
ss_method=aes-128-cfb            #加密方式,可以参照SS客户端自行修改
cat > ${config_path}<<- EOF
{

    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "${ss_port}":"${ss_password}"
    },
    "method": "${ss_method}",
    "timeout":600
}

EOF
#添加服务;"EOF"：去除$的变量表示功能
cat > /usr/lib/systemd/system/ssserver.service<<- "EOF"
[Unit]
Description=ssserver
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/bin/ssserver -c ssconfig.json  -d start
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF
#双引号是弱转义，不会去除$的变量表示功能;当你不方便转义字符串中/的时候，sed命令支持自定义语法的分隔符
sed -i "s:-c .* -d:-c ${config_path} -d:g" /usr/lib/systemd/system/ssserver.service
systemctl daemon-reload
systemctl start ssserver
systemctl enable ssserver
