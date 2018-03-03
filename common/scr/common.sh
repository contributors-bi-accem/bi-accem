#
#   Script común con funciones y utilidades
#   

inicio=$(date +'%s');
script="";

# loggea una información
info () {
    printf "%s\tINFO\t" "$(date +'%Y-%m-%d %H:%M:%S')";
    printf "$@" ;
}

# loggea un error rojo en un terminal
error_red () {
    red=$(tput setaf 1);
    normal=$(tput sgr0);
    printf "${red}%s\tERROR\t" "$(date +'%Y-%m-%d %H:%M:%S')" ;
    if [ $# -gt 1 ]; then
        printf "$1""${normal}" "${@:2}" ;
    else    
        printf "$1""${normal}" ;
    fi
}

# loggea un error
error () {
    printf "%s\tERROR\t" "$(date +'%Y-%m-%d %H:%M:%S')";
    printf "$@" ;
}

# importación de parametros del script
import () {
    if ! . "$1"; then
        error "No se puede acceder al fichero de parametros %s.\n" "$1"
        error "Script finalizado en error.\n"
        exit 1;
    fi
}

# log de inicio de script
start () {
    script="$1"
    printf "\n"
    info "Arrancando %s" "$script";
    if [ $# -gt 1 ]; then
        printf " con parametro(s):\n"
        for param in "${@:2}"
        do
            printf "\t\t\t\t%s\n" "$param"
        done
    else    
        printf "\n";
    fi
}

# ejecuta un comando y lo escribe en el log
exe () {
    info "";
    ( set -x ; "$@" ; )
    return "$?";
}

finish () {

    # Comprimimos los logs de mas de 30 días (no pasa nada si falla)
    info "Comprimimos los logs de mas de %s días.\n" "$logfile_compress"
    find "$logs_path""$logfile_prefix"*.log -type f -mtime +"$logfile_compress" -execdir tar --remove-files -cvz --file {}.tar.gz {} \;

    # Borramos los logs (comprimidos) de mas de 90 días (no pasa nada si falla)
    info "Borramos los logs comprimidos de mas de %s días.\n" "$logfile_del"
    find "$logs_path""$logfile_prefix"*.tar.gz -type f -mtime +"$logfile_del" -delete;

    # Devolvemos el resultado combinado del sql y del tar
    fin=$(date +'%s');
    duration=$(( $fin - $inicio ));
    if [ "$1" -eq 0 ]; then  
        info "%s finalizado correctamente en %u min %u sec.\n\n" "$script" $(($duration/60)) $(($duration%60))
    else 
        error "%s finalizado en error en %u min %u sec.\n\n" "$script" $(($duration/60)) $(($duration%60))
    fi
}
