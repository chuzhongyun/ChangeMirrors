#!/bin/bash
# 镜像源数据定义
# 格式: "id|域名|显示名称"

## 国内源
MIRROR_CHINA=(
    "aliyun|mirrors.aliyun.com|阿里云"
    "tencent|mirrors.tencent.com|腾讯云"
    "huaweicloud|repo.huaweicloud.com|华为云"
    "netease|mirrors.163.com|网易"
    "volces|mirrors.volces.com|火山引擎"
    "tsinghua|mirrors.tuna.tsinghua.edu.cn|清华大学"
    "pku|mirrors.pku.edu.cn|北京大学"
    "zju|mirrors.zju.edu.cn|浙江大学"
    "nju|mirrors.nju.edu.cn|南京大学"
    "lzu|mirror.lzu.edu.cn|兰州大学"
    "sjtu|mirror.sjtu.edu.cn|上海交通大学"
    "cqupt|mirrors.cqupt.edu.cn|重庆邮电大学"
    "ustc|mirrors.ustc.edu.cn|中国科学技术大学"
    "iscas|mirror.iscas.ac.cn|中国科学院软件研究所"
)

## 中国大陆教育网源
MIRROR_EDU=(
    "tsinghua|mirrors.tuna.tsinghua.edu.cn|清华大学"
    "pku|mirrors.pku.edu.cn|北京大学"
    "nju|mirrors.nju.edu.cn|南京大学"
    "cqu|mirrors.cqu.edu.cn|重庆大学"
    "lzu|mirror.lzu.edu.cn|兰州大学"
    "zju|mirrors.zju.edu.cn|浙江大学"
    "sdu|mirrors.sdu.edu.cn|山东大学"
    "jlu|mirrors.jlu.edu.cn|吉林大学"
    "shanghaitech|mirrors.shanghaitech.edu.cn|上海科技大学"
    "sustech|mirrors.sustech.edu.cn|南方科技大学"
    "njupt|mirrors.njupt.edu.cn|南京邮电大学"
    "njtech|mirrors.njtech.edu.cn|南京工业大学"
    "uestc|mirrors.uestc.cn|电子科技大学"
    "bjtu|mirror.bjtu.edu.cn|北京交通大学"
    "bupt|mirrors.bupt.edu.cn|北京邮电大学"
    "qlu|mirrors.qlu.edu.cn|齐鲁工业大学"
    "scau|mirrors.scau.edu.cn|华南农业大学"
    "xjtu|mirrors.xjtu.edu.cn|西安交通大学"
    "jxust|mirrors.jxust.edu.cn|江西理工大学"
    "hust|mirrors.hust.edu.cn|华中科技大学"
    "nyist|mirror.nyist.edu.cn|南阳理工学院"
    "wsyu|mirrors.wsyu.edu.cn|武昌首义学院"
    "jcut|mirrors.jcut.edu.cn|荆楚理工学院"
    "bfsu|mirrors.bfsu.edu.cn|北京外国语大学"
    "ustc|mirrors.ustc.edu.cn|中国科学技术大学"
    "nwafu|mirrors.nwafu.edu.cn|西北农林科技大学"
    "neusoft|mirrors.neusoft.edu.cn|大连东软信息学院"
    "sjtu-siyuan|mirror.sjtu.edu.cn|上海交通大学(思源)"
    "sjtu-zhiyuan|mirrors.sjtug.sjtu.edu.cn|上海交通大学(致远)"
)

