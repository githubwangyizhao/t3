#!/usr/bin/expect -f

######################################
######本地文件 同步到 远程服务器######
######################################

# do_transmit.sh 
set timeout 600
#本地目录
set localPath [lindex $argv 0]
#登录用户名
set user [lindex $argv 1]
#密钥
set secret [lindex $argv 2]
#密钥密码
set password [lindex $argv 3]
#远端ip
set remoteIp [lindex $argv 4]
#端口
set port [lindex $argv 5]
#远端目录
set remotePath [lindex $argv 6]
#包含文件
set includeFile [lindex $argv 7]
#排除文件
set excludeFile [lindex $argv 8]

#echo "正在同步:"
spawn rsync -avrzhPL --delete -e "ssh -p ${port} -i ${secret}" --files-from=${includeFile} --exclude-from=${excludeFile} ${localPath} ${user}@${remoteIp}:${remotePath}
#echo "同步完毕!"
#expect {
#    "Enter passphrase for key" {
#        send "${password}\r"
#    }
#}

interact
