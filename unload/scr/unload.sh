#!/bin/bash

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

# Importación de parametros del script
if ! . ../conf/params.cfg; then
    printf "Error: no se puede acceder al fichero de parametros.\n"
    exit 1;
fi

# redirigimos stdout y stderr hacia el log.
exec 1>>"$logs_path""$file_prefix"$(date +'%Y-%m-%d').log 2>&1
     
# Inicialización de variables
from_ts="";
to_ts="";
inicio=$(date +'%s');
str_now=$(date -d @$inicio +'%Y-%m-%d %H:%M:%S');
param_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$';

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

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
    if [[ $1 =~ $2 ]] && date --date "$1" >/dev/null 2>&1; then
            return 0;
    else
        #printf "Info: fecha incorrecta: %s\n" "$1";
        return 1;
    fi
}

# primero comprobamos si se ha especificado un parametro de ejecución
if testDateFormat "$1" "$param_regex"; then
    printf "Info: fecha min recuperada del primer parametro: %s.\n" "$1";
    from_ts="$1"
else
    # si no se ha especificado ningun argumento, la recuperamos del fichero .lastdate
    if [ -e "$lastdatefile" ] && from_ts=$(cat "$lastdatefile") && testDateFormat "$from_ts" "$param_regex"; then
        printf "Info: fecha min %s recuperada del fichero: %s.\n" "$from_ts" "$lastdatefile";
    else
        printf "Error: No se ha especificado ningun argumento valida y el fichero %s no contiene una fecha valida.\n" "$lastdatefile" >&2
        exit 1;
    fi
fi

# comprobamos si se ha especificado el segundo parametro de ejecución
if testDateFormat "$2" "$param_regex"; then
    printf "Info: fecha max recuperada del segundo parametro: %s.\n" "$2";
    to_ts="$2";
else
    printf "Info: no se ha especificado un segundo parametro, se usa %s.\n" "$str_now";
    to_ts=$str_now;
fi



# lanzamos el script sql
mysql --login-path="$mysql_loginpath" --database="$mysql_db" --execute=" \
SET @from_ts='${from_ts}'; \
SET @to_ts='${to_ts}'; \
SET @unload_dir='${unload_dir}'; \
SET @file_prefix='${file_prefix}'; \
SET @file_datefmt='${mysql_datefmt}'; \
source ${sql_file};"

resultado=$?
if [ "$resultado" != 0 ]; then
    printf "Error: error en la ejecución del script SQL %s\n" "$sql_file"
    exit 1;
else
    printf "Info: Queries ejecutadas correctamente.\n"
fi

# Probamos a ver si se han creado los ficheros resultantes
patron_ficheros="$file_prefix"\*_$(date --date="$to_ts" +"$bash_datefmt").dat

# nombre del fichero tar.gz de salida
fichero="$file_prefix"$(date --date="$to_ts" +"$bash_datefmt").tar.gz

cd "$unload_dir";
for f in $patron_ficheros; do
    # si no hay ficheros, el test a continuación dara "false", sino tenemos claro que hay por lo menos un fichero.
    if [ -f "$f" ]; then
        files_exist=SI
    else
        files_exist=NO
    fi;
    break
done

# Si hay ficheros resultantes, los comprimimos en un tar.gz
if [ "$files_exist" == "SI" ]; then
    tar --remove-files -czv --file "$fichero" $patron_ficheros
    resultado=$?
    if [ "$resultado" != 0 ]; then
        printf "Error: error al generar el archivo comprimido %s\n" "$fichero"
    else 
        printf "Info: Generado el archivo comprimido %s\n" "$fichero"
    fi
else
    printf "Error: no se ha generado ninguna descarga.\n" >&2
fi

# Si todo ha ido bien, guardamos la fecha en lastdatefile para la proxima ejecución.
if [ "$resultado" == 0 ]; then
    echo "$to_ts" > "$lastdatefile";
fi


# Borramos los datos de mas de 30 días
find "$unload_dir""$file_prefix"*.tar.gz -type f -mtime +30 -delete;

# Comprimimos los logs de mas de 30 días
find "$logs_path""$file_prefix"*.log -type f -mtime +30 -execdir tar --remove-files -cvz --file {}.tar.gz {} \;

# Borramos los logs de mas de 90 días
find "$logs_path""$file_prefix"*.tar.gz -type f -mtime +90 -delete;

fin=$(date +'%s');
duration=$(( $fin - $inicio ));
printf "Info: Descarga finalizada en %u min %u sec.\n" $(($duration/60)) $(($duration%60))
exit "$resultado";
