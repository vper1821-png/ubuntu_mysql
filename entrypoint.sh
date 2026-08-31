#!/bin/bash
set -e

# 1. FORZAR BIND-ADDRESS A 0.0.0.0 (escuchar en todas las IPs)
# Esto se hace ANTES de arrancar MySQL por primera vez
sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || echo "bind-address = 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# 2. INICIALIZAR LA BASE DE DATOS (si es la primera ejecución)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">> Inicializando base de datos MySQL por primera vez..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

    # Arrancar MySQL en segundo plano para configurarlo
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    
    # Esperar a que el socket esté disponible
    while [ ! -S /var/run/mysqld/mysqld.sock ]; do sleep 1; done
    
    # Ejecutar comandos SQL
    mysql -u root --socket=/var/run/mysqld/mysqld.sock <<EOF
CREATE DATABASE IF NOT EXISTS mydb;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'rootpassword';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    
    # Detener el proceso de mysqld (lo levantaremos de nuevo al final)
    mysqladmin -u root -prootpassword --socket=/var/run/mysqld/mysqld.sock shutdown
    echo ">> Configuración inicial completada."
else
    echo ">> Base de datos ya inicializada."
fi

# 3. INICIAR SERVICIOS EN PRIMER PLANO
service mysql start
service ssh start

# 4. MANTENER EL CONTENEDOR VIVO
tail -f /dev/null
