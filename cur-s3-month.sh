#!/bin/bash



    ##################
    ##
    ## Download files from S3 bucket ibi-org-billing to a local folder named target 
    ##   then extract all the ZIP  files to CSV files from the sub directories 
    ##     then you can upload these CSV files to another s3 bucket to be used with Athena or other extraction manipulation process 
    ##
    ## 
    ################################################################################################################################



#clear the screec 
##############################################
clear


#Colors
##############################################
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RED='\033[0;31m'

#create local target directory
##############################################

mkdir target 


#clear screen 
################################################
echo " " 
echo " " 
echo " " 
echo -e "**************************************"
echo -e "*${GREEN}Downloading s3 content${NC}*"
echo -e "***************************************"
sleep 3


#Download from the ibi-org-billing all content 
###############################################
aws s3 sync s3://$1/ibi-customers/$2 target/


#clear screen 
################################################
echo " " 
echo " " 
echo " " 
echo -e "*********************************"
echo -e "*${GREEN}downloded content${NC}*"
echo -e "*********************************"
sleep 2


#Present the target folder with the list of folders int 
##########################################################
ls -l target/ |grep -v total
echo " "
echo " " 
sleep 5



echo -e "#####################################################################################################"
echo -e "### ${GREEN}       eXTRACTING THE FILES FROM THE DIRECTORIs ${NC}                                   #"
echo -e "#####################################################################################################"
echo " " 


#list all zip files  
#################################################################################
find target/ -name "*" -type f -exec ls -l {} \;
sleep 6


##############################################
#clear screen present message
################################################
echo " " 
echo " " 
echo " " 
echo -e "*****************************"
echo -e "*${GREEN}Unziping files${NC}*"
echo -e "*****************************"
sleep 5


#unzip the ZIP files into the target/files directory    
#################################################################################
mkdir target/files
mkdir /tmp/download 
cd target/files
#find .. -name "*" -type f -exec unzip -o {} \;

find .. -name "*.zip" -type f > /tmp/zipfiles.tmp


echo "Number of zip files found" > /tmp/csv.log
echo "=========================" >> /tmp/csv.log
cat /tmp/zipfiles.tmp|wc -l >> /tmp/csv.log
zip=`cat /tmp/zipfiles.tmp|wc -l`


for n in `cat /tmp/zipfiles.tmp`
do 
  cp "$n" ./
  FFILE=`ls -1`
  unzip $FFILE
  rm -fr *.zip
  FFILE=`ls -1`
  cat $FFILE >> /tmp/download/${2}_supercsv.csv
# mv $FFILE /tmp/download/${RANDOM}_$FFILE
  rm -fr $FFILE
  sleep 5
  ls -1 
  sleep 5 
  
done 

echo "copied CSV files to download directory" >> /tmp/csv.log
echo "======================================" >> /tmp/csv.log
ls -1 /tmp/download/ |wc -l >> /tmp/csv.log
copied=`ls -1 /tmp/download/ |wc -l` 


echo " "
echo " "
echo " " 
cat /tmp/csv.log 
echo " " 
echo " " 
echo " " 
sleep 10 

#if [[ "$zip" -ne "$copied" ]] 
#then 
#  exit
#fi 



echo -e "########################################################################"
echo -e " *       ${RED}Copy / upload CSV files to new Bucket${NC}              *"
echo -e "########################################################################"



#Copy upload files to the new s3bucket 
#################################################################################
echo -e "     *************************************************"
echo -e "     *${GREEN}Uploading files to new bucket ${NC}    *"
echo -e "     ************************************************"

  echo " " 
  echo " "
  cd 
  aws s3 sync /tmp/download s3://$3/ibi-customers


#List the files in the target new bucket 
#############################################################
aws s3 ls s3://$3/ibi-customers/


#Please check the scv.log file 
#############################################################
echo " " 
echo " " 
echo " "

echo -e "     ***********************************************************************************"
echo -e "     *                ${RED}Check /tmp/csv.log file${NC}                               *"
echo -e "     ***********************************************************************************"



#END








