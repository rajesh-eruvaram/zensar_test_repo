#!/bin/bash
# Initialize error variable
err=0

echo "***********START $err***********"
#echo

err="0"; export err

LOGFILE="XXTEST_INST.log"; export LOGFILE
LOGERR="XXTEST_INST.err"; export LOGERR

touch "$LOGFILE" "$LOGERR"

: > "$LOGFILE"
: > "$LOGERR"

chmod 666 "$LOGFILE" "$LOGERR"


# Function to get user input
#function getinput {
#printf "Enter APPS password: "
#stty -echo
#read P_APPS_PWD
#stty echo
#echo
#printf "Enter DB Server Name: "
#read P_SERVER_NAME

#printf "Enter Port Number: "
#read P_PORT

#printf "Enter Database SID: "
#read P_DATABASE_SID
#}

#function to deploy the Table
function deploytbl {
	for i in `ls *.[tT][bB][lL]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Table $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
sqlplus -s apps/$P_APPS_PWD << EOF
set define off
@$i
show errors
EOF
		echo "Status : $?"
		echo ""
	done
}


#function to deploy the pl/sql procedure
function deployprc {
	for i in `ls *.[pP][rR][cC]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Procedure $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
sqlplus -s apps/$P_APPS_PWD << EOF
set define off
@$i
show errors
EOF
		echo "Status : $?"
		echo ""
	done
}


#function to deploy the Package Spe.
function deploypks {
	for i in `ls *.[pP][kK][sS]`
	do 
		dos2unix -q -k $i		
		echo "*****Deploying Package Specification $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
sqlplus -s apps/$P_APPS_PWD << EOF
set define off
@$i
/
show errors
EOF
		echo "Status : $?"
		echo ""
	done
}


#function to deploy the Package Body
function deploypkb {
	for i in `ls *.[pP][kK][bB]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Package Body $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
sqlplus -s apps/$P_APPS_PWD << EOF
set define off
@$i
/
show errors
EOF
		echo "Status : $?"
		echo ""
	done
}


##function to deploy the FMB files
function deployfmb {
	for i in `ls *.[fF][mM][bB]`
	do 
		echo "Checking $i file in server path">> $LOGFILE 2>> $LOGERR
		if [[ -f "$XXGT_TOP/forms/US/$i" ]]; then
			backup_file="$XXGT_TOP/forms/US/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			cp "$XXGT_TOP/forms/US/$i" "$backup_file"
			echo "$i found and backup created: $backup_file (Status: $?)"
		fi
		
		# Backup existing .fmx file if it exists
        fmx_file="${i%.*}.fmx"
        if [[ -f "$XXGT_TOP/forms/US/$fmx_file" ]]; then
            backup_fmx_file="$XXGT_TOP/forms/US/${fmx_file}_bkp_$(date '+%d%b%Y_%H%M%S')"
            cp "$XXGT_TOP/forms/US/$fmx_file" "$backup_fmx_file"
            echo "$fmx_file found and backup created: $backup_fmx_file (Status: $?)"
        else
            echo "No existing $fmx_file file to backup."
        fi
		
			echo "*****Deploying FMB $i"
			echo "" >> $LOGFILE 2>> $LOGERR   # add new line
			cp $i $XXGT_TOP/forms/US/
			frmcmp_batch module=$XXGT_TOP/forms/US/$i userid=apps/$P_APPS_PWD module_type=form batch=yes compile_all=special
			chmod 777 "$XXGT_TOP/forms/US/$i"
			echo "Status : $?"
			echo ""
	done
}


#function to deploy the RDF files
function deployrdf {
	for i in `ls *.[rR][dD][fF]` 
	do 
		echo "Checking $i file in server path">> $LOGFILE 2>> $LOGERR
		if [[ -f "$XXGT_TOP/reports/US/$i" ]]; then
			backup_file="$XXGT_TOP/reports/US/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			cp "$XXGT_TOP/reports/US/$i" "$backup_file"
			echo "$i found and backup created: $backup_file (Status: $?)"
		fi
		echo "*****Deploying RDF $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		cp $i $XXGT_TOP/reports/US/
		chmod 777 "$XXGT_TOP/reports/US/$i"
		echo "Status : $?"
		echo ""
	done
}



##function for LDT  files
function deployldt {
	#process the LDT files sequentially in order to make sure the LDTs are deployed correctly.
	#for s in `seq 51 70`
	#do
		#for i in `ls *.[lL][dD][tT]`
		for i in `grep -l "daa+$s" *.ldt`
		do 
			echo "" >> $LOGFILE 2>> $LOGERR   # add new line
			echo "*****Deploying LDT $i">> $LOGFILE 2>> $LOGERR
			echo "" >> $LOGFILE 2>> $LOGERR   # add new line
			lctfile=`grep "dbdrv" $i`
			lctfile=${lctfile##*"UPLOAD "}
			lctfile=${lctfile%%" @~"*}
			echo "LCT File = $lctfile***"
			FNDLOAD apps/$P_APPS_PWD 0 Y UPLOAD "$lctfile" "$i" UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
			echo "Status : $?"
			echo ""
		done
	#done
}


echo "Apps password  :: *****" >> $LOGFILE 2>> $LOGERR
echo "DB Server Name :: $P_SERVER_NAME" >> $LOGFILE 2>> $LOGERR
echo "DB Port Number :: $P_PORT" >> $LOGFILE 2>> $LOGERR
echo "Database SID   :: $P_DATABASE_SID" >> $LOGFILE 2>> $LOGERR
echo "Reading the input...Done" >> $LOGFILE 2>> $LOGERR
echo "" >> $LOGFILE 2>> $LOGERR

#call the function to deploy Table
deploytbl >> $LOGFILE 2>> $LOGERR
	
#call the function to deploy procedure
deployprc >> $LOGFILE 2>> $LOGERR


#call the function to deploy Package Specification
deploypks >> $LOGFILE 2>> $LOGERR

# #call the function to deploy Package Body
deploypkb >> $LOGFILE 2>> $LOGERR

# #call the function to deploy FMB 
deployfmb >> $LOGFILE 2>> $LOGERR

#call the function to deploy RDF
deployrdf >> $LOGFILE 2>> $LOGERR

# #call the function to deploy AOL LDT files
deployldt >> $LOGFILE 2>> $LOGERR


DB_CONNECT_STRING="${P_SERVER_NAME}:${P_PORT}/${P_DATABASE_SID}"

# Display the collected info
#echo
echo "Collected DB Connection Info:"
echo "Server Name : $P_SERVER_NAME"
echo "Port        : $P_PORT"
echo "SID         : $P_DATABASE_SID"
echo "Connect Str : $DB_CONNECT_STRING"

echo "***********END $err***********"
#echo
#echo >> $LOGFILE 2>> $LOGERR
#echo
