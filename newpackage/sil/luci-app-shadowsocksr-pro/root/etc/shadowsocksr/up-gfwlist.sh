#!/bin/sh

online_list=/tmp/shadowsocksr/online-gfwlist.txt
original_list=/etc/shadowsocksr/original-gfwlist.txt
user_defined_list=/etc/shadowsocksr/user-defined-gfwlist.txt
mode=$1
flag=0

generate_china_banned(){
	
		cat $1 | base64 -d > /tmp/gfwlist.txt
		rm -f $1


	cat /tmp/gfwlist.txt | sort -u |
		sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' |
		sed '/\*/d; /apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /byr\.cn/d; /jlike\.com/d; /weibo\.com/d; /zhongsou\.com/d; /youdao\.com/d; /sogou\.com/d; /so\.com/d; /soso\.com/d; /aliyun\.com/d; /taobao\.com/d; /jd\.com/d; /qq\.com/d' |
		sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' |
		grep '^[0-9a-zA-Z\.-]\+$' | grep '\.' | sed 's#^\.\+##' | sort -u |
		awk '
BEGIN { prev = "________"; }  {
	cur = $0;
	if (index(cur, prev) == 1 && substr(cur, 1 + length(prev) ,1) == ".") {
	} else {
		print cur;
		prev = cur;
	}
}' | sort -u

}

if [ -z "$mode" ] ;then
	#update online gfwlist.
	if [ -x /usr/bin/wget-ssl ]; then
		refresh_cmd="wget-ssl --no-check-certificate https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt -O /tmp/gfwlist.b64 2>/dev/null"
	else
		refresh_cmd="wget -O /tmp/gfwlist.b64 http://iytc.net/tools/list.b64 2>/dev/null"
	fi
	eval $refresh_cmd
	if [ "$?" == "0" ]; then
		generate_china_banned /tmp/gfwlist.b64 > $online_list
	fi
	rm -f /tmp/gfwlist.txt
	if [ -s $online_list ];then
		if ( ! cmp -s $online_list $original_list );then
			mv $online_list $original_list
			echo "GFW-List updated!"
			flag=1
			sort -u $original_list $user_defined_list > /tmp/shadowsocksr/china-banned
			if ( ! cmp -s /tmp/shadowsocksr/china-banned /etc/gfwlist/china-banned );then
				if [ -s "/tmp/shadowsocksr/china-banned" ];then
					mv /tmp/shadowsocksr/china-banned /etc/gfwlist/china-banned
					echo "Update GFW-List Done!"
					flag=1
				fi
			else
				echo "GFW-List No Change!"
				flag=0
			fi
		else
			echo "GFW-List No Change!"
		fi
	fi
		rm -f /tmp/shadowsocksr/gfwlist.txt
		rm -f /tmp/shadowsocksr/online-gfwlist.txt
else
	#update user defined gfwlist.
	sort -u $original_list $user_defined_list > /tmp/shadowsocksr/china-banned
	if ( ! cmp -s /tmp/shadowsocksr/china-banned /etc/gfwlist/china-banned );then
		if [ -s "/tmp/shadowsocksr/china-banned" ];then
			mv /tmp/shadowsocksr/china-banned /etc/gfwlist/china-banned
			echo "Update Custom-List Done!"
			flag=1
		fi
	else
		echo "Custom-List No Change!"
		flag=0
	fi
	rm -f /tmp/shadowsocksr/china-banned
fi

[ "$flag" = 1 ] && /etc/init.d/ssrpro restart dnsmasq
return $flag

