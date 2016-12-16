#!/bin/bash

## 2016-12-16

## Designed by FXZ
## Transfer rec db data
## Check validation
## Monitor and Alarm

Gzipfile="recommend_pool.json.gz"
GZIP="/usr/bin/gzip"
WORK="/home/fengxinzhi/rec-db"
LOG="log/recdb.log.$(date +%Y%m%d)"
FILE="recommend_pool.json"
BACKFILE="/data/rec-db"
GIT="http://git.izuiyou.com/zibo/recommend_building.git"

MACH="stg-rec|db-preview05"

monitor(){
	#python sendmsg.py "Fatal error : dump data failed two time, please check !!!"
	echo "montor !!!" >>$LOG
}


dump(){
	echo "Begin dump data..." >>$LOG
	python dump_db.py >recommend_pool.json
}

monitor(){
	#python sendmsg.py "Fatal error : dump data failed two time, please check !!!"
	echo "montor !!!" >>$LOG
}

#move file 
MV(){
	right=0
	for i in $(lh| grep -E $MACH|awk '{print $1}')
	do 
		if [[ $NUM==$MNUM ]]
		then
			ssh $i "[[ ! -d /data/recdb ]] && mkdir -p /data/recdb "
			ssh $i " mv -f /home/work/recommend_pool.json /data/recdb/ "
			echo "Move json file Success !!!" >>$LOG
		else
			echo "MD5 isn't right ! Move josn file failed ,Fatal err !!!" >>$LOG
			right+=1
			monitor
			exit 
		fi
	done 
}


#backup dumpfile
backup(){
	[[ ! -d bak ]] && mkdir bak
	if [ -f $Gzipfile ]
	then
		mv $FILE $BACKFILE/$(date +%Y%m%d-%H%M).$FILE
		echo "Backup file Done!" >>$LOG
	fi
}

#trans file
Tran(){
	for i in $(lh| grep -E $MACH|awk '{print $1}')
	do 
		echo "Begin to update $i " >>$LOG
		rsync -Pt $Gzipfile  $i:/home/work/
	done

}

[[ ! -d $BACKFILE  ]] && mkdir -p $BACKFILE

cd $WORK

[[ $? -ne 0 ]] && echo "Work path $WORK does not exist !" >>$LOG && monitor  && exit
[[ ! -d log  ]] && mkdir log

if [[ ! -f dump_db.py ]]  
then 
	echo "dump_db.py not exist !" >>$LOG 
	[[ -f recommend_building/build_process/dump_db.py ]] && ln -s recommend_building/build_process/dump_db.py dump_db.py 

	[[ ! -f recommend_building/build_process/dump_db.py ]] && git clone  $GIT 

	[[ $? -ne 0 ]] && echo "dump_db.py could not download ! " && monitor &&  exit

fi
	
time dump >>$LOG

if [ $? -ne 0 ]
then 
	echo "dump data failed, try again !!!"
	dump
	if [ $? -ne 0 ]
	then
		echo "dump data failed ,  fatal, monitor !!!"
		monitor
		exit
	fi
fi
 


$GZIP $FILE

Tran

sleep 1

$GZIP -d $Gzipfile

md=$(md5sum $FILE|awk '{print $1}')

echo "Locat 	FILE 	 md5 : $md " >>okfile

Copy(){
	
	for i in $(lh| grep -E $MACH|awk '{print $1}')
		do 		
			ssh $i "cd /home/work/ && gzip -d recommend_pool.json.gz"		
			chk=$(ssh $i "md5sum /home/work/recommend_pool.json|awk '{print $1}'")
			echo "$i checksum is : $chk " >>okfile
			if [[ "$chk"=="$md" ]]
			then
				echo "Md5 $i ok !" >> okfile
			else
				echo "Md5 $i err  !" >> okfile
			fi
		done

}

Copy

OKNUM=$(grep "qd*ok" okfile|wc -l)
MNUM=$(lh| grep -E $MACH|wc -l)

MV

echo $(date +%Y%m%d-%H%M) >>$LOG
cat okfile  >>$LOG

if [[ "$right" -eq 0 ]]
then
	echo "Backup Done!" >>$LOG
	backup
fi

echo "" >okfile

