# bi-accem
Contribuciones para el reporting de la organización

Script de descarga (carpeta unload)

Instrucciones de instalación:
1. Crear un usuario de lectura <usuario_lectura> en el MySQL del servidor Gorrion
2. Crear un usuario de acceso en Linux <usuario_linux> en el servidor Gorrion con una contraseña fuerte.
3. Crear una carpeta <carpeta_datos> con 30 GB disponibles donde se van a descargar los ficheros
   Crear una carpeta <carpeta_logs> con 1 GB disponible para almacenar los logs
4. Crear una carpeta <carpeta_sw> con 10 MB disponible para copiar los scripts.
4. Configurar la seguridad de MySQL para que el servidor MySQL (usuario mysql en linux) pueda escribir en el directorio <carpeta_datos>:
    - configurar el parametro secure_file_priv en: 
      editar el fichero /etc/mysql/mysql.conf.d/mysqld.cnf
      añadir la línea: secure_file_priv=<carpeta_datos>
      En todo caso se puede deshabilitar dicha seguridad especificando secure_file_priv=""
    - configurar los permisos del directorio <carpeta_datos> para que el usuario linux <usuario_linux> pueda escribir en esa carpeta.
    - configurar la seguridad apparmor de Linux:
      editar el fichero /etc/apparmor.d/usr.sbin.mysqld
      añadir las lineas:
      <carpeta_datos>/ rw,
      <carpeta_datos>/** rw,
5. Con el usuario linux <usuario_linux>, ejecutar la utilidad mysql_config_editor para crear un fichero de credenciales del usuario MySql <usuario_lectura>:
    mysql_config_editor set --login-path=client --host=localhost --user=<usuario_lectura> --password
    por defecto, esa utilidad crea ese fichero en /home/<usuario_linux>/.mylogin.cnf
    comprobar que el fichero de credenciales está correctamente creado lanzando el comando:
    mysql --login-path=/home/<usuario_linux>/.mylogin.cnf
    Si se abre sesión en mysql, todo OK.
6. Copiar la carpeta unload del paquete de sw en <carpeta_sw>, poner permisos de ejecución al fichero unload/scr/unload.sh y adaptar el fichero unload/conf/params.conf a los parametros del entorno (rutas, etc).
7. Lanzar una prueba con <carpeta_sw>/unload/scr/unload.sh "2017-09-18 00:00:00"
   Los logs se crean en la carpeta logs configurada en los parametros (unload/conf/params.conf)
8. Planificar la ejecución del script unload.sh cada mañana a las 00:30 o cada x horas:
   con el usuario <usuario_linux>, lanzar crontab -e y especificar la frecuencia deseada.

