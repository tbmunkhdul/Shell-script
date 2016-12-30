#!/bin/sh

echo "Starting ..."
#################### START ######################

WORKINGFOLDER=./just_backup
mdkir $WORKINGFOLDER/folders
export DATE=$(date +%d-%b)

creat_lists ()
{
	find $1 -type f > $WORKINGFOLDER/tmp/$2/new.tmp.txt

	__var_number_line=`cat $WORKINGFOLDER/tmp/$2/new.tmp.txt | wc -l`

        for (( i=1; i<=$__var_number_line; i++ ))
                do
                _var=`head -n $i $WORKINGFOLDER/tmp/$2/new.tmp.txt | tail -n 1`
                echo "$i :: $_var" # delete this line
                varstat=`stat -c=%Y "$_var"`
                echo "$_var:::::$varstat" >> $WORKINGFOLDER/tmp/$2/new.tmp.stat.txt
        done
}
compare_list ()
{
        diff -n $1 $2 | grep ":::::" |  gawk -F: '{ print $1 }' > $WORKINGFOLDER/tmp/$3/tar.tmp.txt
}
if [ ! -s /bin/tar ] ; then
	echo "not found the TAR"
fi

if [ ! -s /usr/bin/stat ] ; then
        echo "not found the STAT"
fi


cd $WORKINGFOLDER
	
	if [ ! -d $WORKINGFOLDER/tmp ] ; then
		mkdir $WORKINGFOLDER/tmp 
	fi
	
if [ -s $WORKINGFOLDER/folders ] ; then

	var_folders_name=`cat $WORKINGFOLDER/folders`

	for var in $var_folders_name; do
		tmpvar=`echo $var | sed 's/\//\_/g'`

		if [ ! -d $WORKINGFOLDER/tmp/$tmpvar ] ; then
			mkdir $WORKINGFOLDER/tmp/$tmpvar
		fi	
		creat_lists $var $tmpvar
		if [ ! -s $WORKINGFOLDER/tmp/$tmpvar/old.tmp.txt ] ; then
			mv $WORKINGFOLDER/tmp/$tmpvar/new.tmp.txt $WORKINGFOLDER/tmp/$tmpvar/old.tmp.txt
			mv $WORKINGFOLDER/tmp/$tmpvar/new.tmp.stat.txt $WORKINGFOLDER/tmp/$tmpvar/old.tmp.stat.txt
			tar -cf $WORKINGFOLDER/tmp/$tmpvar/first-${DATE}.tar $var
		else
			compare_list $WORKINGFOLDER/tmp/$tmpvar/old.tmp.stat.txt $WORKINGFOLDER/tmp/$tmpvar/new.tmp.stat.txt $tmpvar
				if [ -s $WORKINGFOLDER/tmp/$tmpvar/tar.tmp.txt ] ; then
				tar -c -T $WORKINGFOLDER/tmp/$tmpvar/tar.tmp.txt -f $WORKINGFOLDER/tmp/$tmpvar/backup_just-${DATE}.tar	
				rm -rf $WORKINGFOLDER/tmp/$tmpvar/tar.tmp.txt
				fi
			mv $WORKINGFOLDER/tmp/$tmpvar/new.tmp.txt $WORKINGFOLDER/tmp/$tmpvar/old.tmp.txt
			mv $WORKINGFOLDER/tmp/$tmpvar/new.tmp.stat.txt $WORKINGFOLDER/tmp/$tmpvar/old.tmp.stat.txt
		fi		
	done

else 
	echo "Create a \"folders\" file and add a folder name to backup... "
fi 

################# END ############################
