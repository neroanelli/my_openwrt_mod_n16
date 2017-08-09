module("luci.controller.policyroute", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/policyroute") then
		return
	end

	entry({"admin", "services", "policyroute"}, cbi("policyroute"), _("PolicyRoute"), 74).dependent = true
end