## 海外源 (格式: "id|域名|显示名称|洲")
MIRROR_ABROAD=(
    "xtom-hk|mirrors.xtom.hk|亚洲-xTom-香港"
    "01link-hk|mirror.01link.hk|亚洲-01Link-香港"
    "nus|download.nus.edu.sg/mirror|亚洲-新加坡国立大学"
    "sggs|mirror.sg.gs|亚洲-SG.GS-新加坡"
    "xtom-sg|mirrors.xtom.sg|亚洲-xTom-新加坡"
    "nchc|free.nchc.org.tw|亚洲-NCHC-台湾"
    "ossplanet|mirror.ossplanet.net|亚洲-OSS Planet-台湾"
    "nctu|linux.cs.nctu.edu.tw|亚洲-阳明交通大学-台湾"
    "tku|ftp.tku.edu.tw|亚洲-淡江大学-台湾"
    "anigil|mirror.anigil.com|亚洲-AniGil-韩国"
    "icscoe|ftp.udx.icscoe.jp/Linux|亚洲-ICSCoE-日本"
    "jaist|ftp.jaist.ac.jp/pub/Linux|亚洲-JAIST-日本"
    "yz-yamagata|linux2.yz.yamagata-u.ac.jp/pub/Linux|亚洲-山形大学-日本"
    "xtom-jp|mirrors.xtom.jp|亚洲-xTom-日本"
    "gbnetwork|mirrors.gbnetwork.com|亚洲-GB Network-马来西亚"
    "kku|mirror.kku.ac.th|亚洲-孔敬大学-泰国"
    "vorboss|mirror.vorboss.net|欧洲-Vorboss-英国"
    "quickhost|mirror.quickhost.uk|欧洲-QuickHost-英国"
    "dogado|mirror.dogado.de|欧洲-dogado-德国"
    "xtom-de|mirrors.xtom.de|欧洲-xTom-德国"
    "rwth|ftp.halifax.rwth-aachen.de|欧洲-RWTH Aachen-德国"
    "agdsn|ftp.agdsn.de|欧洲-AG DSN-德国"
    "in2p3|mirror.in2p3.fr/pub/linux|欧洲-CCIN2P3-法国"
    "ircam|mirrors.ircam.fr/pub|欧洲-Ircam-法国"
    "crans|eclats.crans.org|欧洲-Crans-法国"
    "crihan|ftp.crihan.fr|欧洲-CRIHAN-法国"
    "xtom-nl|mirrors.xtom.nl|欧洲-xTom-荷兰"
    "datapacket|mirror.datapacket.com|欧洲-DataPacket-荷兰"
    "kernel-org|eu.edge.kernel.org|欧洲-Linux Kernel-荷兰"
    "xtom-ee|mirrors.xtom.ee|欧洲-xTom-爱沙尼亚"
    "netsite|mirror.netsite.dk|欧洲-netsite-丹麦"
    "dotsrc|mirrors.dotsrc.org|欧洲-Dotsrc-丹麦"
    "accum|mirror.accum.se|欧洲-ACC-瑞典"
    "lysator|ftp.lysator.liu.se|欧洲-Lysator-瑞典"
    "yandex|mirror.yandex.ru|欧洲-Yandex-俄罗斯"
    "ia64|mirror.linux-ia64.org|欧洲-ia64-俄罗斯"
    "truenetwork|mirror.truenetwork.ru|欧洲-Truenetwork-俄罗斯"
    "belnet|ftp.belnet.be/mirror|欧洲-Belnet-比利时"
    "uoc|ftp.cc.uoc.gr/mirrors/linux|欧洲-克里特大学-希腊"
    "muni|ftp.fi.muni.cz/pub/linux|欧洲-马萨里克大学-捷克"
    "sh-cvut|ftp.sh.cvut.cz|欧洲-SH CVUT-捷克"
    "karneval|mirror.karneval.cz/pub/linux|欧洲-Vodafone-捷克"
    "nic-cz|mirrors.nic.cz|欧洲-CZ.NIC-捷克"
    "ethz|mirror.ethz.ch|欧洲-ETH Zurich-瑞士"
    "kernel-us|mirrors.kernel.org|北美-Linux Kernel-美国"
    "mit|mirrors.mit.edu|北美-MIT-美国"
    "princeton|mirror.math.princeton.edu/pub|北美-普林斯顿-美国"
    "osuosl|ftp-chi.osuosl.org/pub|北美-OSUOSL-美国"
    "fcix|mirror.fcix.net|北美-FCIX-美国"
    "xtom-us|mirrors.xtom.com|北美-xTom-美国"
    "steadfast|mirror.steadfast.net|北美-Steadfast-美国"
    "ubc|mirror.it.ubc.ca|北美-UBC-加拿大"
    "xenyth|mirror.xenyth.net|北美-GoCodeIT-加拿大"
    "switch|mirrors.switch.ca|北美-Switch-加拿大"
    "pop-sc|mirror.pop-sc.rnp.br/mirror|南美-PoP-SC-巴西"
    "uepg|mirror.uepg.br|南美-UEPG-巴西"
    "ufscar|mirror.ufscar.br|南美-UFSCar-巴西"
    "sysarmy|mirrors.eze.sysarmy.com|南美-Sysarmy-阿根廷"
    "fcix-au|gsl-syd.mm.fcix.net|大洋-FCIX-澳大利亚"
    "aarnet|mirror.aarnet.edu.au/pub|大洋-AARNet-澳大利亚"
    "datamossa|mirror.datamossa.io|大洋-DataMossa-澳大利亚"
    "amaze|mirror.amaze.com.au|大洋-Amaze-澳大利亚"
    "xtom-au|mirrors.xtom.au|大洋-xTom-澳大利亚"
    "overthewire|mirror.overthewire.com.au|大洋-Over the Wire-澳大利亚"
    "fsmg|mirror.fsmg.org.nz|大洋-FSMG-新西兰"
    "liquidtelecom|mirror.liquidtelecom.com|非洲-Liquid Telecom-肯尼亚"
    "dimensiondata|mirror.dimensiondata.com|非洲-Dimension Data-南非"
)

## 获取镜像显示列表 (按类别)
get_mirror_list() {
    local category="$1"
    case "$category" in
    china)   echo "${MIRROR_CHINA[@]}" ;;
    edu)     echo "${MIRROR_EDU[@]}" ;;
    abroad)  echo "${MIRROR_ABROAD[@]}" ;;
    esac
}

## 根据 ID 查找镜像域名
find_mirror_domain() {
    local target_id="$1"
    local lists=("MIRROR_CHINA[@]" "MIRROR_EDU[@]" "MIRROR_ABROAD[@]")
    for list_ref in "${lists[@]}"; do
        for entry in ${!list_ref}; do
            local id="${entry%%|*}"
            if [[ "$id" == "$target_id" ]]; then
                echo "${entry#*|}" | cut -d'|' -f1
                return 0
            fi
        done
    done
    return 1
}

## 根据 ID 查找镜像显示名
find_mirror_name() {
    local target_id="$1"
    local lists=("MIRROR_CHINA[@]" "MIRROR_EDU[@]" "MIRROR_ABROAD[@]")
    for list_ref in "${lists[@]}"; do
        for entry in ${!list_ref}; do
            local id="${entry%%|*}"
            if [[ "$id" == "$target_id" ]]; then
                echo "$entry" | cut -d'|' -f3
                return 0
            fi
        done
    done
    return 1
}

## 内网地址映射
declare -A INTRANET_MAP=(
    ["mirrors.aliyun.com"]="mirrors.cloud.aliyuncs.com"
    ["mirrors.tencent.com"]="mirrors.tencentyun.com"
    ["repo.huaweicloud.com"]="mirrors.myhuaweicloud.com"
    ["mirrors.volces.com"]="mirrors.ivolces.com"
)

## 检查是否有内网地址
get_intranet_mirror() {
    local domain="$1"
    echo "${INTRANET_MAP[$domain]:-}"
}