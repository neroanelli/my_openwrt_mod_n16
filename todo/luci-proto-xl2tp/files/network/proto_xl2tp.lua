--[[
LuCI - Network model - xl2tp protocol extension

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

]]--

local netmod = luci.model.network
local _, p
for _, p in ipairs({"xl2tp"}) do

	local proto = netmod:register_protocol(p)

	function proto.get_i18n(self)
		if p == "xl2tp" then
			return luci.i18n.translate("L2TP/IPSec")
		end
	end

	function proto.ifname(self)
		return p .. "-" .. self.sid
	end

	function proto.opkg_package(self)
		if p == "xl2tp" then
			return "xl2tpd"
		end
	end

	function proto.is_installed(self)
		if p == "xl2tp" then
			return nixio.fs.access("/lib/netifd/proto/xl2tp.sh")
		end
	end

	function proto.is_floating(self)
		return true
	end

	function proto.is_virtual(self)
		return true
	end
--[[
	function proto.get_interface(self)
		return interface(self:ifname(), self)
	end

	function proto.contains_interface(self, ifc)
		return (netmod:ifnameof(ifc) == self:ifname())
	end
]]--
	function proto.get_interfaces(self)
		return nil
	end

	function proto.contains_interface(self, ifc)
		return (netmod:ifnameof(ifc) == self:ifname())
	end

	netmod:register_pattern_virtual("^%s-%%w" % p)
end
