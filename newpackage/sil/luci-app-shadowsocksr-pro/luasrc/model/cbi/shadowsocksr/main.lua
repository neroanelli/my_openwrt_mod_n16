-- Copyright (C) 2017 by Sil
-- Licensed to the public under the GNU General Public License v3.

local fs = require "nixio.fs"
local NXFS = require "nixio.fs"
local SYS  = require "luci.sys"
local uci = luci.model.uci.cursor()
local gfw_count = SYS.exec("cat /etc/gfwlist/china-banned | wc -l")
local ip_count = SYS.exec("cat /etc/shadowsocksr/china-ip.txt | wc -l")
local conf = "/etc/shadowsocksr/base-gfwlist.txt"
local dog = "/tmp/shadowsocksr/switch.log"

local Status
local currentserver
local currentserver_name

Status = translate("<span class=shadowsocksr_status>ShadowsocksR Status</span>")
currentserver = string.gsub(luci.sys.exec("cat /tmp/shadowsocksr/currentserver 2>/dev/null"), "^%s*(.-)%s*$", "%1")

m = Map("shadowsocksr")
m.title	= translate("Shadowsocksr Transparent Proxy")
m.description = translate("A fast secure tunnel proxy that help you get through firewalls on your router")
m.template="shadowsocksr/status"

local server_table = {}

uci:foreach("shadowsocksr", "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = s.alias
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)

if (string.len(currentserver)) == 0 then
	currentserver_name = "empty"
else
	currentserver_name = server_table[currentserver]
end

if (currentserver_name == nil) then
	currentserver_name = "empty"
end

s = m:section(TypedSection, "shadowsocksr")
s.anonymous = true
s.description = translate(string.format("%s<br /><br />", Status))

-- ---------------------------------------------------
-- [[ Base Setting ]]--
s:tab("basic",  translate("Base Setting"))


switch = s:taboption("basic",Flag, "enabled", translate("Enable"))
switch.rmempty = false

global_server = s:taboption("basic", ListValue, "global_server", translate("Global Server"),
	translate(string.format("Current Server is <strong>%s</strong>", currentserver_name)))
global_server:value("nil", translate("Disable"))
for k, v in pairs(server_table) do global_server:value(k, v) end
global_server.default = "nil"
global_server.rmempty = false

local_port = s:taboption("basic", Value, "local_port", translate("Local Port"))
local_port.datatype = "range(1,65535)"
local_port.optional = false
local_port.rmempty = false

-- monitor_enable = s:taboption("basic", Flag, "monitor_enable", translate("Enable Process Monitor"))
-- monitor_enable.rmempty = false

enable_switch = s:taboption("basic", Flag, "enable_switch", translate("Enable Auto Switch"))
enable_switch.rmempty = false

delay_time = s:taboption("basic", Value, "delay_time", translate("Switch Check Cycly(second)"))
delay_time.datatype = "uinteger"
delay_time:depends("enable_switch", "1")
delay_time.default = 600

check_timeout = s:taboption("basic", Value, "check_timeout", translate("Check Timout(second)"))
check_timeout.datatype = "uinteger"
check_timeout:depends("enable_switch", "1")
check_timeout.default = 3

proxy_mode = s:taboption("basic",ListValue, "proxy_mode", translate("Proxy Mode"))
proxy_mode:value("M", translate("Base on GFW-List Auto Proxy Mode(Recommend)"))
proxy_mode:value("S", translate("Bypassing China Manland IP Mode(Be caution when using P2P download！)"))
proxy_mode:value("G", translate("Global Mode"))
proxy_mode:value("V", translate("Overseas users watch China video website Mode"))

cronup = s:taboption("basic", Flag, "gfw_cron_mode", translate("Auto Update GFW-List"),
	translate(string.format("GFW-List Lines： <strong><font color=\"blue\">%s</font></strong> Lines", gfw_count)))
cronup.default = "1"
cronup:depends("proxy_mode", "M")
cronup.rmempty = false

updatead = s:taboption("basic", Button, "updatead", translate("Manually force update GFW-List"), translate("Note: It needs to download and convert the rules. The background process may takes 60-120 seconds to run. <br / > After completed it would automatically refresh, please do not duplicate click!"))
updatead.inputtitle = translate("Manually update GFW-List")
updatead.inputstyle = "apply"
updatead:depends("proxy_mode", "M")
updatead.write = function()
	SYS.call("nohup sh /etc/shadowsocksr/up-gfwlist.sh > /tmp/shadowsocksr/gfwupdate.log 2>&1 &")
end

cn_cronup = s:taboption("basic", Flag, "cn_cron_mode", translate("Auto Update China IP"),
	translate(string.format("China IP Data Lines： <strong><font color=\"blue\">%s</font></strong> Lines", ip_count)))
cn_cronup.default = "1"
cn_cronup:depends("proxy_mode", "S")
cn_cronup.rmempty = false

updateip = s:taboption("basic", Button, "updateip", translate("Manually force update China IP Data"), translate("Note: It needs to download and convert the rules. The background process may takes 60-120 seconds to run. <br / > After completed it would automatically refresh, please do not duplicate click!"))
updateip.inputtitle = translate("Manually update China IP Data")
updateip.inputstyle = "apply"
updateip:depends("proxy_mode", "S")
updateip.write = function()
	SYS.call("nohup sh /etc/shadowsocksr/up-chinaip.sh > /tmp/shadowsocksr/china-ip-update.log 2>&1 &")
end

