#!/bin/sh

[ -x /usr/sbin/xl2tpd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_xl2tp_init_config() {
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_string "keepalive"
	proto_config_add_string "pppd_options"
	proto_config_add_boolean "ipv6"
	proto_config_add_int "mtu"
	proto_config_add_string "server"
    proto_config_add_string "oif"
	available=1
	no_device=1
}

proto_xl2tp_setup() {
	local config="$1"
	local iface="$2"
	local optfile="/tmp/xl2tp/options.${config}"

	local ip serv_addr server oif
    json_get_var oif oif
	json_get_var server server && {
		for ip in $(resolveip -t 5 "$server"); do
			#support nwan add by neroanelli
			#( proto_add_host_dependency "$config" "$ip" )
            ( proto_add_host_dependency "$config" "$ip" $oif )
			serv_addr=1
		done
	}
	[ -n "$serv_addr" ] || {
		echo "Could not resolve server address"
		sleep 5
		proto_setup_failed "$config"
		exit 1
	}
    ##check the depending interface is running or not 
	echo "Check depending interface"
	while true; do
		if network_is_up $oif; then
			echo "OK"
			break
		else
			echo "depending interface $oif is not up"
			sleep 3
		fi
	done
	#/etc/init.d/racoon restart
	pidfile=/var/run/starter.charon.pid
	if [ -e $pidfile ]; then
		pid=`cat $pidfile`
		if kill -0 1> /dev/null 2>&1 $pid; then
			ipsec down l2tp-psk-client
			ipsec up l2tp-psk-client
		else
			ipsec start
			sleep 2
			ipsec up l2tp-psk-client
		fi
	fi
	
	if [ ! -p /var/run/xl2tpd/l2tp-control ]; then
		/etc/init.d/xl2tpd start
	fi

	json_get_vars ipv6 demand keepalive username password pppd_options
	[ "$ipv6" = 1 ] || ipv6=""
	if [ "${demand:-0}" -gt 0 ]; then
		demand="precompiled-active-filter /etc/ppp/filter demand idle $demand"
	else
		demand="persist"
	fi

	[ -n "$mtu" ] || json_get_var mtu mtu

	local interval="${keepalive##*[, ]}"
	[ "$interval" != "$keepalive" ] || interval=5

	mkdir -p /tmp/xl2tp

	echo "${keepalive:+lcp-echo-interval $interval lcp-echo-failure ${keepalive%%[, ]*}}" > "${optfile}"
	echo "usepeerdns" >> "${optfile}"
	echo "nodefaultroute" >> "${optfile}"
	echo "${username:+user \"$username\" password \"$password\"}" >> "${optfile}"
	echo "ipparam \"$config\"" >> "${optfile}"
	echo "ifname \"xl2tp-$config\"" >> "${optfile}"
	echo "ip-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ipv6-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ip-down-script /lib/netifd/ppp-down" >> "${optfile}"
	echo "ipv6-down-script /lib/netifd/ppp-down" >> "${optfile}"
	# Don't wait for LCP term responses; exit immediately when killed.
	echo "lcp-max-terminate 0" >> "${optfile}"
	#echo "${ipv6:++ipv6} ${pppd_options}" >> "${optfile}"
	echo "${mtu:+mtu $mtu}" >> "${optfile}"
	#echo "${mtu:+mtu $mtu mru $mtu}" >> "${optfile}"
	# Support l2tp/ipSec add by neroanelli
	echo "lock" >> "${optfile}"
	echo "debug" >> "${optfile}"
	echo "noauth" >> "${optfile}"
	echo "kdebug 1" >> "${optfile}"
	echo "refuse-chap" >> "${optfile}"
	echo "refuse-mschap" >> "${optfile}"
	echo "refuse-mschap-v2" >> "${optfile}"
	echo "nobsdcomp" >> "${optfile}"
	echo "nodeflate" >> "${optfile}"
	echo "noaccomp" >> "${optfile}"
	echo "nopcomp" >> "${optfile}"
	echo "novj" >> "${optfile}"
	#echo "noccp" >> "${optfile}"
	#echo "novjccomp" >> "${optfile}"
	echo "lcp-echo-interval 3600" >> "${optfile}"
	echo "lcp-echo-failure 50" >> "${optfile}"
	#echo "name $username" >> "${optfile}"
	echo "$pppd_options" >> "${optfile}"

	xl2tpd-control add xl2tp-${config} \
	"pppoptfile=$optfile" \
	"lns=$server" \
	"require pap = yes" \
	"bps = 1000000" \
	"ppp debug = yes" \
	"redial=yes" \
	"redial timeout=15"
	xl2tpd-control connect xl2tp-${config} 
	#echo "c connect" > /var/run/xl2tpd/l2tp-control
}

proto_xl2tp_teardown() {
	local interface="$1"
	local optfile="/tmp/xl2tp/options.${interface}"

	case "$ERROR" in
		11|19)
			proto_notify_error "$interface" AUTH_FAILED
			proto_block_restart "$interface"
		;;
		2)
			proto_notify_error "$interface" INVALID_OPTIONS
			proto_block_restart "$interface"
		;;
	esac

	xl2tpd-control disconnect xl2tp-${interface}
	# Wait for interface to go down
        while [ -d /sys/class/net/xl2tp-${interface} ]; do
		sleep 1
	done
	#/etc/init.d/racoon stop
	xl2tpd-control remove xl2tp-${interface}
	rm -f ${optfile}
	/etc/init.d/xl2tpd stop
	#/etc/init.d/racoon stop
	ipsec down l2tp-psk-client
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol xl2tp
}
