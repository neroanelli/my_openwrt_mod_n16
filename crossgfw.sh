# sudo umount /dev/sdb1 
# sudo mkdir -p /mnt/sdb 
# sudo mount -w /dev/sdb1 /mnt/sdb  
# sudo chmod -R 777 /dev/sdb  

git clone https://github.com/clowwindy/ChinaDNS-C.git
cd ChinaDNS-C
./autogen.sh 
./configure && make
sudo nohup ./src/chinadns -l iplist.txt -c chnroute.txt &
cd ..

git clone https://github.com/madeye/shadowsocks-libev.git
cd shadowsocks-libev

sudo apt-get install build-essential autoconf libtool libssl-dev -y
./configure && make
sudo make install

cd ..
sudo apt-get install ipset -y
ipset_whitelist=~/whitelist
redir_port=1080
# Create new chain
sudo iptables -t nat -N SHADOWSOCKS

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
sudo iptables -t nat -A SHADOWSOCKS -d 116.251.209.170 -j RETURN

# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
# See ashi009/bestroutetb for a highly optimized CHN route list.
sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

# Anything else should be redirected to shadowsocks's local port
#iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports 1080
sed -e "s/^/-A whitelist &/g" -e "1 i\-N whitelist nethash --hashsize 4096" $ipset_whitelist | sudo ipset -R -!
sudo iptables -t nat -A SHADOWSOCKS -p tcp -m set ! --match-set whitelist dst -j REDIRECT --to-ports $redir_port
# Apply the rules
sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS

# Start the shadowsocks-redir
sudo nohup ss-redir -c ~/shadowsocks.json -f /var/run/shadowsocks.pid &
