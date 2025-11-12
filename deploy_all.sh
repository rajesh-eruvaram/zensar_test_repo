#!/bin/bash
# Initialize error variable
FORMS_PATH=$FORMS_PATH:$AU_TOP/forms/US
export FORMS_PATH
err=0

#initialize for err
function errtrap {
	err=$(($err + $?))
}

trap errtrap ERR

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

function runshellscript {
	for i in `ls *.[sS][hH]`
	do 
	#echo "in sh $i">> $LOGFILE 2>> $LOGERR
		[[ "$i" == "deploy_all.sh" ]] && continue	
		
			echo "Checking $i file in server path"		
		if [[ -f "$XXGT_TOP/bin/$i" ]]; then
			backup_file="$XXGT_TOP/bin/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			cp "$XXGT_TOP/bin/$i" "$backup_file"
			echo "$i found and backup created: $backup_file (Status: $?)"
		fi	
		
		dos2unix -q -k $i
		cp $i $XXGT_TOP/bin/
        chmod 777 "$XXGT_TOP/bin/$i"
		echo "*****Deploying Shellscript $i...">> $LOGFILE 2>> $LOGERR
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		echo "Status : $?"
		echo ""
	done
}

#function to deploy the CTL files
#function sqlfile {
#	for i in `ls *.[sS][qQ][lL]`
#	do 
#		dos2unix -q -k $i
#		echo "*****Deploying SQL file in server $i "
#		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
#		cp $i $XXGT_TOP/sql/
#		chmod 777 "$XXGT_TOP/bin/$i"
##		echo "Status : $?"
#		echo ""
#	done
#}

#function to deploy the shell scripts .PROG files & create a softlink
function deployprogfile {
	for i in `ls *.[pP][rR][oO][gG]`
	do  
		echo "Checking $i file in server path"
		if [[ -f "$XXGT_TOP/bin/$i" ]]; then
			backup_file="$XXGT_TOP/bin/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			cp "$XXGT_TOP/bin/$i" "$backup_file"
			echo "$i found and backup created: $backup_file (Status: $?)"
		fi		
		dos2unix -q -k $i
		echo "*****Deploying .Prog $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		cp $i $XXGT_TOP/bin/
		chmod 777 $XXGT_TOP/bin/$i
		echo "Status : $?"
		echo ""
	done
}

