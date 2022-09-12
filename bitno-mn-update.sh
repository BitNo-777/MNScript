#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'bitnod' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop bitnod${NC}"
        bitno-cli stop
        sleep 30
        if pgrep -x 'bitnod' > /dev/null; then
            echo -e "${RED}bitnod daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 bitnod
            sleep 30
            if pgrep -x 'bitnod' > /dev/null; then
                echo -e "${RED}Can't stop bitnod! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your BitNo Masternode Will be Updated To The Latest Version v1.0.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'bitnoauto.sh' | crontab -

#Stop bitnod by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/bitno*
mkdir BITNO_1.0.0
cd BITNO_1.0.0
wget https://github.com/BitNo-777/bitno/releases/download/1.0.0/bitno-1.0.0-linux.tar.gz
tar -xzvf bitno-1.0.0-linux.tar.gz
mv bitnod /usr/local/bin/bitnod
mv bitno-cli /usr/local/bin/bitno-cli
chmod +x /usr/local/bin/bitno*
rm -rf ~/.bitno/blocks
rm -rf ~/.bitno/chainstate
rm -rf ~/.bitno/sporks
rm -rf ~/.bitno/peers.dat
cd ~/.bitno/
wget https://github.com/BitNo-777/bitno/releases/download/1.0.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.bitno/bootstrap.zip ~/BITNO_1.0.0


# add new nodes to config file
sed -i '/addnode/d' ~/.bitno/bitno.conf

echo "addnode=193.149.129.80
addnode=193.149.180.54
addnode=45.61.136.151
addnode=168.100.9.55
addnode=162.33.177.119" >> ~/.bitno/bitno.conf

#start bitnod
bitnod -daemon

printf '#!/bin/bash\nif [ ! -f "~/.bitno/bitno.pid" ]; then /usr/local/bin/bitnod -daemon ; fi' > /root/bitnoauto.sh
chmod -R 755 /root/bitnoauto.sh
#Setting auto start cron job for BitNo  
if ! crontab -l | grep "bitnoauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/bitnoauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"
