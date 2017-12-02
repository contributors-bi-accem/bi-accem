# bi-accem
Contribuciones para el reporting de la organización

# Script de descarga (carpeta unload)

## Instrucciones de instalación en el servidor e-gorrion:
1. Crear un usuario de lectura ```usuario_lectura``` en la base de datos MySQL del servidor e-Gorrion
2. Crear un usuario de acceso en Linux ```usuario_linux``` en el servidor Gorrion con una contraseña fuerte.
3. Crear una carpeta ```carpeta_datos``` con 30 GB disponibles donde se van a descargar los ficheros
4. Crear una carpeta ```carpeta_logs``` con 1 GB disponible para almacenar los logs
5. Crear una carpeta ```carpeta_sw``` con 10 MB disponible para copiar los scripts.
6. Configurar la seguridad de MySQL para que el servidor MySQL (usuario mysql en linux) pueda escribir en el directorio ```carpeta_datos```:
- Configurar el parametro secure_file_priv en: 
  - Editar el fichero ```/etc/mysql/mysql.conf.d/mysqld.cnf``` y añadir la línea: 
  ```
  secure_file_priv=carpeta_datos
  ```
  - En todo caso se puede deshabilitar dicha seguridad especificando ```secure_file_priv=""```
- Configurar los permisos del directorio ```carpeta_datos``` para que el usuario linux ```usuario_linux``` pueda escribir en esa carpeta.
  - Configurar la seguridad apparmor de Linux:
  - Editar el fichero ```/etc/apparmor.d/usr.sbin.mysqld``` y añadir las lineas:
  ```
     carpeta_datos/ rw,
     carpeta_datos/** rw,
     ```
7. Con el usuario linux ```usuario_linux```, ejecutar la utilidad mysql_config_editor para crear un fichero de credenciales del usuario MySql ```usuario_lectura```:
    ```
    mysql_config_editor set --login-path=client --host=localhost --user=<usuario_lectura> --password
    ```
  - Por defecto, esa utilidad crea ese fichero en /home/<usuario_linux>/.mylogin.cnf
  - Comprobar que el fichero de credenciales está correctamente creado lanzando el comando:
    ```
    mysql --login-path=/home/<usuario_linux>/.mylogin.cnf
    ```
   Si se abre sesión en mysql, todo OK.
8. Copiar la carpeta unload del paquete de sw en ```carpeta_sw```, poner permisos de ejecución al fichero ```unload/scr/unload.sh``` y adaptar el fichero ```unload/conf/params.conf``` a los parametros del entorno (rutas, etc).
9. Lanzar una prueba con <carpeta_sw>/unload/scr/unload.sh "2017-09-18 00:00:00". Los logs se crean en la carpeta logs configurada en los parametros (unload/conf/params.conf)
10. Planificar la ejecución del script unload.sh por ejemplo cada mañana a las 00:30 o cada x horas: con el usuario ```usuario_linux```, lanzar: 
```
crontab -e
```
y especificar la frecuencia deseada.

## Instrucciones de uso
- El script admite 2 parametros opcionales de fecha en formato "YYYY-MM-DD HH:mm:SS": 
  - El primero especifica una fecha minima de datos en la extracción (para limitar las extracciones de obs_mod y obs_descript).
  - El segundo especifica una fecha maxima de datos en la extracción (para limitar las extracciones de obs_mod y obs_descript).
  - Ejemplo: 
  ```
  ./unload.sh "2016-01-01 00:00:00" "2017-01-01 00:00:00"
  ```
- El script genera un fichero ```.lastdate``` en el directorio ```scr``` donde se guarda el timestamp maximo de extracción. De ese modo, la siguiente ejecución esa fecha se puede utilizar para extraer los datos desde aquel timestamp.
- Si no se especifica ningun parametro, el script toma como fecha minima la fecha guardada en el fichero ```.lastdate```. Si el fichero no esta presente o legible, como por ejemplo en la primera ejecución, el script usa la fecha "1900-01-01 00:00:00".

En resumen, los parametros permiten forzar las fechas minima y maxima de extracción, pero solo con lanzar el script sin parametro debería funcionar según lo esperado.

# Script de carga y procesamiento (carpeta loader)

## Instrucciones de instalación en el servidor privado:

1. Crear una base de datos MySql ```datamart``` distinta de e-gorrion en un servidor separado.
2. Crear un usuario con todos los permisos ```usuario_servicio``` en la base de datos y otro usuario ```usuario_lectura``` solo con permisos de lectura.
3. Crear un usuario de acceso en Linux ```usuario_linux``` en el servvidor de la BBDD espejo con una contraseña fuerte.
4. Crear una carpeta ```carpeta_datos``` con 30 GB disponibles donde se van a descargar los ficheros desde el servidor e-gorrion.
5. Crear una carpeta ```carpeta_logs``` con 1 GB disponible para almacenar los logs.
6. Crear una carpeta ```carpeta_sw``` con 10 MB disponible para copiar los scripts.
6. Configurar la seguridad de MySQL para que el servidor MySQL (usuario mysql en linux) pueda escribir en el directorio ```carpeta_datos```:
- Configurar el parametro secure_file_priv en: 
  - Editar el fichero ```/etc/mysql/mysql.conf.d/mysqld.cnf``` y añadir la línea: 
  ```
  secure_file_priv=carpeta_datos
  ```
  - En todo caso se puede deshabilitar dicha seguridad especificando ```secure_file_priv=""```
- Configurar los permisos del directorio ```carpeta_datos``` para que el usuario linux ```usuario_linux``` pueda escribir en esa carpeta.
  - Configurar la seguridad apparmor de Linux:
  - Editar el fichero ```/etc/apparmor.d/usr.sbin.mysqld``` y añadir las lineas:
  ```
     carpeta_datos/ rw,
     carpeta_datos/** rw,
     ```
7. Con el usuario linux ```usuario_linux```, ejecutar la utilidad mysql_config_editor para crear un fichero de credenciales del usuario MySql ```usuario_lectura```:
    ```
    mysql_config_editor set --login-path=client --host=localhost --user=<usuario_lectura> --password
    ```
  - Por defecto, esa utilidad crea ese fichero en /home/<usuario_linux>/.mylogin.cnf
  - Comprobar que el fichero de credenciales está correctamente creado lanzando el comando:
    ```
    mysql --login-path=/home/<usuario_linux>/.mylogin.cnf
    ```
   Si se abre sesión en mysql, todo OK. 
 8. Copiar la carpeta loader del paquete de sw en ```carpeta_sw```, poner permisos de ejecución al fichero ```loader/scr/main.sh```,```loader/scr/loader.sh``` y ```loader/scr/execute-sql.sh``` y adaptar el fichero ```loader/conf/params.conf``` a los parametros del entorno (rutas, etc).
