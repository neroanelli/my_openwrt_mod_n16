include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-macvlan
PKG_VERSION:=1.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-macvlan
   SECTION:=luci
   CATEGORY:=LuCI
   DEPENDS:=+libc +ip+ kmod-macvlan +iptables +iptables-mod-conntrack-extra +iptables-mod-ipopt
   TITLE:=Macvlan LuCI configuration module
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-app-macvlan/description
Macvlan LuCI configuration module
endef

define Package/luci-app-macvlan/conffiles
/etc/config/macvlan
endef

define Package/luci-app-macvlan/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/macvlan $(1)/etc/config/macvlan
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/macvlan.lua $(1)/usr/lib/lua/luci/controller/macvlan.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/macvlan.lua $(1)/usr/lib/lua/luci/model/cbi/macvlan.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/macvlan
	$(INSTALL_DATA) ./luasrc/view/macvlan/macvlan_rediag.htm $(1)/usr/lib/lua/luci/view/macvlan/macvlan_rediag.htm
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./root/bin/genwancfg $(1)/bin/genwancfg
	$(INSTALL_BIN) ./root/bin/pppconnectcheck $(1)/bin/pppconnectcheck
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/macvlan $(1)/etc/init.d/macvlan
	$(INSTALL_BIN) ./root/etc/init.d/ppp_syncdiag $(1)/etc/init.d/ppp_syncdiag
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/etc/hotplug.d/iface/01-macvlan $(1)/etc/hotplug.d/iface/01-macvlan
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./luasrc/macvlan.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/macvlan.zh-cn.lmo
endef



define Build/Compile
endef

$(eval $(call BuildPackage,luci-app-macvlan))