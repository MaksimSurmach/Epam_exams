#!bin/bash/

#######################################
# Parce input log file to output.json
#######################################

if [ -z "$1" ];                     # if sting empty
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
    if ( index($0, "[")==1 ){                                                                 # first line
       nameSample = substr($0,index($0, "[") + 1, (index($0, "]")-(index($0, "[")+1)))
       numberOfTests = substr($0, index($0,"..")+2, index($0,"tests") - index($0,"..") -3)    # get number of test 
       printf ("{" "\n")
       printf ("\"testname\": \""nameSample"\"," "\n")
    }
    if( NR==2 ){                        # start of array of test result
        printf ("\"tests\": [")
        printf ("\n")
    }
    if( NR==(numberOfTests+3) ){        # end of array of test result
        printf ("],")
        printf ("\n")
    }
    if( NR>2 && NR<numberOfTests+3 ){
        duration = substr($0, match($0, /[0-9]+ms/), match($0, /ms/))    # get test time from end of string
        name = substr($0, 
                    match($0, /[0-9] /) + length(numberOfTests)+2, 
                    match($0, /[0-9]+ms/) - length(duration)- match($0, /[0-9] /) - length(numberOfTests))   
                                                        # get name separate substring length deleting status and time 
        status = substr($0, 0, match($0, /[0-9]+/))     # get first character before number of test

        if(match(status, "not")) 
            status = "false"
        else 
            status = "true"      # set if test passed or not

        printf ("{" "\n")
        printf ("\"name\": \""name"\"," "\n")
        printf ("\"status\": \""status"\"," "\n")
        printf ("\"duration\": \""duration"\"" "\n")

        if(NR==numberOfTests+2)
            printf ("}" "\n")     # if last number of test we didnt wrote a comma
        else 
            printf ("}," "\n")
    }
} ENDFILE{           # last line
        
        printf ("\"summary\": {" "\n")
        success = substr($0, 0,match($0, /^[0-9]+/))                                       # get first digit from string
        failed = substr($0, 
                        match($0, /[0-9]+ tests failed/), 
                        match($0, /tests failed/)- match($0, /[0-9]+ tests failed/))       # find test failed number
        rating = substr($0,
                        match($0, /rated as/) +9,
                        match($0, /%/) - match($0, /rated/) - 9 )                        # find rating without % symbol
        durationALL = substr($0, match($0, /spent/)+6, length($0)) 
        printf ("\"success\": \""success"\","  "\n")
        printf ("\"failed\": \""failed"\","  "\n")
        printf ("\"rating\": \""rating"\","  "\n")
        printf ("\"duration\": \""durationALL"\""  "\n")
        printf ("}" "\n")
        printf ("}" "\n")    # end of file
    }' $1 > output.json



