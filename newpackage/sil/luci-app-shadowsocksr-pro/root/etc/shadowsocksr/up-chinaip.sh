#!/bin/sh

online_list=/tmp/shadowsocksr/china-ip.txt
original_list=/etc/shadowsocksr/china-ip.txt
temp_list=/tmp/china-ip.ipset
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $online_list
if [ "$?" == "0" ]; then
	if [ -s $online_list ];then
		if ( ! cmp -s $online_list $original_list );then
			mv $online_list $original_list
			awk '!/^$/&&!/^#/{printf("add china-ip %s'" "'\n",$0)}' $original_list > $temp_list
			ipset destroy china-ip 2>/dev/null
			ipset -! create china-ip hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null
			#sed -i "s/cfg_gfwlist/$cfg_gfwlist/g" /tmp/addinip.ipset
			ipset -! restore < $temp_list
			echo "Update China IP Data Done!"
			flag=1
		else
			echo "China IP Data No Change!"
			flag=0
		fi
	fi
	rm -f $online_list
	rm -f $temp_list
else
	echo "Download China IP Data failed."
fi


# mode=$1
# if [ -z "$mode" ] ;then
	# /etc/shadowsocksr/gen-gfwlist.sh > /tmp/ol-gfw.txt
	# flag=0
	# if [ -s "/tmp/ol-gfw.txt" ];then
		# sort -u /etc/shadowsocksr/base-gfwlist.txt /tmp/ol-gfw.txt > /tmp/china-banned
		# if ( ! cmp -s /tmp/china-banned /etc/gfwlist/china-banned );then
			# if [ -s "/tmp/china-banned" ];then
				# mv /tmp/china-banned /etc/gfwlist/china-banned
				# echo "Update GFW-List Done!"
				# flag=1
			# fi
		# else
			# echo "GFW-List No Change!"
			# flag=0
		# fi
	# fi
	# rm -f /tmp/gfwlist.txt
	# rm -f /tmp/ol-gfw.txt
# else
	# sort -u /etc/shadowsocksr/base-gfwlist.txt /etc/gfwlist/china-banned > /tmp/china-banned
	# if ( ! cmp -s /tmp/china-banned /etc/gfwlist/china-banned );then
		# if [ -s "/tmp/china-banned" ];then
			# mv /tmp/china-banned /etc/gfwlist/china-banned
			# echo "Update Custom-List Done!"
			# flag=0
			# fi
		# else
			# echo "Custom-List No Change!"
			# flag=0
	# fi
# fi

# [ "$flag" = 1 ] && /etc/init.d/dnsmasq restart
# return $flag

# dns_start(){
	# mkdir -p /var/etc/dnsmasq-go.d
	# ###### Anti-pollution configuration ######
	# if [ -n "$cfg_safe_dns" ]; then
		# if [ "$cfg_safe_dns_tcp" = 1 ]; then
			# start_pdnsd "$cfg_safe_dns"
			# awk -vs="127.0.0.1#$PDNSD_LOCAL_PORT" '!/^$/&&!/^#/{printf("server=/%s/%s\n",$0,s)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/01-pollution.conf
		# else
			# awk -vs="$cfg_safe_dns#$cfg_safe_dns_port" '!/^$/&&!/^#/{printf("server=/%s/%s\n",$0,s)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/01-pollution.conf
		# fi
	# else
		# echo "WARNING: Not using secure DNS, DNS resolution might be polluted if you are in China."
	# fi

	# ###### dnsmasq-to-ipset configuration ######
	# case "$cfg_proxy_mode" in
		# M|V)
			# awk '!/^$/&&!/^#/{printf("ipset=/%s/'"$cfg_gfwlist"'\n",$0)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/02-ipset.conf
			# ;;
	# esac

	# # -----------------------------------------------------------------
	# ###### Restart main 'dnsmasq' service if needed ######
	# if ls /var/etc/dnsmasq-go.d/* >/dev/null 2>&1; then
		# mkdir -p /tmp/dnsmasq.d
		# cat > /tmp/dnsmasq.d/dnsmasq-go.conf <<EOF
# conf-dir=/var/etc/dnsmasq-go.d
# EOF
		# /etc/init.d/dnsmasq restart
	# fi


# }
	# mkdir -p /var/etc/dnsmasq-go.d
	# ###### Anti-pollution configuration ######
	# if [ -n "$cfg_safe_dns" ]; then
		# if [ "$cfg_safe_dns_tcp" = 1 ]; then
			# start_pdnsd "$cfg_safe_dns"
			# awk -vs="127.0.0.1#$PDNSD_LOCAL_PORT" '!/^$/&&!/^#/{printf("server=/%s/%s\n",$0,s)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/01-pollution.conf
		# else
			# awk -vs="$cfg_safe_dns#$cfg_safe_dns_port" '!/^$/&&!/^#/{printf("server=/%s/%s\n",$0,s)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/01-pollution.conf
		# fi
	# else
		# echo "WARNING: Not using secure DNS, DNS resolution might be polluted if you are in China."
	# fi

	# ###### dnsmasq-to-ipset configuration ######
	# case "$cfg_proxy_mode" in
		# M|V)
			# awk '!/^$/&&!/^#/{printf("ipset=/%s/'"$cfg_gfwlist"'\n",$0)}' \
				# /etc/gfwlist/$cfg_gfwlist > /var/etc/dnsmasq-go.d/02-ipset.conf
			# ;;
	# esac

	# # -----------------------------------------------------------------
	# ###### Restart main 'dnsmasq' service if needed ######
	# if ls /var/etc/dnsmasq-go.d/* >/dev/null 2>&1; then
		# mkdir -p /tmp/dnsmasq.d
		# cat > /tmp/dnsmasq.d/dnsmasq-go.conf <<EOF
# conf-dir=/var/etc/dnsmasq-go.d
# EOF
		# /etc/init.d/dnsmasq restart
	# fi