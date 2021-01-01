#!/usr/bin/env bash
echo "本脚本仅供学习交流，请勿用于其他用途，否则后果自负"
file_name=gost-linux-amd64-2.11.0.gz
gost=gost
if [[ ! -f $file_name && ! -f $gost ]]; then
  yum install wget -y
  wget https://github.com/ginuerzh/gost/releases/download/v2.11.0/gost-linux-amd64-2.11.0.gz
  gzip -d gost-linux-amd64-2.11.0.gz && mv gost-linux-amd64-2.11.0 gost && chmod +x gost
fi
echo "gost安装成功"
read -p "请输入要中转的服务器IP:" dest
read -p "请输入要转发的起始端口号:" start_port
read -p "请输入要转发的终止端口号:" end_port
read -p "请输入偏移量:" offset
while [[ $start_port -le $end_port ]]; do
  #写入开始的括号
  cat <<EOT > gost.json
{
    "Debug": true,
    "Retries": 0,
    "ServeNodes": [
    ],
    "ChainNodes": [
    ],
    "Routes": [
EOT
  for (( port = $start_port; port <= `expr $start_port + 500` && port <= $end_port; port++ )); do
    listen_port=`expr $port + $offset`
    if [[ ${port} -eq `expr $end_port` ]]; then
      cat <<EOT >> gost.json
        {
            "Retries": 0,
            "ServeNodes": [
                "tcp://:${listen_port}/${dest}:${port}",
                "udp://:${listen_port}/${dest}:${port}"
            ],
            "ChainNodes": [
                "ws://${dest}:12345/ws"
            ]
        }
EOT
    else
      cat <<EOT >> gost.json
        {
            "Retries": 0,
            "ServeNodes": [
                "tcp://:${listen_port}/${dest}:${port}",
                "udp://:${listen_port}/${dest}:${port}"
            ],
            "ChainNodes": [
                "ws://${dest}:12345/ws"
            ]
        },
EOT
    fi
  done
  # 写入结束的括号
  cat <<EOT >> gost.json
  ]
}
EOT
  screen -S "gost-${start_port}-`expr ${start_port} + 500`" -dm ./gost -C gost.json
  start_port=`expr $start_port + 500`
done
