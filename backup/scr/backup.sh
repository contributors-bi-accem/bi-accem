#!/bin/bash

#   Backup script to backup data from "Gorrion" system into a backup file.
#   
#   The script opens a file unload_gorrion_YYYYMMDD.tar.gz that contains
#   one flat file for each extracted table (named unload_<table>_YYYYMMDD.dat)
#   and each file into its corresponding table in ODS.
#
#   Script output:
#           &1: 0 if script succeeds, !=0 otherwise.
#           &2: stderr redirected to sdtout.
#           

# recuperamos el diretorio del script, el directorio base es el padre
base_dir="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"

# importación del script común
com_scr="$base_dir"/../common/scr/common.sh
if ! . "$com_scr"; then
    printf "%s\tERROR\tNo se puede acceder al fichero de parametros %s.\n" "$(date +'%Y-%m-%d %T')" "$com_scr" 
    printf "%s\tERROR\t%s finalizado en error.\n\n" "$(date +'%Y-%m-%d %T')" "$0"
    exit 1;
fi

# importamos las variables de entorno del fichero de configuración
import "$base_dir"/conf/params.cfg || exit 1;

# redirigimos stdout y stderr hacia el fichero de log.
exec 1>>"$logs_path""$logfile_prefix"$(date +'%Y-%m-%d').log 2>&1

# inicialización de variables
start "$0" "$@"
resultado=0;

# comprobamos si se puede leer el fichero de credenciales
if [ ! -e "$mysql_cnfpath" ]; then
    error "No se puede acceder al fichero de credenciales MySQL %s.\n" "$mysql_cnfpath"
    exit 1;
fi

fichero="$backup_dir"/"$backup_file_prefix"$(date +"$bash_datefmt").sql 
info "Fichero output:%s\n" "$fichero"

exe mysqldump --defaults-file="$mysql_cnfpath" --user="$mysql_user" --add-drop-table --dump-date --extended-insert --events \
          --routines --flush-logs --replace --result-file="$fichero" "$mysql_db"
resultado=$?

# Comprimimos el fichero de backup
if [ "$resultado" == 0 ]; then
    
    fichero_tar="$backup_dir"/"$backup_file_prefix"$(date +'%Y%m%d').tar.gz
    exe tar --remove-files -czv --file "$fichero_tar" "$fichero"
    resultado=$?
    
    if [ "$resultado" != 0 ]; then
        error "Error al generar el archivo comprimido %s\n" "$fichero_tar"
    else 
        info "Generado el archivo comprimido %s\n" "$fichero_tar"
    fi
else
    error "No se ha generado ningun backup.\n"
fi

finish "$resultado"
exit "$resultado";
