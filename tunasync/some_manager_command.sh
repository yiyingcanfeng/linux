#!/bin/bash
#tunasynctl set-size -w <worker-id> <mirror> <size> 设置镜像的大小信息
tunasynctl set-size -w worker nginx 528.8M
#列出所有镜像信息
tunasynctl list  --all
#输入的信息类似如下格式，如果要输出到json文件，需要将1,2行删掉
#/root/.config/tunasync/ctl.conf
#[19-01-22 15:48:06][INFO] Use manager address: http://localhost:14242
#[
#  {
#    "name": "ruby",
#    "is_master": true,
#    "status": "success",
#    "last_update": "2019-01-22 02:14:34 +0800",
#    "last_update_ts": 1548094474,
#    "last_ended": "2019-01-22 02:14:34 +0800",
#    "last_ended_ts": 1548094474,
#    "upstream": "https://mirrors.huaweicloud.com/ruby/ruby/",
#    "size": "13.9G"
#  },
#  {
#    "name": "ubuntu-releases",
#    "is_master": true,
#    "status": "success",
#    "last_update": "2019-01-22 02:08:43 +0800",
#    "last_update_ts": 1548094123,
#    "last_ended": "2019-01-22 02:08:43 +0800",
#    "last_ended_ts": 1548094123,
#    "upstream": "rsync://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/",
#    "size": "19.6G"
#  }
#]

#另一种方式
#搭配crontab定时任务，定时将json数据文件同步到 web 前端页面中。
curl http://localhost:14242/jobs | python -m json.tool > /var/www/html/static/tunasync.json
