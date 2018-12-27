#!/bin/bash
# crontab:配合for循环间接的实现每隔5秒执行一次任务
# * *  *  *  * tunasync_status.sh
for((i=1;i<=12;i++));do
    tunasynctl list -p 12345 --all > /var/www/html/static/tunasync.json
    sed -i '1,2d' /var/www/html/static/tunasync.json
    sleep 5
done