FROM ubuntu:20.04

# Evitar prompts interactivos de apt
ENV DEBIAN_FRONTEND=noninteractive

# Instalar paquetes necesarios
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

# Configurar MySQL (crear base de datos y usuario root)
# Esperamos a que MySQL esté realmente disponible antes de ejecutar comandos
RUN service mysql start && \
    sleep 5 && \
    mysql -e "CREATE DATABASE IF NOT EXISTS mydb;" && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';" && \
    mysql -e "FLUSH PRIVILEGES;" && \
    service mysql stop

# Configurar SSH (root con password)
RUN echo 'root:rootpassword' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Generar claves SSH
RUN ssh-keygen -A

# Exponer puertos
EXPOSE 3306 22

# Script de inicio para mantener ambos servicios
CMD service mysql start && service ssh start && tail -f /dev/null
