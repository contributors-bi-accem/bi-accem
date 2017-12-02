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

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

# Lanzamos la descarga en remoto
ssh -p "$port" -i "$private_key" "$user"@"$server" "$remote_scr_dir"unload.sh
resultado=$?

# Recuperamos los ficheros
if [ "$resultado" == 0 ]; then
    "$base_dir"scr/remote-copy.sh
    resultado=$?
fi

# Lanzamos el loader
if [ "$resultado" == 0 ]; then
    "$base_dir"scr/loader.sh
    resultado=$?
fi

# Lanzamos el staging
if [ "$resultado" == 0 ]; then
    sql_file="$base_dir"sql/staging.sql
    "$base_dir"scr/execute-sql.sh "$sql_file"
    resultado=$?
fi

# Lanzamos las transformaciones
if [ "$resultado" == 0 ]; then
    sql_file="$base_dir"sql/transform.sql
    "$base_dir"scr/execute-sql.sh "$sql_file"
    resultado=$?
fi


# Comprimimos los logs de mas de 30 días
printf "Info: Comprimimos los logs de mas de %s días.\n" "$logfile_compress"
find "$logs_path""$logfile_prefix"*.log -type f -mtime +"$logfile_compress" -execdir tar --remove-files -cvz --file {}.tar.gz {} \;

# Borramos los logs (comprimidos) de mas de 90 días
printf "Info: Borramos los logs comprimidos de mas de %s días.\n" "$logfile_del"
find "$logs_path""$logfile_prefix"*.tar.gz -type f -mtime +"$logfile_del" -delete;

# Devolvemos el resultado combinado del sql y del tar
if [ "$resultado" -eq 0 ]; then
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    printf "Info: Carga completa finalizada en %u min %u sec.\n" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script finalizado con errores.\n"
fi

exit "$resultado";
