#!/bin/bash

#   script to execute SQL scripts in  ODS.
#   
#   The script opens an sql file and execute it in Mysql database
#
#   Script execution parameters:
#           $1: sql_file  (Mandatory)   SQL file path
#
#   Script output:
#           &1: 0 if script succeeds, !=0 otherwise.
#           &2: stderr redirected to sdtout.
#           

# recuperamos el diretorio del script, el directorio base es el padre
base_dir="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"/

# importación de parametros del script
if ! . "$base_dir"conf/params.cfg; then
    printf "Error: no se puede acceder al fichero de parametros.\n"
    exit 1;
fi

# inicialización de variables
inicio=$(date +'%s');
str_now=$(date -d @$inicio +'%Y-%m-%d %H:%M:%S');
resultado=0;

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

sql_file="$1"
if [ ! -e "$sql_file" ]; then
    printf "Error: no se puede acceder al fichero SQL %s.\n" "$sql_file" >&2
    exit 1;
fi 

# lanzamos el script sql
#sql_file="$base_dir"sql/staging.sql
mysql --user="$mysql_user" --password="$mysql_pass" -vv --database="$mysql_db" --show-warnings --execute="source ${sql_file};"

resultado=$?

# Devolvemos el resultado combinado del sql y del tar
if [ "$resultado" -eq 0 ]; then
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    printf "Info: Script %s finalizado en %u min %u sec.\n" "$0" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script %s finalizado con errores.\n" "$0"
fi

exit "$resultado";
