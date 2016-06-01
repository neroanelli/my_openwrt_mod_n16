include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nwan
PKG_VERSION:=1.3
PKG_RELEASE:=2
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-nwan
   SECTION:=luci
   CATEGORY:=LuCI
   DEPENDS:=+libc +ip+ kmod-macvlan +iptables +iptables-mod-conntrack-extra +iptables-mod-ipopt
   TITLE:=Nwan LuCI configuration module
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-app-nwan/description
Nwan LuCI configuration module
endef

define Package/luci-app-nwan/conffiles
/etc/config/nwan
/etc/config/nwannumset
endef

define Package/luci-app-nwan/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/nwan $(1)/etc/config/nwan
	$(INSTALL_CONF) ./root/etc/config/nwannumset $(1)/etc/config/nwannumset
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/luci-nwan $(1)/etc/uci-defaults/luci-nwan
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/nwan.lua $(1)/usr/lib/lua/luci/controller/nwan.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/nwan
	$(INSTALL_DATA) ./luasrc/model/cbi/nwan/nwan.lua $(1)/usr/lib/lua/luci/model/cbi/nwan/nwan.lua
	$(INSTALL_DATA) ./luasrc/model/cbi/nwan/nwannumset.lua $(1)/usr/lib/lua/luci/model/cbi/nwan/nwannumset.lua
	$(INSTALL_DIR) $(1)/lib/nwan
	$(INSTALL_BIN) ./root/lib/nwan/assingout $(1)/lib/nwan/assingout
	$(INSTALL_BIN) ./root/lib/nwan/mobile.rsc $(1)/lib/nwan/mobile.rsc
	$(INSTALL_BIN) ./root/lib/nwan/n_lineset $(1)/lib/nwan/n_lineset
	$(INSTALL_BIN) ./root/lib/nwan/nwan_numset $(1)/lib/nwan/nwan_numset
	$(INSTALL_BIN) ./root/lib/nwan/nwan-ping $(1)/lib/nwan/nwan-ping
	$(INSTALL_BIN) ./root/lib/nwan/onlinecheck $(1)/lib/nwan/onlinecheck
	$(INSTALL_BIN) ./root/lib/nwan/other.rsc $(1)/lib/nwan/other.rsc
	$(INSTALL_BIN) ./root/lib/nwan/pppoeup $(1)/lib/nwan/pppoeup
	$(INSTALL_BIN) ./root/lib/nwan/route $(1)/lib/nwan/route
	$(INSTALL_BIN) ./root/lib/nwan/telecom.rsc $(1)/lib/nwan/telecom.rsc
	$(INSTALL_BIN) ./root/lib/nwan/unicom.rsc $(1)/lib/nwan/unicom.rsc
	$(INSTALL_BIN) ./root/lib/nwan/wireless_set $(1)/lib/nwan/wireless_set
	$(INSTALL_BIN) ./root/lib/nwan/assingout $(1)/lib/nwan/assingout
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/nwan $(1)/etc/init.d/nwan
	$(INSTALL_BIN) ./root/etc/init.d/nwannumset $(1)/etc/init.d/nwannumset
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/etc/hotplug.d/iface/09-route $(1)/etc/hotplug.d/iface/09-route
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./luasrc/nwan.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/nwan.zh-cn.lmo
endef


define Package/luci-app-nwan/postinst
#!/bin/sh 
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/luci-nwan ) && rm -f /etc/uci-defaults/luci-nwan
	chmod 755 /etc/init.d/nwan >/dev/null 2>&1
	chmod 755 /etc/init.d/nwannumset >/dev/null 2>&1
	/etc/init.d/nwan enable >/dev/null 2>&1
	/etc/init.d/nwannumset enable  >/dev/null 2>&1
	exit 0
}
endef
define Package/luci-app-nwan/postrm
#!/bin/sh
uci delete ucitrack.@nwan[-1] >/dev/null 2>&1
uci delete ucitrack.@nwannumset[-1] >/dev/null 2>&1
uci commit ucitrack
sh /lib/nwan/nwan_macvlan_del  >/dev/null 2>&1
sh /lib/nwan/nwan_macvlan100_del  >/dev/null 2>&1
sh /lib/nwan/nwan_macvlan200_del  >/dev/null 2>&1
sh /lib/nwan/nwan_macvlan300_del  >/dev/null 2>&1
exit 0
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-app-nwan))