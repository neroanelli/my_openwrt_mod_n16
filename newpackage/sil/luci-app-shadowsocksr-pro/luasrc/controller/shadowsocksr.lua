-- Copyright (C) 2017 by Sil
-- Licensed to the public under the GNU General Public License v3.
local uci = luci.model.uci.cursor()
module("luci.controller.shadowsocksr", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/shadowsocksr") then
		return
	end
	-- local page
	entry({"admin", "services", "shadowsocksr"}, alias("admin", "services", "shadowsocksr", "main"), _("ShadowsocksR Pro")).dependent = true
	entry({"admin", "services", "shadowsocksr", "main"}, cbi("shadowsocksr/main"), _("ShadowsocksR Setting"), 10).leaf = true  
	entry({"admin", "services", "shadowsocksr", "check"}, call("check_status"))
	entry({"admin", "services", "shadowsocksr", "refresh"}, call("refresh_data"))
	entry({"admin", "services", "shadowsocksr", "server"}, cbi("shadowsocksr/server"), _("ShadowsocksR Server"), 20).leaf = true  
	entry({"admin", "services", "shadowsocksr", "custom"}, cbi("shadowsocksr/custom"), _("ShadowsocksR Custom"), 30).leaf = true  
	entry({"admin", "services", "shadowsocksr", "status"},call("act_status")).leaf=true
	entry({"admin", "services", "shadowsocksr", "server_status"},call("server_status")).leaf=true
	-- entry({"admin", "services", "shadowsocksr", "client"}, cbi("shadowsocksr/client"), _("ShadowsocksR client"))
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
	--local set ="/usr/bin/wget --spider --quiet --tries=5 --timeout=3 www.gstatic.com/generate_204"
	--local set ="/usr/bin/nc -z -w3 www." .. para .. ".com 80"
	--local set ="/usr/bin/ssr-check www." .. para .. ".com 80 3 1"
	local set ="curl -m 3 -o /dev/null -s www." .. para .. ".com:80"
	sret=luci.sys.call(set)
	if sret == 0 then
 		retstring ="0"
	else
 		retstring ="1"
	end	
	luci.http.prepare_content("application/json")
	luci.http.write_json({ ret=retstring })
end


function act_status()
	local currentserver = ""
	local shadowsocksr = "shadowsocksr"
	local currentserver_name = ""
	local server_table = {}
	local e= {}
	uci:foreach(shadowsocksr, "servers", function(s)
		if s.alias then
			server_table[s[".name"]] = s.alias
		elseif s.server and s.server_port then
			server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
		end
	end)
	uci:unload(shadowsocksr)
	currentserver=string.gsub(luci.sys.exec("cat /tmp/shadowsocksr/currentserver 2>/dev/null"), "^%s*(.-)%s*$", "%1")
	if (string.len(currentserver)) == 0 then
		currentserver_name = "empty"
	else
		currentserver_name = server_table[currentserver]
	end
	e.shadowsocksr=luci.sys.call("pidof ssr-redir > /dev/null") == 0
	e.servername=currentserver_name
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function server_status()
local set=""
local server_name = ""
local shadowsocksr = "shadowsocksr"
local data = {}	-- Array to transfer data to javascript

uci:foreach(shadowsocksr, "servers", function(s)
	section = s[".name"]
	if s.alias then
		server_name=s.alias
	elseif s.server and s.server_port then
		server_name= "%s:%s" %{s.server, s.server_port}
	end
	socket = nixio.socket("inet", "stream")
	socket:setopt("socket", "rcvtimeo", 3)
	socket:setopt("socket", "sndtimeo", 3)
	ret=socket:connect(s.server,s.server_port)
	if  tostring(ret) == "true" then
		socket:close()
		status = true
	else
		status = false
	end
	--ping = luci.sys.exec("ping -c 1 " .. s.server .. "| grep round-trip | awk -F '/' '{ print $4 }'")
	if	status then
		ping = luci.sys.exec("curl -m 1 -o /dev/null -s -w %{time_connect} " .. s.server .. ":" .. s.server_port)
	else
		ping = "0.00"
	end

	data[#data+1]	= {
		section = section,
		status  = status,
		ping    = ping
	}
end)

uci:unload(shadowsocksr)

luci.http.prepare_content("application/json")
luci.http.write_json(data)
end

function refresh_data()
	local set =luci.http.formvalue("set")
	local icount =0
	
	if set == "gfw_data" then
		sret=luci.sys.call("sh /etc/shadowsocksr/up-gfwlist.sh > /tmp/shadowsocksr/gfwupdate.log 2>/dev/null")
		if sret== 0 then
			retstring ="0"
		else
			icount = luci.sys.exec("cat /etc/gfwlist/china-banned | wc -l")
			retstring = icount
		end
		

	-- elseif set == "ip_data" then
	-- 	refresh_cmd="wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'  2>/dev/null| awk -F\\| '/CN\\|ipv4/ { printf(\"%s/%d\\n\", $4, 32-log($5)/log(2)) }' > /tmp/china_ssr.txt"
	--  	sret=luci.sys.call(refresh_cmd)
	--  	icount = luci.sys.exec("cat /tmp/china_ssr.txt | wc -l")
	-- 	if  sret== 0 and tonumber(icount)>1000 then
	-- 		oldcount=luci.sys.exec("cat /etc/china_ssr.txt | wc -l")
	-- 		if tonumber(icount) ~= tonumber(oldcount) then
	--    			luci.sys.exec("cp -f /tmp/china_ssr.txt /etc/china_ssr.txt")
	--    			retstring=tostring(tonumber(icount))
	--   		else
	--    			retstring ="0"
	--  		 end
	--  else
	--   	retstring ="-1"
	--  end
	--  luci.sys.exec("rm -f /tmp/china_ssr.txt ")
	-- else
	--   if nixio.fs.access("/usr/bin/wget-ssl") then
	--   refresh_cmd="wget --no-check-certificate -O - https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt | grep ^\\|\\|[^\\*]*\\^$ | sed -e 's:||:address\\=\\/:' -e 's:\\^:/127\\.0\\.0\\.1:' > /tmp/ad.conf"
	--  else
	--   refresh_cmd="wget -O /tmp/ad.conf http://iytc.net/tools/ad.conf"
	--  end
	--  sret=luci.sys.call(refresh_cmd .. " 2>/dev/null")
	--  if sret== 0 then
	--   icount = luci.sys.exec("cat /tmp/ad.conf | wc -l")
	--   if tonumber(icount)>1000 then
	--    if nixio.fs.access("/etc/dnsmasq.ssr/ad.conf") then
	--     oldcount=luci.sys.exec("cat /etc/dnsmasq.ssr/ad.conf | wc -l")
	--    else
	--     oldcount=0
	--    end
	   
	--    if tonumber(icount) ~= tonumber(oldcount) then
	--     luci.sys.exec("cp -f /tmp/ad.conf /etc/dnsmasq.ssr/ad.conf")
	--     retstring=tostring(math.ceil(tonumber(icount)))
	--     if oldcount==0 then
	--      luci.sys.call("/etc/init.d/dnsmasq restart")
	--     end
	--    else
	--     retstring ="0"
	--    end
	--   else
	--    retstring ="-1"  
	--   end
	--   luci.sys.exec("rm -f /tmp/ad.conf ")
	--  else
	--   retstring ="-1"
	--  end
	end	
	luci.http.prepare_content("application/json")
	luci.http.write_json({ ret=retstring ,retcount=icount})
end