safe_dns_tcp = s:taboption("basic",Flag, "safe_dns_tcp", translate("Pdnsd uses TCP"),
	translate("Through the server transfer mode inquires DNS pollution prevention (pdnsd,Safer and recommended)"))
safe_dns_tcp.rmempty = false
-- safe_dns_tcp:depends("more", "1")

-- more_opt = s:taboption("basic",Flag, "more", translate("More Options"),
-- 	translate("Options for advanced users"))

-- timeout = s:taboption("basic",Value, "timeout", translate("Timeout"))
-- timeout.datatype = "range(0,10000)"
-- timeout.placeholder = "60"
-- timeout.optional = false
-- timeout:depends("more", "1")

-- safe_dns = s:taboption("basic",Value, "safe_dns", translate("Safe DNS"),
-- 	translate("8.8.8.8 or 8.8.4.4 is recommended"))
-- safe_dns.datatype = "ip4addr"
-- safe_dns.optional = false
-- safe_dns:depends("more", "1")

-- safe_dns_port = s:taboption("basic",Value, "safe_dns_port", translate("Safe DNS Port"),
-- 	translate("Foreign DNS on UDP port 53 might be polluted"))
-- safe_dns_port.datatype = "range(1,65535)"
-- safe_dns_port.placeholder = "53"
-- safe_dns_port.optional = false
-- safe_dns_port:depends("more", "1")

--fast_open =s:taboption("basic",Flag, "fast_open", translate("TCP Fast Open"),
--	translate("Enable TCP fast open, only available on kernel > 3.7.0"))


-- [[ User-defined GFW-List ]]--
-- s:tab("list",  translate("User-defined GFW-List"))
-- gfwlist = s:taboption("list", TextValue, "conf")
-- gfwlist.description = translate("<br />（!）Note: When the domain name is entered and will automatically merge with the online GFW-List. Please manually update the GFW-List list after applying.")
-- gfwlist.rows = 13
-- gfwlist.wrap = "off"
-- gfwlist.cfgvalue = function(self, section)
-- 	return NXFS.readfile(conf) or ""
-- end
-- gfwlist.write = function(self, section, value)
-- 	NXFS.writefile(conf, value:gsub("\r\n", "\n"))
-- 	SYS.call("/etc/shadowsocksr/up-gfwlist.sh x> /tmp/shadowsocksr/gfwupdate.log 2>&1 &")
-- end

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
s:tab("status",  translate("Status and Tools"))
s:taboption("status", DummyValue,"opennewwindow" , 
translate("<input type=\"button\" class=\"cbi-button cbi-button-apply\" value=\"IP111.CN\" onclick=\"window.open('http://www.ip111.cn/')\" />"))

ckbaidu = s:taboption("status", DummyValue, "baidu", translate("Baidu Connectivity")) 
ckbaidu.value = translate("Not Checked") 
ckbaidu.template = "shadowsocksr/check"

ckgoogle = s:taboption("status", DummyValue, "google", translate("Google Connectivity"))
ckgoogle.value = translate("Not Checked") 
ckgoogle.template = "shadowsocksr/check"

update_gfw=s:taboption("status", DummyValue, "gfw_data", translate("GFW List Data")) 
update_gfw.template = "shadowsocksr/refresh"
update_gfw.value =gfw_count .. " " .. translate("Records")
-- ckgoogle = s:taboption("status", Button, "google", translate("Google Connectivity"))
-- ckgoogle.inputtitle = translate("No Check")
-- ckgoogle.inputstyle = "apply"
-- ckgoogle.template = "shadowsocksr/check"

-- ckgoogle.write = function()
-- 	SYS.call("sh /etc/shadowsocksr/up-gfwlist.sh > /tmp/gfwupdate.log 2>&1 &")
-- end




-- [[ Watchdog Log ]]--
s:tab("watchdog",  translate("Watchdog Log"))
log = s:taboption("watchdog", TextValue, "sylogtext")
log.template = "cbi/tvalue"
log.rows = 13
log.wrap = "off"
log.readonly="readonly"

function log.cfgvalue(self, section)
  --SYS.exec("[ -f /tmp/shadowsocksr/switch.log ] && sed '1!G;h;$!d' /tmp/shadowsocksr/switch.log > /tmp/shadowsocksr/ssrpro.log")
	return nixio.fs.readfile(dog)
end

function log.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile(dog, value)
end



t=m:section(TypedSection,"acl_rule",translate("<strong>Client Proxy Mode Settings</strong>"),
translate("Proxy mode settings can be set to specific LAN clients ( <font color=blue> No Proxy, Global Proxy, Game Mode</font>) . Does not need to be set by default."))
t.template="cbi/tblsection"
t.sortable=true
t.anonymous=true
t.addremove=true
e=t:option(Value,"ipaddr",translate("IP Address"))
e.width="40%"
e.datatype="ip4addr"
e.placeholder="0.0.0.0/0"
luci.ip.neighbors({ family = 4 }, function(entry)
	if entry.reachable then
		e:value(entry.dest:string())
	end
end)

e=t:option(ListValue,"filter_mode",translate("Proxy Mode"))
e.width="40%"
e.default="disable"
e.rmempty=false
e:value("disable",translate("No Proxy"))
e:value("global",translate("Global Proxy"))
e:value("game",translate("Game Mode"))

-- ---------------------------------------------------
local apply = luci.http.formvalue("cbi.apply")
if apply then
	--os.execute("/etc/init.d/ssrpro restart " .. currentserver .. ">/dev/null 2>&1 &")
	os.execute("/etc/init.d/ssrpro restart >/dev/null 2>&1 &")
end

return m
