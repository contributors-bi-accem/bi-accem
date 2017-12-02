#!/bin/bash

#   Loader script to import data from "Gorrion" system into ODS.
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
declare -a tables=("descripteur" "modalite" "observation" "obs_descript" 
        "obs_mod" "personne" "questionnaire" "compte" "groupe" "lier_groupe" 
        "liste_droits" "QuestionComplexe" "succursale_groupe");
resultado=0;

printf "\nInfo: Iniciando %s a las %s.\n" "$0" "$str_now";

# comprobamos si se puede leer el fichero de credenciales
if [ ! -e "$private_key" ]; then
    printf "Error: no se puede acceder al fichero de clave privada %s.\n" "$private_key" >&2
    exit 1;
fi

# descargamos los ficheros al servidor local
scp -q -P 979 -i "$private_key" "$user"@"$server":"$remote_dir""$datafile_prefix"*.tar.gz "$datafile_dir"
resultado=$?

if [ "$resultado" -eq 0 ]; then
    # borramos los ficheros remotos
    ssh -q -P 979 -i "$private_key" "$user"@"$server" rm -f "$remote_dir""$datafile_prefix"*.tar.gz
    resultado=$?
done;

# Devolvemos el resultado
if [ "$resultado" -eq 0 ]; then
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    printf "Info: %s finalizado en %u min %u sec.\n" "$0" $(($duration/60)) $(($duration%60))
else 
    printf "Error: Script finalizado con errores.\n"
fi

exit "$resultado";
