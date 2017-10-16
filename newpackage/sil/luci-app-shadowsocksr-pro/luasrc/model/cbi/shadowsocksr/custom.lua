-- Copyright (C) 2017 by Sil
-- Licensed to the public under the GNU General Public License v3.

local fs = require "nixio.fs"
local NXFS = require "nixio.fs"
local WLFS = require "nixio.fs"
local SYS  = require "luci.sys"
local uci = luci.model.uci.cursor()
local gfw_count = SYS.exec("cat /etc/gfwlist/china-banned | wc -l")
local conf = "/etc/shadowsocksr/user-defined-gfwlist.txt"
local watch = "/tmp/shadowsocksr_watchdog.log"
local dog = "/tmp/ssrpro.log"


m = Map("shadowsocksr")
m.title	= translate("Shadowsocksr Custom Settings")
m.description = translate("A fast secure tunnel proxy that help you get through firewalls on your router")

s = m:section(TypedSection, "shadowsocksr")
s.anonymous = true

-- [[ User-defined GFW-List ]]--
s:tab("list",  translate("User-defined GFW-List"))
gfwlist = s:taboption("list", TextValue, "conf")
gfwlist.description = translate("<br />（!）Note: When the domain name is entered and will automatically merge with the online GFW-List. Please manually update the GFW-List list after applying.")
gfwlist.rows = 13
gfwlist.wrap = "off"
gfwlist.cfgvalue = function(self, section)
	return NXFS.readfile(conf) or ""
end
gfwlist.write = function(self, section, value)
	NXFS.writefile(conf, value:gsub("\r\n", "\n"))
end

local addipconf = "/etc/shadowsocksr/addinip.txt"


-- [[ GFW-List Add-in IP ]]--
s:tab("addip",  translate("GFW-List Add-in IP"))
gfwaddin = s:taboption("addip", TextValue, "addipconf")
gfwaddin.description = translate("<br />（!）Note: IP add-in to GFW-List. Such as Telegram Messenger")
gfwaddin.rows = 13
gfwaddin.wrap = "off"
gfwaddin.cfgvalue = function(self, section)
	return NXFS.readfile(addipconf) or ""
end
gfwaddin.write = function(self, section, value)
	NXFS.writefile(addipconf, value:gsub("\r\n", "\n"))
end

-- [[ Status and Tools ]]--

-- ---------------------------------------------------
local apply = luci.http.formvalue("cbi.apply")
if apply then
	os.execute("sh /etc/shadowsocksr/up-gfwlist.sh >/dev/null 2>&1 &")
end

return m
