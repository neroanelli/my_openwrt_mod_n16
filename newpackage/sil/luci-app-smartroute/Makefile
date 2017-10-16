include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-smartroute
PKG_VERSION:=1.1
PKG_RELEASE:=2
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-smartroute
   SECTION:=luci
   CATEGORY:=LuCI
   DEPENDS:=+libc +ip +iptables +ipset
   TITLE:=Policy-Route LuCI configuration module
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-app-smartroute/description
Policy-Route LuCI configuration module
endef

define Package/luci-app-smartroute/conffiles
/etc/config/smartroute
endef

define Package/luci-app-smartroute/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/smartroute.conf $(1)/etc/config/smartroute
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/smartroute.lua $(1)/usr/lib/lua/luci/controller/smartroute.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/cbi/smartroute.lua $(1)/usr/lib/lua/luci/model/cbi/smartroute.lua
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/smartroute.init $(1)/etc/init.d/smartroute
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/31-smartroute $(1)/etc/hotplug.d/iface/31-smartroute
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/luci-smartroute.uci $(1)/etc/uci-defaults/luci-smartroute
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./luasrc/smartroute.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/smartroute.zh-cn.lmo
endef


define Package/luci-app-smartroute/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-smartroute ) && rm -f /etc/uci-defaults/luci-smartroute
	chmod 755 /etc/init.d/smartroute >/dev/null 2>&1
	/etc/init.d/smartroute enable >/dev/null 2>&1
fi
exit 0
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-app-smartroute))
