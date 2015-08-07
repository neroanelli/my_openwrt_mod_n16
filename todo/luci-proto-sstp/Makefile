include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-sstp
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-proto-sstp
   SECTION:=LuCI
   CATEGORY:=Protocols
   DEPENDS:=+sstp-client
   TITLE:=Support for SSTP VPN
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-proto-sstp/description
SSTP VPN protocol support for LuCI
endef

define Package/luci-proto-sstp/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/cbi/proto_sstp.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DATA) ./files/network/proto_sstp.lua $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/sstp.sh $(1)/lib/netifd/proto
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-proto-sstp))
