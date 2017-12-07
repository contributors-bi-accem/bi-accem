#!/bin/bash

#   Loader script to import data from "Gorrion" system into ODS.
#   
#   The script opens a file unload_gorrion_YYYYMMDD.tar.gz that contains
#   one flat file for each extracted table (named unload_<table>_YYYYMMDD.dat)
#   and each file into its corresponding table in ODS.
#
#   Script execution parameters:
#           $1: from_ts  (Optional)     Timestamp in format "YYYY-MM-DD HH:mm:SS"
#                                       Sets the lower limit of extraction.
#                                       if not set, the timestamp is read from ".lastdate" file.
#           $2: to_ts    (Optional)     Timestamp in format "YYYY-MM-DD HH:mm:SS"
#                                       Sets the upper (more recent) limit of extraction.
#                                       if not set, the current system datetime is used.
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

# redirigimos stdout y stderr hacia el fichero de log.
exec 1>>"$logs_path""$logfile_prefix"$(date +'%Y-%m-%d').log 2>&1
     
# inicialización de variables
inicio=$(date +'%s');
str_now=$(date -d @$inicio +'%Y-%m-%d %H:%M:%S');
resultado=0;
from_ts="";
to_ts="";
param_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$';
lastdatefile="$base_dir"scr/.lastdate;

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

# Comprueba si el formato de una fecha es correcto y si es una fecha valida.
# Parametros:   $1    el timestamp
#               $2    el formato (regex)
# Salida:       0 si ok, 1 sino.
function testDateFormat(){
    if [[ $1 =~ $2 ]] && date --date "$1" >/dev/null 2>&1; then
            return 0;
    else
        #printf "Info: fecha incorrecta: %s\n" "$1";
        return 1;
    fi
}

# primero comprobamos si se ha especificado un parametro de ejecución que nos da la fecha min
if testDateFormat "$1" "$param_regex"; then
    printf "Info: fecha min recuperada del primer parametro: %s.\n" "$1";
    from_ts="$1";
else
    # si no se ha especificado ningun argumento, la recuperamos del fichero .lastdate
    if [ -e "$lastdatefile" ] && from_ts=$(cat "$lastdatefile") && testDateFormat "$from_ts" "$param_regex"; then
        printf "Info: fecha min %s recuperada del fichero: %s.\n" "$from_ts" "$lastdatefile";
    else
        printf "Error: Argumento no valido, el fichero %s no contiene una fecha valida. Usamos \"1900-01-01 00:00:00\".\n" "$lastdatefile" >&2
        from_ts="1900-01-01 00:00:00";
    fi
fi

# comprobamos si se ha especificado el segundo parametro de ejecución que nos da la fecha max
if testDateFormat "$2" "$param_regex"; then
    printf "Info: fecha max recuperada del segundo parametro: %s.\n" "$2";
    to_ts="$2";
else
    printf "Info: no se ha especificado un segundo parametro, se usa para fecha max: %s.\n" "$str_now";
    to_ts=$str_now;
fi

# Lanzamos el staging
if [ "$resultado" == 0 ]; then
    sql_file="$base_dir"sql/staging.sql
    mysql --user="$mysql_user" --password="$mysql_pass" -vv --database="$mysql_db" --show-warnings \
    --execute="SET @from_ts='${from_ts}'; SET @to_ts='${to_ts}'; source ${sql_file};"
    resultado=$?
    # Si todo ha ido bien, guardamos la fecha en el fichero lastdatefile para la proxima ejecución.
    if [ "$resultado" == 0 ]; then
        echo "$to_ts" > "$lastdatefile";
        printf "Info: Actualizado la fecha a %s en el archivo %s\n" "$to_ts" "$lastdatefile"
    fi
fi

# Lanzamos las transformaciones
if [ "$resultado" == 0 ]; then
    sql_file="$base_dir"sql/transform.sql
    mysql --user="$mysql_user" --password="$mysql_pass" -vv --database="$mysql_db" --show-warnings \
    --execute="source ${sql_file};"
    resultado=$?
fi


# Comprimimos los logs de mas de 30 días (no pasa nada si falla)
printf "Info: Comprimimos los logs de mas de %s días.\n" "$logfile_compress"
find "$logs_path""$logfile_prefix"*.log -type f -mtime +"$logfile_compress" -execdir tar --remove-files -cvz --file {}.tar.gz {} \; 2>/dev/null

# Borramos los logs (comprimidos) de mas de 90 días (no pasa nada si falla)
printf "Info: Borramos los logs comprimidos de mas de %s días.\n" "$logfile_del"
find "$logs_path""$logfile_prefix"*.tar.gz -type f -mtime +"$logfile_del" -delete; 2>/dev/null

# Devolvemos el resultado combinado del sql y del tar
if [ "$resultado" -eq 0 ]; then
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    printf "Info: Carga completa finalizada en %u min %u sec.\n" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script finalizado con errores.\n"
fi

exit "$resultado";
