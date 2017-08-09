
local m, s, o
require("luci.tools.webadmin")

m = Map("policyroute","Policy-Route", translate("Policy Routing for VPN"))

-- Global Setting
s = m:section(TypedSection, "policyroute", translate("Global Setting"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.default = 0
o.rmempty = false

o = s:option(ListValue, "interface", translate("vpn Interface"))
luci.tools.webadmin.cbi_add_networks(o)
o.optional = false
o.rmempty = false
o.default = "vpn"

o = s:option(Value, "ignore_list", translate("Ignore List"))
o:value("/dev/null", translate("Disabled"))
o.default = "/dev/null"
o.rmempty = false

-- Access Control
s = m:section(TypedSection, "policyroute", translate("Access Control"))
s.anonymous = true

s:tab("lan_ac", translate("LAN"))

o = s:taboption("lan_ac", ListValue, "lan_ac_mode", translate("Access Control"))
o:value("0", translate("Disabled"))
o:value("1", translate("Allow listed only"))
o:value("2", translate("Allow all except listed"))
o.default = 0
o.rmempty = false

a = luci.sys.net.arptable() or {}

o = s:taboption("lan_ac", DynamicList, "lan_ac_ip", translate("LAN IP List"))
o.datatype = "ipaddr"
for i,v in ipairs(a) do
	o:value(v["IP address"])
end

s:tab("wan_ac", translate("WAN"))

o = s:taboption("wan_ac", DynamicList, "wan_bp_ip", translate("Bypassed IP"))
o.datatype = "ip4addr"

o = s:taboption("wan_ac", DynamicList, "wan_fw_ip", translate("Forwarded IP"))
o.datatype = "ip4addr"

return m