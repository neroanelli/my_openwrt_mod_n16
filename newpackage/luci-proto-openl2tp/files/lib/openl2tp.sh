#!/bin/sh

[ -x /usr/sbin/openl2tpd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	. /lib/functions/network.sh
	init_proto "$@"
}

proto_openl2tp_init_config() {
	proto_config_add_string "server"
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_int "mtu"
	proto_config_add_boolean "ipv6"
	proto_config_add_boolean "defaultroute"
	proto_config_add_boolean "peerdns"
	proto_config_add_string "oif"
	proto_config_add_string "pppd_options"
	available=1
	no_device=1
}

proto_openl2tp_setup() {
	local config="$1"; shift
	local iface="$2"
	local ifname="openl2tp-$config"
	local optfile="/tmp/openl2tp/options.${config}"
	local RPC="portmap"
	local L2TP="openl2tpd"
	local CONF="l2tpconfig"

	local ip serv_addr server ipv6 defaultroute peerdns oif
	json_get_var oif oif
	json_get_var server server && {
		for ip in $(resolveip -t 5 "$server"); do
			#support nwan add by neroanelli
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
			echo "depending interface $oif is up"
			break
		else
			echo "depending interface $oif is not up"
			sleep 3
		fi
	done
	
	json_get_vars username password ipv6 defaultroute peerdns pppd_options
	if [ "$ipv6" = 1 ]; then
		ipv6=1
	else
		ipv6=""
	fi
	if [ "$defaultroute" = 0 ]; then
		defaultroute=""
	else
		defaultroute=1
	fi

	if [ "$peerdns" = 0 ]; then
		peerdns=""
	else
		peerdns=1
	fi

	[ -n "$mtu" ] || json_get_var mtu mtu

	# local load
	# for module in slhc ppp_generic ppp_async ppp_mppe ip_gre gre pptp; do
		# grep -q "^$module " /proc/modules && continue
		# /sbin/insmod $module 2>&- >&-
		# load=1
	# done
	# [ "$load" = "1" ] && sleep 1
    echo "UP@Checking for IPSec... "
	pidfile=/var/run/starter.charon.pid
	if [ -e $pidfile ]; then
		pid=`cat $pidfile`
		if kill -0 1> /dev/null 2>&1 $pid; then
			echo "ipsec is running... "
			ipsec down l2tp-psk-client
			ipsec up l2tp-psk-client
		else
			echo "ipsec is not running... "
			ipsec start
			sleep 2
			ipsec up l2tp-psk-client
		fi
	else
		echo "ipsec is not running... "
		ipsec start
		sleep 2
		ipsec up l2tp-psk-client
	fi
	
	echo "UP@Checking for $RPC... "
	if ! pidof $RPC 1> /dev/null 2> /dev/null; then
		echo "Starting $RPC... "
		RPC_PROG=`which $RPC`
		if [ -n "$RPC_PROG" ] && [ -x $RPC_PROG ] && start-stop-daemon -q -S -x $RPC_PROG; then
			echo "done"
		else
			echo "failed"
			return 1
		fi
	fi
	
	echo "UP@Checking for $L2TP... "
	L2TP_PROG=`which $L2TP`
	if [ -n "$L2TP_PROG" ] && [ -x $L2TP_PROG ]; then
		echo "yes"
	else
		echo "no"
		return 1
	fi
	
	echo "UP@Checking for $CONF... "
	CONF_PROG=`which $CONF`
	if [ -n "$CONF_PROG" ] && [ -x $CONF_PROG ]; then
		echo "yes"
	else
		echo "no"
		return 1
	fi

	echo "UP@Starting $L2TP... "
	#/usr/sbin/openl2tpd -D
	if ! start-stop-daemon -q -S -x $L2TP_PROG; then
		start-stop-daemon -q -K -x $L2TP_PROG
	fi
	sleep 1
	
	mkdir -p /tmp/openl2tp

	echo "usepeerdns" >> "${optfile}"
	echo "nodefaultroute" >> "${optfile}"
	#echo "${username:+user \"$username\" password \"$password\"}" >> "${optfile}"
	echo "ipparam \"$config\"" >> "${optfile}"
	echo "ifname \"openl2tp-$config\"" >> "${optfile}"
	echo "ip-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ipv6-up-script /lib/netifd/ppp-up" >> "${optfile}"
	echo "ip-down-script /lib/netifd/ppp-down" >> "${optfile}"
	echo "ipv6-down-script /lib/netifd/ppp-down" >> "${optfile}"
	# Don't wait for LCP term responses; exit immediately when killed.
	echo "lcp-max-terminate 0" >> "${optfile}"
	#echo "${ipv6:++ipv6} ${pppd_options}" >> "${optfile}"
	echo "${mtu:+mtu $mtu}" >> "${optfile}"
	#echo "${mtu:+mtu $mtu mru $mtu}" >> "${optfile}"
	# Support L2TP/IPSec add by neroanelli
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
	echo "$pppd_options" >> "${optfile}"
	
	echo "Establishing tunnel... "
	#( echo "peer profile modify profile_name=default"
	#( echo "ppp profile modify profile_name=default mtu=1000 auth_peer=no auth_pap=yes auth_eap=no auth_mschapv1=no auth_mschapv2=no default_route=no lcp_echo_interval=3600 lcp_echo_failure_count=300"
	( echo "system modify tunnel_establish_timeout=10 session_establish_timeout=10 tunnel_persist_pend_timeout=10 session_persist_pend_timeout=8"
	echo "ppp profile modify profile_name=default optionsfile=$optfile"
	echo "tunnel profile modify profile_name=default our_udp_port=1701"
	echo "tunnel create tunnel_name=corbina hello_timeout=8 retry_timeout=3 dest_ipaddr=$server persist=yes"
	echo "quit" ) | $CONF_PROG 1> /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "failed"
		rm -f /var/run/$L2TP.pid
		rm -f ${optfile}
		return 1
	fi
	
	( echo "session create tunnel_name=corbina session_name=corbina interface_name=$ifname user_name=$username user_password=$password"
	echo "quit" ) | $CONF_PROG 1> /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "failed"
		rm -f /var/run/$L2TP.pid
		rm -f ${optfile}
		return 1
	fi

	#proto_init_update "$ifname" 1 1
	#proto_send_update "$config"
	
	#proto_run_command "$config" openl2tpd \
	#	-c /etc/openl2tpd.conf \
	#	-D 
}

proto_openl2tp_teardown() {
	local interface="$1"
	local ifname="openl2tp-$interface"
	local optfile="/tmp/openl2tp/options.${interface}"
	local L2TP="openl2tpd"
	local CONF="l2tpconfig"
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
	#proto_kill_command "$interface"
	#rm -f /var/run/openl2tpd.pid 
	echo "DOWN@Checking for $L2TP... "
	L2TP_PROG=`which $L2TP`
	if [ -n "$L2TP_PROG" ] && [ -x $L2TP_PROG ]; then
		echo "yes"
	else
		echo "no"
		return 1
	fi
 
	echo "DOWN@Checking for $CONF... "
	CONF_PROG=`which $CONF`
	if [ -n "$CONF_PROG" ] && [ -x $CONF_PROG ]; then
		echo "yes"
	else
		echo "no"
		return 1
	fi
	
	echo "DOWN@Deleting tunnel... "
	( echo "session delete tunnel_name=corbina session_name=corbina"
	echo "quit" ) | $CONF_PROG 1> /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "failed"
	else
	( echo "tunnel delete tunnel_name=corbina"
	echo "quit" ) | $CONF_PROG 1> /dev/null 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "failed"
		else
			echo "done"
		fi
	fi
	rm -f ${optfile}
	echo "DOWN@Stopping $L2TP... "
	if ! start-stop-daemon -q -K -x $L2TP_PROG; then
		echo "not running"
		return 1
	else
		echo "del"
		rm -f /var/run/$L2TP.pid
		echo "done"
	fi
	ipsec down l2tp-psk-client
	#proto_init_update "$ifname" 0
	#proto_send_update "$interface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol openl2tp
}
