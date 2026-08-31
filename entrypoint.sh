#!/bin/bash
set -e

# Configurar MySQL para escuchar en todas las interfaces
echo ">> Configurando MySQL para aceptar conexiones remotas..."
sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf || echo "bind-address = 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Si el directorio de datos está vacío, inicializar MySQL
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">> Inicializando base de datos MySQL por primera vez..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
    # Arrancar MySQL en segundo plano para ejecutar comandos
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    # Esperar a que el socket esté disponible
    while [ ! -S /var/run/mysqld/mysqld.sock ]; do sleep 1; done
    # Configurar root con contraseña, permitir acceso remoto y crear base de datos
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

# Iniciar servicios en primer plano
service mysql start
service ssh start

# Mantener el contenedor vivo
tail -f /dev/null
