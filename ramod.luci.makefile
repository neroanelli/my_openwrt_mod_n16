/feeds/ramod/luci/contrib/package/luci/


	
$(eval $(call application,dnsfilter,DNS-Filter LuCI configuration module,\
	+PACKAGE_luci-app-dnsfilter:libc \
	+PACKAGE_luci-app-dnsfilter:bash \
	+PACKAGE_luci-app-dnsfilter:screen \
	+PACKAGE_luci-dnsfilter:wget))

$(eval $(call application,cpulimit,cpulimit-ng LuCI configuration module,\
	+PACKAGE_luci-cpulimit:cpulimit-ng))

$(eval $(call application,nwan,nwan configuration module,\
	+PACKAGE_luci-app-nwan:libc \
	+PACKAGE_luci-app-nwan:ip \
	+PACKAGE_luci-app-nwan:kmod-macvlan \
	+PACKAGE_luci-app-nwan:iptables \
	+PACKAGE_luci-app-nwan:iptables-mod-conntrack-extra \
	+PACKAGE_luci-app-nwan:iptables-mod-ipopt))
	
$(eval $(call application,vpnc,LuCI GUI to the VPNC program,\
	+PACKAGE_luci-vpnc:vpnc))

### Server Gateway Interfaces ###
define sgi
  define Package/luci-sgi-$(1)
    SECTION:=luci
    CATEGORY:=LuCI
    TITLE:=LuCI - Lua Configuration Interface
    URL:=http://luci.subsignal.org/
    MAINTAINER:=LuCI Development Team <luci@lists.subsignal.org>
    SUBMENU:=7. Server Interfaces
    TITLE:=$(if $(2),$(2),LuCI $(1) server gateway interface)
	DEPENDS:=$(3)
