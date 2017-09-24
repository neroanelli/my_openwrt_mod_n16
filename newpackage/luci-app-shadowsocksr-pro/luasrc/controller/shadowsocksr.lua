module("luci.controller.shadowsocksr", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/shadowsocksr") then
		return
	end
	-- local page
	entry({"admin", "services", "shadowsocksr"}, alias("admin", "services", "shadowsocksr", "main"), _("ShadowsocksR Pro")).dependent = true
	entry({"admin", "services", "shadowsocksr", "main"}, cbi("shadowsocksr/main"), _("ShadowsocksR Setting"), 10).leaf = true  
	entry({"admin", "services", "shadowsocksr", "check"}, call("check_status"))
	entry({"admin", "services", "shadowsocksr", "server"}, cbi("shadowsocksr/server"), _("ShadowsocksR Server"), 20).leaf = true  
	-- page.dependent = true
end

function check_status()
	local para = luci.http.formvalue("set")
	--local webaddr = "www.baidu.com"
	-- if	para == "google" then
	-- 	webaddr = "www.google.com"
	-- end
	-- if  para == "baidu" then
	-- 	webaddr = "www.baidu.com"
	-- end
	--local set ="/usr/bin/ssr-check www." .. luci.http.formvalue("set") .. ".com 80 3 1"
	--local set ="/usr/bin/wget --spider --quiet --tries=5 --timeout=3 www.gstatic.com/generate_204"
	local set ="/usr/bin/nc -z -w3 www." .. para .. ".com 80"
	sret=luci.sys.call(set)
	if sret == 0 then
 		retstring ="0"
	else
 		retstring ="1"
	end	
	luci.http.prepare_content("application/json")
	luci.http.write_json({ ret=retstring })
end