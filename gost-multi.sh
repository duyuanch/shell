#!/usr/bin/env bash
echo "本脚本仅供学习交流，请勿用于其他用途，否则后果自负"
file_name=gost-linux-amd64-2.11.0.gz
if [[ ! -f $file_name ]]; then
  yum install wget -y
  wget https://github.com/ginuerzh/gost/releases/download/v2.11.0/gost-linux-amd64-2.11.0.gz
fi
gzip -d gost-linux-amd64-2.11.0.gz && mv gost-linux-amd64-2.11.0 gost && chmod +x gost
echo "gost安装成功"
#写入开始的括号
cat <<EOT >> gost.json
{
    "Debug": true,
    "Retries": 0,
    "ServeNodes": [
    ],
    "ChainNodes": [
    ],
    "Routes": [
EOT

while [[ true ]]; do
  read -p "请输入要中转的服务器IP:" dest
  read -p "请输入要转发的起始端口号:" start_port
  read -p "请输入要转发的终止端口号:" end_port
  for (( port = $start_port; port <= $end_port; port++ )); do
    listen_port=`expr $port + 1`
    echo "loop${port}"
    if [[ ${port} -eq `expr $end_port` ]]; then
      echo "if"
      cat <<EOT >> gost.json
        {
            "Retries": 0,
            "ServeNodes": [
                "tcp://:${listen_port}/${dest}:${port}",
                "udp://:${listen_port}/${dest}:${port}"
            ],
            "ChainNodes": [
                "ws://${dest}:12348/ws"
            ]
        }
EOT
    else
      echo "else"
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
  read -p "是否继续添加服务器转发(y|n):" yesOrNo
  if [[ ${yesOrNo} == "n" ]]; then
    break
  fi
done
# 写入结束的括号
cat <<EOT >> gost.json
  ]
}
EOT
echo "安装成功"
