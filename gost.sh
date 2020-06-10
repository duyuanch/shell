#!/usr/bin/env bash
echo "本脚本仅供学习交流，请勿用于其他用途，否则后果自负"

yum install wget -y
wget https://github.com/ginuerzh/gost/releases/download/v2.11.0/gost-linux-amd64-2.11.0.gz
gzip -d gost-linux-amd64-2.11.0.gz && mv gost* gost && chmod +x gost
echo "gost安装成功"

read -p "请输入要中转的服务器IP:" dest
read -p "请输入要转发的起始端口号:" start_port
read -p "请输入要转发的终止端口号:" end_port
for (( port = $start_port; port <= $end_port; port++ )); do
  listen_port=`expr $port - 10000`
  echo "nohup ./gost -L=:${listen_port}/$dest:$port -F=ws://$dest:12348/ws &"
  nohup ./gost -L=:${listen_port}/:${port} -F=ws://${dest}:12348/ws &
done
echo "安装成功"
