-- Copyright (C) 2017 yushi studio <ywb94@qq.com> github.com/ywb94
-- Licensed to the public under the GNU General Public License v3.

local m, s, o, plugin_param, obfs_param
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")
local fs = require "nixio.fs"
local sys = require "luci.sys"
local sid = arg[1]


local server_table = {}
local arp_table = luci.sys.net.arptable() or {}
local method = {
	"rc4",
	"rc4-md5",
	"rc4-md5-6",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",	
	"bf-cfb",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"cast5-cfb",
	"des-cfb",
	"idea-cfb",
	"rc2-cfb",
	"seed-cfb",
	"salsa20",
	"chacha20",
	"chacha20-ietf",

}

local protocol = {
	"origin",
	"verify_simple",
	"verify_deflate",
	"verify_sha1",		
	"auth_sha1",
	"auth_sha1_v2",
	"auth_sha1_v4",
	"auth_aes128_sha1",
	"auth_aes128_md5",
	"auth_chain_a",
	"auth_chain_b",
	"auth_chain_c",
	"auth_chain_d",
}

obfs = {
	"plain",
	"http_simple",
	"random_head",
	"http_post",
	"tls_simple",	
	"tls1.2_ticket_auth",
}

m = Map("shadowsocksr", translate("Edit ShadowSocksR Server"))
m.redirect = luci.dispatcher.build_url("admin/services/shadowsocksr")

if sid == nil or m.uci:get("shadowsocksr", sid) ~= "servers" then
	-- luci.http.redirect(m.redirect) 
	-- return
	uci:foreach("shadowsocksr", "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = s.alias
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
	end)

-- [[ addon Servers Setting ]]--

	sec = m:section(TypedSection, "servers", translate("Servers"))
	sec.anonymous = true
	sec.addremove = true
	sec.sortable = true
	sec.template = "cbi/tblsection"
	sec.extedit = luci.dispatcher.build_url("admin/services/shadowsocksr/server/%s")
	function sec.create(...)
		local sid = TypedSection.create(...)
		if sid then
			luci.http.redirect(sec.extedit % sid)
			return
		end
	end

	o = sec:option(DummyValue, "alias", translate("Alias"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or translate("None")
	end
	
	
	o = sec:option(DummyValue, "server", translate("Server Address"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "?"
	end
	
	o = sec:option(DummyValue, "server_port", translate("Server Port"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "?"
	end
	
	o = sec:option(DummyValue, "method", translate("Encrypt Method"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "?"
	end
	
	o = sec:option(DummyValue, "protocol", translate("Protocol"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "?"
	end
	
	
	o = sec:option(DummyValue, "obfs", translate("Obfs"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "?"
	end
	
	
	o = sec:option(DummyValue, "switch_enable", translate("Auto Switch"))
	function o.cfgvalue(...)
		return Value.cfgvalue(...) or "0"
	end


else



	-- [[ Servers Setting ]]--
	s = m:section(NamedSection, sid, "servers")
	s.anonymous = true
	s.addremove = false
	
	o = s:option(Value, "alias", translate("Alias(optional)"))
	
	-- o = s:option(Flag, "auth_enable", translate("Onetime Authentication"))
	-- o.rmempty = false
	
	o = s:option(Flag, "switch_enable", translate("Auto Switch"))
	o.rmempty = false
	
	o = s:option(Value, "server", translate("Server Address"))
	o.datatype = "host"
	o.rmempty = false
	
	o = s:option(Value, "server_port", translate("Server Port"))
	o.datatype = "port"
	o.rmempty = false
	
	o = s:option(Value, "timeout", translate("Connection Timeout"))
	o.datatype = "uinteger"
	o.default = 60
	o.rmempty = false
	
	o = s:option(Value, "password", translate("Password"))
	o.password = true
	o.rmempty = false
	
	o = s:option(ListValue, "method", translate("Encrypt Method"))
	for _, v in ipairs(method) do o:value(v) end
	o.rmempty = false
	
	o = s:option(ListValue, "protocol", translate("Protocol"))
	for _, v in ipairs(protocol) do o:value(v) end
	o.rmempty = false
	
	
	o = s:option(ListValue, "obfs", translate("Obfs"))
	for _, v in ipairs(obfs) do o:value(v) end
	o.rmempty = false
	
	plugin_param = s:option(Flag, "plugin_param", translate("Plug-in parameters"),
		translate("Incorrect use of this parameter will cause IP to be blocked. Please use it with care"))
	plugin_param:depends("obfs", "http_simple")
	plugin_param:depends("obfs", "http_post")
	plugin_param:depends("obfs", "tls1.2_ticket_auth")
	plugin_param:depends("obfs", "tls1.2_ticket_fastauth")
	
	obfs_param = s:option(Value, "obfs_param", translate("Confusing plug-in parameters"))
	obfs_param.rmempty = true
	obfs_param.datatype = "host"
	obfs_param:depends("plugin_param", "1")
	
	o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
	o.rmempty = false
end
return m
