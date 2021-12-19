#!/usr/bin/env bash
echo "本脚本仅供学习交流，请勿用于其他用途，否则后果自负"

download() {
  file_name=gost-linux-amd64-2.11.1.gz
  gost="${file_name%.*}"
  if [[ ! -f $file_name && ! -f "gost" ]]; then
    echo "gost未安装【开始下载】"
    yum install wget -y
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.1/gost-linux-amd64-2.11.1.gz
    else
      echo "gost【已经下载】"
  fi
  gzip -d ${file_name} && mv ${gost} gost && chmod +x gost
  echo "恭喜安装成功!!!"
}

client() {
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
                  "relay://${dest}:12348"
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
                  "relay://${dest}:12348"
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
}

server() {
  screen -S gost -dm ./gost -L "relay://:12348"
}

main() {
  download
  PS3='请选择菜单: '
  options=("中转服务器" "目标服务器" "查看服务" "退出")
  select opt in "${options[@]}"
  do
      case $opt in
          "中转服务器")
              client
              ;;
          "目标服务器")
              server
              ;;
          "查看服务")
              screen -ls
              ;;
          "退出")
              break
              ;;
          *) echo "Invalid option $REPLY";;
      esac
  done
}

main
