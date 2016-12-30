#!/bin/sh
###################### START #############################
echo "Staring ..."
export DATETIME=$(date +%s)
cd /usr/local/bfd/

./tlog /var/log/messages vsftpd | grep -w vsftpd | grep -iwf pattern.auth | awk '{print $17}' | tr -d '"' | sort |uniq -c > host-lists

cat host-lists | sort -rn | awk '{ if ( $1 > 30 ) { print ;}}' > host-lists.tmp

if [ -s host-lists.tmp ] ; then

	cp /etc/apf/deny_hosts.rules ./backup/deny_hosts.rules-${DATETIME}
	cp /etc/apf/deny_hosts.rules .
	
	cat host-lists.tmp | awk '{ print $2}' > host-lists
	cp host-list /usr/local/bfd/bhost/blockhosts-${DATETIME}

	blockhostlist=`cat host-lists`
		for varblockhostlist in $blockhostlist; do
			echo $varblockhostlist >> deny_hosts.rules
			echo $varblockhostlist-${DATETIME} >> attemping_host.log	
		done
	echo "Restarting APF"
	cp deny_hosts.rules /etc/apf/deny_hosts.rules
	rm -rf deny_hosts.rules
	/etc/apf/apf -r
fi

find ./bhost -type f -cmin +1440 > restimevar

if [ -s restimevar ] ; then
	
	cp /etc/apf/deny_hosts.rules ./backup/deny_hosts.rules-${DATETIME}
        cp /etc/apf/deny_hosts.rules .

	blockedhostname=`cat restimevar`
	restorehostlist=`cat $blockedhostname`
			cp deny_hosts.rules deny_hosts.rules.tmp.a
		for varrestorehostlist in $restorehostlist; do
			cat deny_hosts.rules.tmp.a | grep -v $varrestorehostlist > deny_hosts.rules.tmp.b
			mv deny_hosts.rules.tmp.b deny_hosts.rules.tmp.a
			echo $varrestorehostlist-${DATETIME} >> restoring_host.log	
		done
			mv deny_hosts.rules.tmp.a deny_hosts.rules	
			
	rm -rf $blockedhostname
	echo "Restarting APF"
	cp deny_hosts.rules /etc/apf/deny_hosts.rules
        rm -rf deny_hosts.rules
	/etc/apf/apf -r
fi
	rm -rf restimevar
	rm -rf host-lists
	rm -rf host-lists.tmp
##################### END ############################
# find . -type f -cmin +1440  / 1 honog
