#!/bin/bash
#echo "Need to run we auth before login jumphost"
#sleep 1

log_directory=/c/Users/aa100193/Logs/$(date '+%Y-%m-%d')
if test -e $log_directory
then
	cd $log_directory
else
	mkdir -p $log_directory
	cd $log_directory
fi

current=$(date +%s)
timeslot=`expr 12 \* 3600`

if test -e ./authlog.txt
then
	record=$(cat authlog.txt)
	recordtime=$(date +%s -d "$record $timeslot seconds")
	if test $current -le $recordtime
		then
			echo "No need to run we auth.Your access token is still valid."
			sleep 1
		else
			echo -e "Trying to run we auth...........\n"
			we auth to re-authenticate
			echo "$(date '+%Y-%m-%d %H:%M:%S')" > authlog.txt
	fi
else
	we auth to re-authenticate
	echo "$(date '+%Y-%m-%d %H:%M:%S')" > authlog.txt
fi

if [ $? -eq 0 ]
then
	echo -e "\nJumphost list:"
	echo "1: To login Oracle"
	echo "2: To vehicle status server(malfunction)"
	echo "3: To provisioning service(postgres)"
	echo "4: To connect to non-prod oracle db(PFEU)"
	echo "5: To Master data"
	echo "6: To CVS(delete secondary user)"
	echo "7: To PPS(update price plan from b to c)"
	echo "8: To IAM(to remove iam user)"
	echo "9: To resent Nissan vehicle profile"
else
	echo "Authenticate failed!!!"
	exit
fi

#we auth to re-authenticate

#case $num in
#	1) we ssh -l wcar -L 1521:jlr-prod-rds-oracle-02-ee.cuk8pxgbvhvw.rds.cn-northwest-1.amazonaws.com.cn:1521 customer-vehicle-data-storage-server prod
#		;;
#	2) we ssh --forward-ports 12448:localhost:8443 vehiclestatus-service-server jlr cn-northwest-1 prod
#	;;
#	*) echo "Wrong input!!!!"
#		;;
#esac

int=1

while [ $int -le 5 ]
do
	read -p "Please select number to login jumphost: " num
	case $num in
		1) 
			echo -e "......\n"
			sleep 1
		       we ssh -l wcar_op -L 1521:jlr-prod-rds-oracle-02-ee.cuk8pxgbvhvw.rds.cn-northwest-1.amazonaws.com.cn:1521 customer-vehicle-data-storage-server prod
			if [ $? -ne 0 ]
			then
				ssh -F /home/aa100193/.ssh/config.wessh -l wcar 10.185.72.178 -L 1521:jlr-prod-rds-oracle-02-ee.cuk8pxgbvhvw.rds.cn-northwest-1.amazonaws.com.cn:1521
			else
				break
			fi
			;;
		2) 
#			we ssh --forward-ports 12448:localhost:8441 vehiclestatus-service-server jlr cn-northwest-1 prod
			ssh -F /home/aa100193/.ssh/config.wessh -l wcar_op 10.185.74.113 -L 12448:localhost:8443

			break
			;;
		3) 
#			we ssh --forward-ports 5433:jlr-prod-aurora-postgres-01-node-a.cuk8pxgbvhvw.rds.cn-northwest-1.amazonaws.com.cn:5432 provisioning-service jlr cn-northwest-1 prod
			ssh -F /home/aa100193/.ssh/config.wessh -l wcar_op 10.185.74.30 -L 5433:jlr-prod-aurora-postgres-01-node-a.cuk8pxgbvhvw.rds.cn-northwest-1.amazonaws.com.cn:5432
			break
			;;
		4)
			we ssh --forward-ports 15999:jlr-qa-rds-oracle-01.cwrrzj4ztpcb.rds.cn-northwest-1.amazonaws.com.cn:1521 customer-vehicle-data-storage-server jlr iot cn-northwest-1 -c "sleep 3600"
			break
			;;
		5)
			we ssh --forward-ports 10448:localhost:8443 master-data-gateway-server jlr cn-northwest-1 prod
			break
			;;
		6)
			we ssh --forward-ports 10449:localhost:8443 customer-vehicle-data-storage-server jlr cn-northwest-1 prod
			break
			;;
		7)
			essh -u wcar -p 10888:localhost:8443 10.185.73.235 -c 'loop=1; while true; sleep 60; do date; echo "prod jlr-priceplan-service jumphost established for $loop mins"; ((loop=$loop+1)); done;'
			break
			;;
		8)
			we ssh --forward-ports 13448:localhost:8443 jlr-identity-and-access-management-gateway jlr cn-northwest-1 prod
			break
			;;
		9)
			we ssh --forward-ports 19443:nissan.prod.nissan.eu-west-1.wcar.aws.wcar-i.net:443 10.182.241.114 -c 'loop=1; while true; sleep 60; do date; echo "NISSAN PROD (nissan.prod.nissan.eu-west-1.wcar.aws.wcar-i.net) jumphost established for $loop mins"; ((loop=$loop+1)); done;'
			break
			;;
		*) 
			count=`expr 5 - $int`
			echo "Wrong input!!!! You have $count times"
			let "int++"
#			continue
			;;
	esac
done

