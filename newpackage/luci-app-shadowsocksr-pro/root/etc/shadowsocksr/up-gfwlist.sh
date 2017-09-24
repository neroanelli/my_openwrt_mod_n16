#!/bin/sh

/etc/shadowsocksr/gen-gfwlist.sh > /tmp/ol-gfw.txt
flag=1
if [ -s "/tmp/ol-gfw.txt" ];then
	sort -u /etc/shadowsocksr/base-gfwlist.txt /tmp/ol-gfw.txt > /tmp/china-banned
	if ( ! cmp -s /tmp/china-banned /etc/gfwlist/china-banned );then
		if [ -s "/tmp/china-banned" ];then
			mv /tmp/china-banned /etc/gfwlist/china-banned
			echo "Update GFW-List Done!"
			flag=0
		fi
	else
		echo "GFW-List No Change!"
		flag=1
	fi
fi

rm -f /tmp/gfwlist.txt
rm -f /tmp/ol-gfw.txt
[ "$flag" = 0 ] && /etc/init.d/ssrpro restart
