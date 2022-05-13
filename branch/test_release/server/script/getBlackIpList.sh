#! /bin/bash

`wget -c http://ipblock.chacuo.net/down/t_txt=c_CN -O /opt/t1/trunk/server/priv/chinaIpList.txt`
cat /opt/t1/trunk/server/priv/chinaIpList.txt |awk -F ' ' '{print $1"\r\n"$2}' | tee /opt/t1/trunk/server/priv/blackIpList.txt