#function to deploy the Table
function deploytbl {
	for i in `ls *.[tT][bB][lL]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Table in .tbl file $i"
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

#function to deploy the Sequence
function deployseq {
	for i in `ls *.[sS][eE][qQ]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Sequence in .seq file $i"
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

#function to deploy the CTL files
function deployctl {
	for i in `ls *.[cC][tT][lL]`
	do 
		echo "Checking $i file in server path"
		if [[ -f "$XXGT_TOP/bin/$i" ]]; then
			backup_file="$XXGT_TOP/bin/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			cp "$XXGT_TOP/bin/$i" "$backup_file"
			echo "$i found and backup created: $backup_file (Status: $?)"
		fi		
		dos2unix -q -k $i
		echo "*****Deploying ctl File $i"
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		cp $i $XXGT_TOP/bin/
		chmod 777 "$XXGT_TOP/bin/$i"
		echo "Status : $?"
		echo ""
	done
}


#function to deploy the View
function deployview {
	for i in `ls *.[vV][wW]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying View in .vw file $i"
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

#function to deploy the Materalize View
function deploymv {
	for i in `ls *.[mM][vV]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying MV in .mv file $i"
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


#function to deploy the Trigger
function deploytrigger {
	for i in `ls *.[tT][rR][gG]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Trigger in .trg file $i"
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


#function to deploy the Function
function deployfunction {
	for i in `ls *.[fF][nN][cC]`
	do 
		dos2unix -q -k $i
		echo "*****Deploying Function in .fnc file $i"
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
		echo "*****Deploying Procedure in .prc file $i"
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
		echo "*****Deploying Package Specification in .pks file $i"
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
		echo "*****Deploying Package Body in .pkb file $i"
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
			echo "*****Deploying FMB $i"
			cp $i $XXGT_TOP/forms/US/
			sudo chown appldevt:dba "$XXGT_TOP/forms/US/$i"
			sudo chmod 755 "$XXGT_TOP/forms/US/$i"	
			frmcmp_batch module=$XXGT_TOP/forms/US/$i userid=apps/$P_APPS_PWD module_type=form batch=yes compile_all=special			
			echo "Status : $?"
			echo ""
			
            fmx_file="${i%.*}.fmx"
				if [ -f "$XXGT_TOP/forms/US/$fmx_file" ]; then
					sudo chown appldevt:dba "$XXGT_TOP/forms/US/$fmx_file"
					sudo chmod 755 "$XXGT_TOP/forms/US/$fmx_file"
					#echo "[$(date +"%Y-%m-%d %H:%M:%S")] Set 755 permission on $fmx_file" | tee -a "$LOGFILE"
				fi					
		
	done
}


#function to deploy the RDF files
function deployrdf {
	for i in `ls *.[rR][dD][fF]` 
	do 
		echo "Checking $i file in server path">> $LOGFILE 2>> $LOGERR
		if [[ -f "$XXGT_TOP/reports/US/$i" ]]; then
			backup_file="$XXGT_TOP/reports/US/${i}_bkp_$(date '+%d%b%Y_%H%M%S')"
			# Backup the RDF while preserving timestamp
			cp -p "$XXGT_TOP/reports/US/$i" "$backup_file"
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


#function to deploy the workflow files
function deploywft {
	for i in `ls *.[wW][fF][tT]`
	do 
		echo "*****Deploying Workfloe file $i">> $LOGFILE 2>> $LOGERR
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		WFLOAD apps/$P_APPS_PWD 0 Y FORCE $i
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



#function to deploy the XML Definition and XML Template LDT files
function deploy_xml_rtf_ldt {
	for i in `grep -l "phase=dat" *.ldt`
	do 
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		echo "*****Deploying RTF LDT $i">> $LOGFILE 2>> $LOGERR
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		lctfile=`grep "dbdrv" $i`
		lctfile=${lctfile##*"UPLOAD "}
		lctfile=${lctfile%%" @~"*}
		echo "LCT File = $lctfile***"
		FNDLOAD apps/$P_APPS_PWD 0 Y UPLOAD "$lctfile" "$i" UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE
		echo "Status : $?"
		echo ""
	done

}

#function to deploy the XML report files
function deployxmlfile {
	for i in `ls *.[xX][mM][lL]`
	do 
		
		echo "*****Deploying XML Data Template File $i">> $LOGFILE 2>> $LOGERR
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		lobcode=$i
		lobcode=${lobcode%%.[a-zA-Z]*}
		loblog="$lobcode"_xml.log
		java oracle.apps.xdo.oa.util.XDOLoader UPLOAD -DB_USERNAME apps -DB_PASSWORD $P_APPS_PWD -JDBC_CONNECTION $P_SERVER_NAME:$P_PORT:$P_DATABASE_SID -LOB_TYPE DATA_TEMPLATE -APPS_SHORT_NAME XXGT -LOB_CODE "$lobcode" -FILE_TYPE "text/html" -XDO_FILE_TYPE "XML" -LOG_FILE "$loblog" -FILE_NAME "$i" -CUSTOM_MODE FORCE -UPLOAD_MODE REPLACE
		echo "Status : $?"
		echo ""
	done
}


#function to deploy the RTF templates file
function deployrtffile {
	for i in `ls *.[rR][tT][fF]`
	do  
	
		echo "*****Deploying RTF Tempalte File $i">> $LOGFILE 2>> $LOGERR
		echo "" >> $LOGFILE 2>> $LOGERR   # add new line
		lobcode=$i
		lobcode=${lobcode%%.[a-zA-Z]*}
		loblog="$lobcode"_rtf.log
		#- Retriving territory information		
territory_exits=`sqlplus -s apps/$P_APPS_PWD << EOF | grep ^territory | sed "s/^territory: //"
set heading off feedback off serveroutput on trimout on pagesize 0 
  declare
    l_territory_code   VARCHAR2(240);
    l_territory_exists varchar2(10);
  begin
    begin
      select territory
        into l_territory_code
        from xdo_lobs
       where lob_type = 'TEMPLATE_SOURCE'
         and xdo_file_type = 'RTF'
         and lob_code = '$lobcode';
    exception
      when too_many_rows then
        begin
          select territory
            into l_territory_code
            from xdo_lobs
           where lob_type = 'TEMPLATE_SOURCE'
             and xdo_file_type = 'RTF'
             and lob_code = '$lobcode'
             and territory = 'US';
        exception
          when others then
            l_territory_code := '00';
        end;
    when others then
      l_territory_code := '00';
    end;
  
    if l_territory_code = '00' THEN
       l_territory_exists := 'N';
    else
       l_territory_exists := 'Y';
    end if;
    
   dbms_output.put_line('territory'||l_territory_exists);   
   
  exception
   when others then
          l_territory_exists := 'N';
     dbms_output.put_line('territory'||l_territory_exists);
 end;
 /
EOF`
		#-
		echo "territory-"$territory_exits
		texit=`echo $territory_exits`
		#- echo 'texit-'$texit
		texists=`echo $texit | cut -c 10`
		#- echo "texits-"$texists
    	if [ $texists = N ]; then
			echo "Terrirtory N" $territory_exists
			java oracle.apps.xdo.oa.util.XDOLoader UPLOAD -DB_USERNAME apps -DB_PASSWORD $P_APPS_PWD -JDBC_CONNECTION $P_SERVER_NAME:$P_PORT:$P_DATABASE_SID -LOB_TYPE TEMPLATE -APPS_SHORT_NAME XXGT -LOB_CODE "$lobcode" -LANGUAGE en -XDO_FILE_TYPE "RTF" -FILE_NAME "$i" -LOG_FILE "$loblog" -CUSTOM_MODE FORCE -UPLOAD_MODE REPLACE
		else
			echo "Terrirtory Y" $territory_exists
			java oracle.apps.xdo.oa.util.XDOLoader UPLOAD -DB_USERNAME apps -DB_PASSWORD $P_APPS_PWD -JDBC_CONNECTION $P_SERVER_NAME:$P_PORT:$P_DATABASE_SID -LOB_TYPE TEMPLATE -APPS_SHORT_NAME XXGT -LOB_CODE "$lobcode" -LANGUAGE en -TERRITORY US -XDO_FILE_TYPE "RTF" -FILE_NAME "$i" -LOG_FILE "$loblog" -CUSTOM_MODE FORCE -UPLOAD_MODE REPLACE
		fi
		
		echo "Status : $?"
		#echo
	done
}


#function to deploy the SQL program files in SQL folder 
function deploy_SQL_file_in_folder {
    # Loop through all .sql files that DO NOT contain "CREATE" or "REPLACE"
    for i in `grep -wL -i -e "CREATE" -e "REPLACE" *.sql`
    do 
        dos2unix -q -k "$i"
        echo "*****Deploying SQL file in server Folder $i "
        echo "" >> $LOGFILE 2>> $LOGERR   # add new line
        cp "$i" "$XXGT_TOP/sql/"
        chmod 777 "$XXGT_TOP/sql/$i"
        echo "Status : $?"
        echo ""
    done
}


#function to deploy the TABLE .Sql File
function deploy_table_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+TABLE" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying TABLE .sql file $i"
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

##function to deploy the SEQUENCE .Sql File
function deploy_seq_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+SEQUENCE" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying SEQUENCE .sql file $i"
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

##function to deploy the VIEW .Sql files
function deploy_view_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?VIEW" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying VIEW .sql file $i"
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

##function to deploy the MATERIALIZED VIEW .Sql files
function deploy_mv_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?MATERIALIZED" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying MATERIALIZED VIEW .sql file $i"
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



##function to deploy the TRIGGER .Sql File
function deploy_trigger_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?TRIGGER" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying TRIGGER .sql file $i"
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

##function to deploy the FUNCTION .Sql File
function deploy_function_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?FUNCTION" *.sql`	
	do 
		dos2unix -q -k $i
		echo "*****Deploying FUNCTION .sql file $i"
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

##function to deploy the PROCEDURE .Sql File
function deploy_procedure_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?PROCEDURE" *.sql`	
	do 
		dos2unix -q -k $i
		echo "*****Deploying PROCEDURE .sql file $i"
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

##function to deploy the PACKAGE .Sql File
function deploy_package_sql_file {
	for i in `grep -Eil "CREATE[[:space:]]+(OR[[:space:]]+REPLACE[[:space:]]+)?PACKAGE" *.sql`
	do 
		dos2unix -q -k $i
		echo "*****Deploying PACKAGE .sql file $i"
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


#read te input
#getinput;
echo "Apps password  :: *****" >> $LOGFILE 2>> $LOGERR
echo "DB Server Name :: $P_SERVER_NAME" >> $LOGFILE 2>> $LOGERR
echo "DB Port Number :: $P_PORT" >> $LOGFILE 2>> $LOGERR
echo "Database SID   :: $P_DATABASE_SID" >> $LOGFILE 2>> $LOGERR
echo "Reading the input...Done" >> $LOGFILE 2>> $LOGERR
echo "" >> $LOGFILE 2>> $LOGERR
#echo

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "===================================================">> $LOGFILE 2>> $LOGERR
echo "SCRIPT START TIME: $START_TIME" >> $LOGFILE 2>> $LOGERR
echo "===================================================">> $LOGFILE 2>> $LOGERR

##call the function to deploye Shell script
runshellscript>> $LOGFILE 2>> $LOGERR

##call the function to deploy SQL script to bin
#sqlfile >> $LOGFILE 2>> $LOGERR

##call the function to deploy .Prog Files
deployprogfile>> $LOGFILE 2>> $LOGERR

##call the function to deploy Table
deploytbl >> $LOGFILE 2>> $LOGERR

##call the function to deploy Sequence
deployseq >> $LOGFILE 2>> $LOGERR

##call the function to deploy CTL files
deployctl >> $LOGFILE 2>> $LOGERR

##call the function to View
deployview >> $LOGFILE 2>> $LOGERR

##call the function to MV
deploymv >> $LOGFILE 2>> $LOGERR

##call the function to deploy Trigger
deploytrigger >> $LOGFILE 2>> $LOGERR
	
##call the function to deploy function
deployfunction >> $LOGFILE 2>> $LOGERR
	
##call the function to deploy procedure
deployprc >> $LOGFILE 2>> $LOGERR

##call the function to deploy Package Specification
deploypks >> $LOGFILE 2>> $LOGERR

##call the function to deploy Package Body
deploypkb >> $LOGFILE 2>> $LOGERR

##call the function to deploy FMB 
deployfmb >> $LOGFILE 2>> $LOGERR

##call the function to deploy RDF
deployrdf >> $LOGFILE 2>> $LOGERR

##call the function to Deploying workflow files
deploywft >> $LOGFILE 2>> $LOGERR

##call the function to deploy AOL LDT files
deployldt >> $LOGFILE 2>> $LOGERR

##function to deploy the XML Definition and XML  Template LDT files
deploy_xml_rtf_ldt >> $LOGFILE 2>> $LOGERR

##call the function to attached .RTF file in  Template 
deployrtffile >> $LOGFILE 2>> $LOGERR

##call the function to  attached .XML file in Data Definitions 
deployxmlfile >> $LOGFILE 2>> $LOGERR
 
##################################################


##function to deploy the SQL program files in SQL folder 
deploy_SQL_file_in_folder >> $LOGFILE 2>> $LOGERR

##function to deploy the TABLE .Sql File
deploy_table_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the SEQUENCE .Sql File
#deploy_seq_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the VIEW .Sql files
deploy_view_sql_file >> $LOGFILE 2>> $LOGERR 

##function to deploy the MATERIALIZED VIEW .Sql files
#deploy_mv_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the TRIGGER .Sql File
deploy_trigger_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the FUNCTION .Sql File
deploy_function_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the PROCEDURE .Sql File
deploy_procedure_sql_file >> $LOGFILE 2>> $LOGERR

##function to deploy the PACKAGE .Sql File
deploy_package_sql_file >> $LOGFILE 2>> $LOGERR 

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
#check if the installation is success or failure
echo "" >> $LOGFILE 2>> $LOGERR
echo ""
if (( $err == 0 )); then
	echo "Installation completed Successfully. Log file $LOGFILE created." >> $LOGFILE 2>> $LOGERR
	echo "Installation completed Successfully. Log file $LOGFILE created."
else
	echo "Installation Failed. Check log file $LOGERR for errors." >> $LOGFILE 2>> $LOGERR
	echo "Installation Failed. Check log file $LOGERR for errors."
fi
echo "" >> $LOGFILE 2>> $LOGERR
echo ""

# --- Capture end date/time ---
END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "==================================================="  >> $LOGFILE 2>> $LOGERR
echo "SCRIPT END TIME: $END_TIME" >> $LOGFILE 2>> $LOGERR
echo "==================================================="  >> $LOGFILE 2>> $LOGERR
exit 0
