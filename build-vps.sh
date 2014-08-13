TOP_DIR="barrier_breaker"
#apt-get install g++ libncurses5-dev zlib1g-dev bison flex unzip autoconf gawk make gettext gettext texinfo sharutils gcc binutils ncurses-term patch bzip2 libbz2-dev libz-dev asciidoc subversion sphinxsearch libtool git git-core curl
#############################
## get the latest source code 
#############################
#svn checkout svn://svn.openwrt.org/openwrt/trunk -r 40820
svn checkout svn://svn.openwrt.org/openwrt/branches/barrier_breaker
#svn checkout svn://svn.openwrt.org/openwrt/branches/attitude_adjustment aa

echo "pause"
read -n 1


#######Comment luci line
echo "src-git exopenwrt https://github.com/black-roland/exOpenWrt.git" >> ./$TOP_DIR/feeds.conf.default
echo "src-git mwan git://github.com/Adze1502/mwan.git" >> ./$TOP_DIR/feeds.conf.default
echo "src-git ramod git://github.com/ravageralpha/my_openwrt_mod.git" >> ./$TOP_DIR/feeds.conf.default
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
mkdir ./$TOP_DIR/feeds/packages/net/aria2/patches
mkdir ./$TOP_DIR/feeds/packages/net/openconnect/patches
cp -rf ./patch/aria2/*.* ./$TOP_DIR/feeds/packages/net/aria2/patches
cp -rf ./patch/uClibc/*.* ./$TOP_DIR/toolchain/uClibc/patches-0.9.33.2
cp -rf ./patch/busybox/*.* ./$TOP_DIR/package/utils/busybox/patches
#cp -rf ./patch/openconnect/*.* ./$TOP_DIR/feeds/packages/net/openconnect/patches
#package
cp -rf ./package/base-files/etc/sysupgrade.conf ./trunk/package/base-files/files/etc/
cp -rf ./package/base-files/etc/profile ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./package/base-files/etc/ipset ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./package/base-files/etc/config/wireless ./$TOP_DIR/package/base-files/files/etc/config/
cp -rf ./package/base-files/etc/hotplug.d ./$TOP_DIR/package/base-files/files/etc/
cp -rf ./package/dnsmasq/*.* ./$TOP_DIR/package/network/services/dnsmasq/files/
cp -rf ./package/cpulimit-ng ./$TOP_DIR/package/
#############################
#!!!!!!remove IPSET
#REMOVE ipset ./$TOP_DIR/package/network/services/dnsmasq/Makefile
#############################
#fstools
cp -rf ./package/fstools ./$TOP_DIR/package/system/
#############################
#!!!!!change the makefile
#patch -p0 ./$TOP_DIR/package/system/fstools/Makefile < ./$TOP_DIR/package/system/fstools/Makefile.diff
#rm ./$TOP_DIR/package/system/fstools/Makefile.diff
#############################
#luci??
#cp -rf ./luci ./$TOP_DIR/feeds/
#patch -p0 ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile < ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile.diff
#rm ./$TOP_DIR/feeds/luci/contrib/package/luci/Makefile.diff
cp -rf ./n16/luci ./$TOP_DIR/feeds/ramod/

cd $TOP_DIR

make defconfig
make prereq

cp ../n16/config.40820 ./.config
cp ../n16/config.x86 ./.config

#make menuconfig
#make V=99 2>&1 |tee build.log
#make V=99 2>&1 |tee build.log |grep -i error   
#tar -cvf ~/trunk/bin.tar ~/trunk/bin
