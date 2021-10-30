#!/bin/bash

#######################################
# Format name and surname to Title case
# Generate email like "first letter from name" + "surname" + "location_id" + @abc.com
#######################################

if [ -z "$1" ];         # if sting empty
then
    echo "Input file must be passed as an argument!"
    break 
fi

if ! [ -f $1 ] || ! [ -e $1 ];      # check if if input variable exist and is it file
then
    echo "Input file '"$1"' doesn't exist!"
    break 
fi

awk '{ 
    for (i=1; i<= NF; i++) {                                                    # going for all records line
        if (NR!=1) {                                                            # if now first line with rowname
            if (i==2) loc=substr($i, 0, length($i))                             # get location id
            if (i==3) {
                name=tolower(substr($i,0, 1))                                   # get first character symbol
                surname=tolower(substr($i,index($i, " ")+1, length($i)))        # get surname
                $i=toupper(substr($i,0, 1)) tolower(substr($i,2, index($i," ")-1))  
                    toupper(substr($i,index($i, " ")+1, 1)) 
                    tolower(substr($i,index($i, " ")+2, 
                    length($i)-index($i," ")+2))  # generate uppercase for first character for name and surname
            }
            if (i==5) $i= name surname loc "@abc.com"                           # generate new email
        }
        printf $i ","
    }
    printf("\n");       #if last record in line send end line
 }' FPAT='([^,]*)|("[^"]+")'  $1 > accounts_new.csv
    # FPAT save for parsing difficuilt records with comma in double qoute string
