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
tables=( "descripteur" "modalite" "observation" "obs_descript" "obs_mod" "personne" "questionnaire" 
    "compte" "groupe" "lier_groupe" "liste_droits" "QuestionComplexe" "succursale_groupe" )
resultado=0;

printf "\nInfo: Iniciando %s a las %s.\n" $0 "$str_now";

# comprobamos si se puede leer el fichero de credenciales
if [ ! -e "$mysql_loginpath" ]; then
    printf "Error: no se puede acceder al fichero de credenciales MySQL %s.\n" "$mysql_loginpath" >&2
    exit 1;
fi 


for datafile in `ls "$datafile_dir""$datafile_prefix"*.tar.gz | sort -V`; do 

    file_date=$(echo "$datafile" | grep -Po "([0-9]{8}_[0-9]{6})")

    printf "Info: abrimos el fichero %s (fecha %s)\n" "$datafile" "$file_date"
    tar -xvf "$datafile";
    res_tar=$?
    
    if [ "$res_tar" -eq 0 ]; then
        printf "Info: ficheros descomprimidos, lanzamos las queries.\n"

        # remplazamos variables en el fichero sql
        # fichero sql original
        sql_file="$base_dir"sql/load_ods.sql

        # fichero sql temporal con las variables sustituidas
        temp_sql_file="$base_dir"sql/.temp_load_ods.sql

        replacestr="";
        for t in tables; do
            replacestr=$replacestr"s|{"$t"_file}|""$datafile_dir""$datafile_prefix""$t""$file_date"".dat|g;"
        done;
        replacestr="$replacestrs""|{fieldseparator}|"$fieldseparator"|g;
        s|{endofline}|"$endofline"|g";
        printf "remplazos en sql: %s\n" "$replacestr";

        # remplazamos las cadenas de caracteres en el fichero sql
        sed -e "$replacestr" < "$sql_file" > "$temp_sql_file";

        # lanzamos el script sql
        mysql --login-path="$mysql_loginpath" --database="$mysql_db" --execute="source ${temp_sql_file};"
        
        res_sql=$?
        if [ "$res_sql" -ne 0 ]; then
            printf "Error: error en la ejecución del script SQL %s\n" "$sql_file"

            # movemos el fichero al directorio de los errores 
            mv "$datafile" "$bck_failed_dir"
        else
            printf "Info: Queries ejecutadas correctamente.\n"

            # movemos el fichero al directorio de exitos
            mv "$datafile" "$bck_success_dir"
        fi

        #borramos el fichero sql temporal
        rm "$temp_sql_file";
    else
        printf "Error: No se ha conseguido descomprimir el fichero %s\n" "$datafile" >&2

        # movemos el fichero al directorio de los errores 
        mv "$datafile" "$bck_failed_dir"
    fi

    printf "Info: Borramos los datos extraidos temporalmente.\n"
    # borramos los ficheros extraidos
    find "$datafile_dir""$datafile_prefix"*_"$file_date".dat -type f -delete;
    
    # guardamos traza del error
    if [ $(( $res_sql || $res_tar )) -eq 1 ]; then
        resultado=1;
    fi
done;

# Borramos los datos de mas de 3650 días (10 años)
printf "Info: Borramos los datos de mas de %s días (10 años).\n" "$datafile_del"
find "$unload_dir""$datafile_prefix"*.tar.gz -type f -mtime +"$datafile_del" -delete;

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
    printf "Info: Carga finalizada en %u min %u sec.\n" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script finalizado con errores.\n"
fi

exit "$resultado";
