# 统计并设置镜像的大小信息
import os

cmd = 'ls -l |grep "^d" |awk \'{print $9}\' | xargs'
directories = os.popen(cmd).readlines()[0].replace('\n', '')
mirror_size_json = {}
for directory in directories.split(' '):
    count_size_cmd = 'du -hs %s' % directory
    size = os.popen(count_size_cmd).readlines()[0].split('\t')[0]
    mirror_size_cmd = 'tunasynctl set-size -w worker %s %s' % (directory, size)
    print(mirror_size_cmd)
    print(directory,size)
    print(os.popen(mirror_size_cmd).readlines())
