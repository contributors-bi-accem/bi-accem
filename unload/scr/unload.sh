#!/bin/bash

#   Unload script to extract data from "Gorrion" system.
#   
#   The script generates a file unload_gorrion_YYYYMMDD.tar.gz that contains
#   one flat file for each extracted table (named unload_<table>_YYYYMMDD.dat). 
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
from_ts="";
to_ts="";
inicio=$(date +'%s');
str_now=$(date -d @$inicio +'%Y-%m-%d %H:%M:%S');
param_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$';
lastdatefile="$base_dir"scr/.lastdate;

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

# comprobamos si se puede leer el fichero de credenciales
if [ ! -e "$mysql_cnfpath" ]; then
    printf "Error: no se puede acceder al fichero de credenciales MySQL %s.\n" "$mysql_cnfpath" >&2
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

# fichero sql a lanzar
sql_file="$base_dir"sql/unload_gorrion.sql

# lanzamos el script sql
mysql --defaults-file="$mysql_cnfpath" --user="$mysql_user" --database="$mysql_db" --execute=" \
SET @from_ts='${from_ts}'; \
SET @to_ts='${to_ts}'; \
SET @unload_dir='${unload_dir}'; \
SET @file_prefix='${datafile_prefix}'; \
SET @file_datefmt='${mysql_datefmt}'; \
source ${sql_file};"

res_sql=$?
if [ "$res_sql" != 0 ]; then
    printf "Error: error en la ejecución del script SQL %s\n" "$sql_file"
else
    printf "Info: Queries ejecutadas correctamente.\n"
fi

# Probamos a ver si se han creado los ficheros resultantes
patron_ficheros="$datafile_prefix"\*_$(date --date="$to_ts" +"$bash_datefmt").dat

# nombre del fichero tar.gz de salida
fichero="$datafile_prefix"$(date --date="$to_ts" +"$bash_datefmt").tar.gz

# nos movemos al directorio de descarga para hacer un tar sin estructura de directorios
cd "$unload_dir";
for f in $patron_ficheros; do
    # si no hay ficheros, el test a continuación dara "false", 
    # sino tenemos claro que hay por lo menos un fichero.
    if [ -f "$f" ]; then
        files_exist=SI
    else
        files_exist=NO
    fi;
    break
done

# Si hay ficheros resultantes, los comprimimos en un tar.gz
res_tar=0
if [ "$files_exist" == "SI" ]; then
    tar --remove-files -czv --file "$fichero" $patron_ficheros
    res_tar=$?
    if [ "$res_tar" != 0 ]; then
        printf "Error: error al generar el archivo comprimido %s\n" "$fichero" >&2
    else 
        printf "Info: Generado el archivo comprimido %s\n" "$fichero"
    fi
else
    printf "Error: no se ha generado ninguna descarga.\n" >&2
fi

# Si todo ha ido bien, guardamos la fecha en el fichero lastdatefile para la proxima ejecución.
if [ "$res_sql" == 0 ]; then
    echo "$to_ts" > "$lastdatefile";
    printf "Info: Actualizado la fecha a %s en el archivo %s\n" "$to_ts" "$lastdatefile"
fi

# Borramos los datos de mas de 30 días
find "$unload_dir""$datafile_prefix"*.tar.gz -type f -mtime +"$datafile_del" -delete;

# Comprimimos los logs de mas de 30 días
find "$logs_path""$logfile_prefix"*.log -type f -mtime +"$logfile_compress" -execdir tar --remove-files -cvz --file {}.tar.gz {} \;

# Borramos los logs (comprimidos) de mas de 90 días
find "$logs_path""$logfile_prefix"*.tar.gz -type f -mtime +"$logfile_del" -delete;

# Devolvemos el resultado combinado del sql y del tar
resultado=$(( $res_sql || $res_tar ));
if [ $resultado == 0 ]; then
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    printf "Info: Descarga finalizada en %u min %u sec.\n" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script finalizado con errores.\n"
fi

exit "$resultado";
