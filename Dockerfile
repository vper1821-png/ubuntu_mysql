FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        mysql-server \
        openssh-server \
        sudo \
        vim \
        curl \
        wget \
        net-tools \
        iputils-ping \
        && rm -rf /var/lib/apt/lists/*

# 1. Inicializa el directorio de datos (crea la base de datos mysql)
RUN mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

# 2. Ahora ejecuta los comandos SQL con bootstrap
RUN mysqld --bootstrap --user=mysql --datadir=/var/lib/mysql <<EOF
CREATE DATABASE IF NOT EXISTS mydb;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
FLUSH PRIVILEGES;
EOF

# Configurar SSH
RUN echo 'root:rootpassword' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN ssh-keygen -A

EXPOSE 3306 22

CMD service mysql start && service ssh start && tail -f /dev/null
