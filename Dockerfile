FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar paquetes
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

# Configurar MySQL usando mysqld --bootstrap (sin necesidad de iniciar el servicio)
RUN mysqld --bootstrap <<EOF
CREATE DATABASE IF NOT EXISTS mydb;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';
FLUSH PRIVILEGES;
EOF

# Configurar SSH
RUN echo 'root:rootpassword' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Generar claves SSH
RUN ssh-keygen -A

EXPOSE 3306 22

# Script de inicio (mantiene ambos servicios activos)
CMD service mysql start && service ssh start && tail -f /dev/null
