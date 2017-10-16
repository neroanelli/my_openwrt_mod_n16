module("luci.controller.smartroute", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/smartroute") then
		return
	end

	entry({"admin", "network", "smartroute"}, cbi("smartroute"), _("Smart Route"), 74).dependent = true
end