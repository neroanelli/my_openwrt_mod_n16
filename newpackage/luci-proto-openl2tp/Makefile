include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-openl2tp
PKG_VERSION:=1.0
PKG_RELEASE:=2
PKG_MAINTAINER:=Derron Z <neroanelli@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-proto-openl2tp
   SECTION:=LuCI
   CATEGORY:=Protocols
   DEPENDS:=+openl2tp-full +ppp-multilink
   TITLE:=Support for L2TP/IPSec VPN(openl2tp+strongSwan)
   MAINTAINER:=Derron Z <neroanelli@gmail.com>
   PKGARCH:=all
endef

define Package/luci-proto-openl2tp/description
L2TP/IPSec VPN protocol support for LuCI
endef

define Package/luci-proto-openl2tp/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/cbi/proto_openl2tp.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DATA) ./files/network/proto_openl2tp.lua $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/openl2tp.sh $(1)/lib/netifd/proto
endef

define Build/Compile
endef

$(eval $(call BuildPackage,luci-proto-openl2tp))
