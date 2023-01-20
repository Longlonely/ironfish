Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

#1
install_docker_ironfish(){
    
    echo "---开始安装docker..."
    sudo apt-get install -y docker.io 
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "docker 安装完成！"
    sleep 2
    echo "---开始安装ironfish..."
    read -p " ---输入您的Graffiti名称:" name
    echo "---当前输入： $name"
    read -r -p "---请确认输入是否正确？ [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---继续安装ironfish..."
            ;;

        *)
            echo "退出安装!"
            exit 1
            ;;
    esac
    echo "---开始拉取ironfish镜像..."
    sudo docker pull ghcr.io/iron-fish/ironfish:latest
    echo "---启动ironfish，docker名为 node"
    sudo docker run -itd --name node --net host --volume /root/.node:/root/.ironfish ghcr.io/iron-fish/ironfish:latest start  
    sleep 10
    echo "---开始配置节点..."
    sudo docker exec -it node bash -c "ironfish config:set blockGraffiti ${name}"
    sleep 2
    sudo docker exec -it node bash -c "ironfish config:set enableTelemetry true"
    echo "安装完成！"
}

#2
ironfish_status(){
    echo "---开始检查节点状态..."
    sudo docker exec -it node bash -c "ironfish status"
}

#3
ironfish_miner(){
    read -r -p "---请确认节点状态 Connected？ synced？ [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---开始启动挖矿..."
            ;;

        *)
            echo "请等待节点同步后再试！"
            exit 1
            ;;
    esac

    echo "---当前钱包地址为："
    sudo docker exec -it node bash -c "ironfish wallet:address"
    echo "---开始挖矿..."
    echo "---默认连接官方池..."
    read -p "---输入您的钱包地址PulicKey:" key
    sudo docker exec -it node bash -c "ironfish miners:start --pool pool.ironfish.network --address $key"
}

#4
ironfish_wallet(){
    echo "---当前钱包信息："
    sudo docker exec -it node bash -c "ironfish wallet:balance"
    sudo docker exec -it node bash -c "ironfish wallet:notes"
}

#5
ironfish_asset(){
    echo "---开始操作ironfish asset..."
    while true
    do
    echo && echo "
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix}1.铸造 mint${Font_color_suffix}
    ${Green_font_prefix}2.销毁 burn${Font_color_suffix}
    ${Green_font_prefix}3.转账 send${Font_color_suffix}
    ${Green_font_prefix}0.返回${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}" && echo
    read -r -p " ---请选择操作:" num
    case "$num" in
    1)
        sudo docker exec -it node bash -c "ironfish wallet:mint"
        ;;
    2)
        sudo docker exec -it node bash -c "ironfish wallet:burn"
        ;;
    3)
        sudo docker exec -it node bash -c "ironfish wallet:send"
        ;; 
    0)
        break
        ;;
    esac

    done
}

#6
ironfish_cli(){
    echo "---进入ironfish控制台..."
    sudo docker exec -it node bash 
}

#7
ironfish_restart(){
    echo "---启动node节点，如失败请尝试重新安装..."
    sudo docker start node
}

#8
ironfish_update(){
    
    read -r -p "---更新可能丢失钱包数据，是否继续 [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---开始更新..."
            sudo docker pull ghcr.io/iron-fish/ironfish:latest
            echo "---删除旧版节点..."
            sudo docker stop node
            sudo docker rm node
            sudo rm -rf /root/.node
            echo "--旧版本docker节点已删除！"
            sleep 5
            echo "--启动新版本docker节点..."
            sudo docker run -itd --name node --net host --volume /root/.node:/root/.ironfish ghcr.io/iron-fish/ironfish:latest start
            echo "---启动成功，升级完成！"
            ;;
        *)
            echo "---停止更新！"
            exit 1
            ;;
    esac

}

#8 功能补充区
main(){
    while true
    do
    echo && echo "
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix}---Iron Fish 自动管理工具---${Font_color_suffix} 
    ${Green_font_prefix}---V0.2 yangyangcoin---${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix} 1.安装 docker 和 Ironfish   ${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix} 2.检查 node状态   ${Font_color_suffix}
    ${Green_font_prefix} 3.开始 miner挖矿   ${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix} 4.查看 Wallet信息   ${Font_color_suffix}
    ${Green_font_prefix} 5.操作 Asset 铸造，销毁，转账   ${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix} 6.进入 Ironfish控制台   ${Font_color_suffix}
    ${Green_font_prefix} 7.重启节点   ${Font_color_suffix}
    ${Green_font_prefix} 8.版本更新   ${Font_color_suffix}
    ${Green_font_prefix}---------------------------${Font_color_suffix}
    ${Green_font_prefix} 0.退出  ${Font_color_suffix}
    ---------------------------" && echo
    read -r -p " 请选择操作:" num
    case "$num" in
    1)
        install_docker_ironfish
        ;;
    2)
        ironfish_status
        ;;
    3)
        ironfish_miner
        ;;
    4)
        ironfish_wallet
        ;;
    5)
        ironfish_asset
        ;;
    6)
        ironfish_cli
        ;;
    7)
        ironfish_restart
        ;;
    8)
        ironfish_update
        ;;
    0)
        echo "---退出程序！"
        exit
        ;;
    *)
        echo
        echo -e " ${Error} 请选择正确操作："
        ;;
    esac

    done
}

main
