#!/bin/bash

cleanexit()
{
    unset pars comps
    echo "result : "$1
    exit $1;
}

formdate=`date +%Y-%m-%d-%H-%M`;

declare -A pars=( ['dbhost']="localhost" ['username']="root" ['dbname']="test" ['outfilename']="[dbname]-[date-heure].sql" ['errlogfilename']="mysqldump-${formdate}.error.log" );


for param in ${!pars[@]}
do
    read -p "${param} (${pars[$param]}) : " VALUE
    if [ "$VALUE" != "" ]; then
       pars[$param]="$VALUE"
    fi
done

# Replace [dbname] with $dbname & [date_heure] with $formdate
dbname=${pars['dbname']}
pars['outfilename']="${pars['outfilename']/\[dbname\]/$dbname}"
pars['outfilename']="${pars['outfilename']/\[date-heure\]/$formdate}"
#echo ${pars['outfilename']}

## @TODO : COMPRESSION
#comps=('none' 'zip' '7z' 'tgz' 'tbz');
#while [[ !(" ${comps[@]} " =~ " ${COMP} ") ]]; do
#    read -p "compression ? (${comps[*]}) : " COMP
#done

## @TODO : Create variables taking names from $pars
## @TODO : Option -f <parameters.file> to take parameters from file

# mysqldump options
# Use of --opt is the same as specifying --add-drop-table, --add-locks, --create-options,
# --disable-keys, --extended-insert, --lock-tables, --quick, and --set-charset.
# All of the options that --opt stands for also are on by default because --opt is on by default.

mysqldump -h "${pars['dbhost']}" -u "${pars['username']}" -p --opt --add-drop-database --flush-privileges --comments --dump-date --log-error="${pars['errlogfilename']}" ${pars['dbname']} > "${pars['outfilename']}"

cleanexit $?