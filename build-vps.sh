TOP_DIR="trunk"
#apt-get install g++ libncurses5-dev zlib1g-dev bison flex unzip autoconf gawk make gettext gettext texinfo sharutils gcc binutils ncurses-term patch bzip2 libbz2-dev libz-dev asciidoc subversion sphinxsearch libtool git git-core curl
#############################
## get the latest source code 
#############################
#svn checkout svn://svn.openwrt.org/openwrt/trunk -r 40820
#svn checkout svn://svn.openwrt.org/openwrt/branches/attitude_adjustment aa

echo "pause"
read -n 1

#echo "src-git exopenwrt https://github.com/black-roland/exOpenWrt.git" >> ./$TOP_DIR/feeds.conf.default
#echo "src-git mwan git://github.com/Adze1502/mwan.git" >> ./$TOP_DIR/feeds.conf.default
#echo "src-git ramod git://github.com/ravageralpha/my_openwrt_mod.git" >> ./$TOP_DIR/feeds.conf.default
./$TOP_DIR/scripts/feeds update -a
./$TOP_DIR/scripts/feeds install -a

#cp -rf ./n16/opkg.conf ./$TOP_DIR/package/system/opkg/files/
cp -rf ./n16/opkg.conf ./$TOP_DIR/package/system/opkg/files/
############################
##change trx_max_len
# if grep -q "0xD00000" ./$TOP_DIR/tools/firmware-utils/src/trx.c
#############################


#############################
##RA MOD
mkdir ./$TOP_DIR/feeds/oldpackages/net/aria2/patches
mkdir ./$TOP_DIR/feeds/packages/net/openconnect/patches
cp -rf ./my_openwrt_mod_n16/patch/aria2/*.* ./$TOP_DIR/feeds/oldpackages/net/aria2/patches
cp -rf ./my_openwrt_mod_n16/patch/uClibc/*.* ./$TOP_DIR/toolchain/uClibc/patches-0.9.33.2
cp -rf ./my_openwrt_mod_n16/patch/busybox/*.* ./$TOP_DIR/package/utils/busybox/patches
cp -rf ./my_openwrt_mod_n16/patch/openconnect/*.* ./$TOP_DIR/feeds/packages/net/openconnect/patches
#package
cp -rf ./my_openwrt_mod_n16/package/base-files/etc/sysupgrade.conf ./trunk/package/base-files/files/etc/
cp -rf ./my_openwrt_mod_n16/package/base-files/etc/profile ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./my_openwrt_mod_n16/package/base-files/etc/ipset ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./my_openwrt_mod_n16/package/base-files/etc/config/wireless ./$TOP_DIR/package/base-files/files/etc/config/
cp -rf ./my_openwrt_mod_n16/package/base-files/etc/hotplug.d ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./my_openwrt_mod_n16/package/dnsmasq/*.* ./$TOP_DIR/package/network/services/dnsmasq/files/
cp -rf ./my_openwrt_mod_n16/package/cpulimit-ng ./$TOP_DIR/package/
#############################
#!!!!!!remove IPSET
#REMOVE ipset ./$TOP_DIR/package/network/services/dnsmasq/Makefile
#############################
#fstools
cp -rf ./my_openwrt_mod_n16/package/fstools ./$TOP_DIR/package/system/
#############################
#!!!!!change the makefile
#patch -p0 ./$TOP_DIR/package/system/fstools/Makefile < ./$TOP_DIR/package/system/fstools/Makefile.diff
#rm ./$TOP_DIR/package/system/fstools/Makefile.diff
#############################
#luci??
#cp -rf ./my_openwrt_mod_n16/luci ./$TOP_DIR/feeds/
#patch -p0 ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile < ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile.diff
#rm ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile.diff
cp -rf ./n16/luci ./$TOP_DIR/feeds/ramod/

cd $TOP_DIR
#vim ./$TOP_DIR/include/prereq-build.mk ?notroot
make defconfig
make prereq
#./scripts/feeds install -a 
#cp ~/rt-n16/config.rt-n16 ~/trunk/.config
#dnscrypt
#cp ~/rt-n16/config.rt-n16.pdnsd+dnscrypt ~/trunk/.config
cp ../n16/config.40820 ./.config
##QOS
#patch -p0 <10-imq.patch
#sh /home/trob/git/my_openwrt_mod_n16/qos-gargoyle-trunk/netfilter-match-modules/integrate_netfilter_modules.sh  /home/trob/git/trunk /home/trob/git/my_openwrt_mod_n16/qos-gargoyle-trunk/netfilter-match-modules
#make menuconfig
#make V=99 2>&1 |tee build.log
#make V=99 2>&1 |tee build.log |grep -i error   
#tar -cvf ~/trunk/bin.tar ~/trunk/bin
