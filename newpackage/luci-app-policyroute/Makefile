include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-policyroute
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-policyroute
   SECTION:=luci
   CATEGORY:=LuCI
   DEPENDS:=+libc +ip +iptables
   TITLE:=Policy-Route LuCI configuration module
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-app-policyroute/description
Policy-Route LuCI configuration module
endef

define Package/luci-app-policyroute/conffiles
/etc/config/policyroute
endef

define Package/luci-app-policyroute/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/policyroute.conf $(1)/etc/config/policyroute
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/policyroute.lua $(1)/usr/lib/lua/luci/controller/policyroute.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/cbi/policyroute.lua $(1)/usr/lib/lua/luci/model/cbi/policyroute.lua
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/policyroute.init $(1)/etc/init.d/policyroute
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./root/31-vpn $(1)/etc/hotplug.d/iface/31-vpn
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./luasrc/policyroute.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/policyroute.zh-cn.lmo
endef


define Package/luci-app-policyroute/postinst
endef
define Package/luci-app-policyroute/postrm
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-app-policyroute))
