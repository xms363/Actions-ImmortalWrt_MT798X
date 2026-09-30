#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After ./scripts/feeds update -a, Before ./scripts/feeds install -a)
#
# ======== 编译 OpenClash 最新版 =========
# immortalwrt 插件库已经包含 OpenClash，若源码被删除或编译 OpenClash 最新版，使用以下命令自行编译，打开 immortalwrt官方插件库查询：https://github.com/immortalwrt/immortalwrt（选择 openwrt-24.10分支，打开 feeds.conf.default文件，再打开luci仓库找到“applications”查询插件）
#sed -i '1i src-git openclash https://github.com/vernesong/OpenClash.git;master' ./feeds.conf.default
        
# ======== 编译 passwall 最新版 =========
# immortalwrt插件库已经包含 passwall，若源码被删除或编译 Passwall 最新版，使用以下命令自行编译，打开 immortalwrt官方插件库查询：https://github.com/immortalwrt/immortalwrt（选择 openwrt-24.10分支，打开 feeds.conf.default文件，再打开luci仓库找到“applications”查询插件）
# 编译 passwall_luci，去掉下面注释，此命令会在 feeds.conf.default文件，第 1 行插入 passwall_luci
#sed -i '1i src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' ./feeds.conf.default

# 编译 passwall_packages，再次在 feeds.conf.default文件，第 1 行插入 passwall_packages (这样 packages 就变成了第 1 行，luci 变成了第 2 行)
#sed -i '1i src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' ./feeds.conf.default

rm -rf feeds/packages/net/open-app-filter
git clone https://github.com/destan19/OpenAppFilter package/OpenAppFilter
##-----Update golang for luci-app-openlist2------
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-openlist2 package/openlist
git clone https://github.com/EasyTier/luci-app-easytier package/luci-app-easytier
git clone https://github.com/gdy666/luci-app-lucky package/lucky
##-----Fix nginx.config for luci-app-quickfile------
cat > feeds/packages/net/nginx-util/files/nginx.config << 'EOF'

config main global
	option uci_enable 'true'

config server '_lan'
	option server_name '_lan'
	list listen '80 default_server'
	list listen '[::]:80 default_server'
	list include 'conf.d/*.locations'
	option access_log 'off; # logd openwrt'
EOF
git clone https://github.com/sbwml/luci-app-quickfile package/quickfile
git clone --depth=1 https://github.com/LazuliKao/luci-theme-fluent /tmp/luci-theme-fluent
cp -a /tmp/luci-theme-fluent/package/* package/
git clone https://github.com/eamonxg/luci-theme-shadcn package/luci-theme-shadcn
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
##-----------------Add OpenClash meta core------------------
curl -sL -m 30 --retry 2 https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mkdir -p feeds/luci/applications/luci-app-openclash/root/etc/openclash/core
mv /tmp/clash feeds/luci/applications/luci-app-openclash/root/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
##-----------------Delete DDNS's examples-----------------
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
##-----------------Display fixed frequency info for MT7986A-----------------
##sed -i '/"mediatek"\/\*|"mvebu"\/\*)/i "mediatek/filogic")\n\tcpu_freq="2.0GHz" ;;' package/emortal/autocore/files/generic/cpuinfo

