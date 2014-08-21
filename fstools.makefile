/pack/sys/fst/
#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#



define Package/block-mount/install
	$(INSTALL_DIR) $(1)/sbin $(1)/usr/sbin $(1)/etc/hotplug.d/block $(1)/etc/init.d/ $(1)/etc/uci-defaults/ $(1)/lib/functions/

	$(INSTALL_BIN) ./files/fstab.init $(1)/etc/init.d/fstab
	$(INSTALL_DATA) ./files/fstab.default $(1)/etc/uci-defaults/10-fstab
	$(INSTALL_DATA) ./files/mount.hotplug $(1)/etc/hotplug.d/block/10-mount
	$(INSTALL_DATA) ./files/20-swap $(1)/etc/hotplug.d/block/20-swap
	$(INSTALL_DATA) ./files/mount.sh $(1)/lib/functions/mount.sh
	$(INSTALL_DATA) ./files/block.sh $(1)/lib/functions/block.sh

