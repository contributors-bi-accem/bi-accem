#!/bin/bash
set -x
#   Unload script to extract data from "Gorrion" system.
#   
#   The script generates a file unload_gorrion_YYYYMMDD.tar.gz that contains
#   one flat file for each extracted table (named unload_<table>_YYYYMMDD.dat). 
#
#   Script execution parameters:
#           $1: from_ts  (Optional)     Timestamp in format YYYY-MM-DD_HH:mm:SS
#                                       Sets the lower limit of extraction.
#                                       if not set, the timestamp is read from ".lastdate" file.
#           $2: to_ts    (Optional)     Timestamp in format YYYY-MM-DD_HH:mm:SS
#                                       Sets the upper (more recent) limit of extraction.
#                                       if not set, the current system datetime is used.
#
#   Script output:
#           &1: 0 if script succeeds, !=0 otherwise.
#           &2: stderr redirected to sdtout.
#           

# path y prefijo de los logs
logs_path="../logs/"
file_prefix="unload_gorrion_"

# redirigimos stdout y stderr hacia el log.
exec 1>>"$logs_path""$file_prefix"$(date +'%Y-%m-%d').log 2>&1
     
# Inicialización de variables
from_ts="";
to_ts="";
now=$(date +'%s');
str_now=$(date -d @$now +'%Y-%m-%d %H:%M:%S');
param_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$';

printf "\nInfo: Iniciando %s con timestamp %s (%s).\n\n" $0 "$str_now" "$now";

# Importación de parametros del script
if ! . ../conf/params.cfg; then
    printf "Error: no se puede acceder al fichero de parametros.\n" >&2
    exit 1;
fi

# comprobamos si se puede leer el fichero de credenciales
if [ ! -e "$mysql_loginpath" ]; then
    printf "Error: no se puede acceder al fichero de credenciales MySQL %s.\n" "$mysql_loginpath" >&2
    exit 1;
fi 

# Comprueba si el formato de una fecha es correcto y si es una fecha valida.
# Parametros:   $1    el timestamp
#               $2    el formato (regex)
# Salida:       0 si ok, 1 sino.
function testDateFormat(){
    if [[ $1 =~ $2 ]]; then
        printf "ok regex\n";
        res=date -d "$1" >/dev/null 2>&1;
        printf "res=%s\n" "$res";
        if [ date -d '"$1"' >/dev/null 2>&1 ]; then
            printf "ok date\n";
            return 0;
        fi
    fi
    return 1;
}

# primero comprobamos si se ha especificado un parametro de ejecución
temp_from_ts="";
if [ -n "$1" ]; then
    # comprobamos si el argumento tiene el formato "NNNN-NN-NN NN:NN:NN"
    printf "date:%s, regex:%s.\n" "$1" "$param_regex";
    if testDateFormat "$1" "$param_regex"; then
        from_ts=$1
        printf "from_ts: %s\n" "$from_ts"
    else
        printf "Error: timestamp de extracción informado pero mal formateado (se espera YYYY-MM-DD HH:MM:SS).\n" >&2
        exit 1;
    fi
else 
    # si no se ha especificado ningun argumento, la recuperamos del fichero .lastdate
    if ! . "$lastdatefile"; then
        printf "Error: No se ha especificado ningun argumento y el fichero %s no esta presente.\n" "$lastdatefile" >&2
        exit 1;
    else
        from_ts=$(cat "$lastdatefile")
        if ! testDateFormat "$from_ts" "$param_regex"; then
            printf "Error: timestamp mal formateado en el fichero %s.\n" "$lastdatefile" >&2
            exit 1;
        fi
    fi
fi

# comprobamos si se ha especificado el segundo parametro de ejecución
if [ -n "$2" ]; then
    # comprobamos si el argumento tiene el formato "NNNN-NN-NN NN:NN:NN"
    printf "date2:%s, regex:%s.\n" "$2" "$param_regex";
    if testDateFormat "$2" "$param_regex"; then
        to_ts="$2";
        printf "to_ts: %s\n" "$from_ts"
    else
        printf "Error: timestamp de maxima extracción informado pero mal formateado (se espera YYYY-MM-DD HH:MM:SS).\n" >&2
        exit 1;
    fi
else
    printf "Info: no se ha especificado un segundo parametro, se usa %s.\n" "$str_now";
    to_ts=$str_now;
fi

# nombre del fichero de salida
fichero="$file_prefix""$to_ts".tar.gz

# lanzamos el script sql
mysql --login-path="$mysql_loginpath" --database="$mysql_db" --execute=" \
set @from_ts='${from_ts}'; \
set @to_ts='${to_ts}'; \
set @unload_dir='${unload_dir}'; \
set @file_prefix='${file_prefix}'; \
source ${sql_file};"

resultado=$?
if [ "$resultado" != 0 ]; then
    printf "Error: error en la ejecución del script SQL %s\n" "$sql_file"
    exit 1;
else
    printf "Info: Queries ejecutadas correctamente.\n"
fi

# Probamos a ver si se han creado los ficheros resultantes
patron_ficheros="$file_prefix"\*_"$to_ts".dat
for f in $patron_ficheros; do
    # si no hay ficheros, el test a continuación dara "false", sino pues tenemos claro que hay por lo menos un fichero.
    if [ -f "$f" ]; then
        files_exist=SI
    else
        files_exist=NO
    fi;
    break
done

# Si hay ficheros resultantes, los comprimimos en un tar.gz
if [ "$files_exist" == "SI" ]; then
    tar --remove-files -czvf "$fichero" "$patron_ficheros"
    resultado=$?
    if [ "$resultado" != 0 ]; then
        printf "Error: error al generar el archivo comprimido %s\n" "$fichero"
        exit "$resultado";
    fi
else
    printf "Error: no se ha generado ninguna descarga.\n" >&2
    exit 1;
fi
printf "Info: Generado el archivo comprimido %s\n" "$fichero"

# Comprimimos los logs de mas de 30 días
find ../logs/*.log -mtime +30 -exec tar --remove-files -cvfz {}.tar.gz {};

# Borramos los logs de mas de 90 días
find ../logs/*.tar.gz -mtime +90 -delete;

exit "$resultado";
