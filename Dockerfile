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

# Configurar MySQL: arrancar el servicio, configurar y detenerlo
RUN service mysql start && \
    mysql -e "CREATE DATABASE IF NOT EXISTS mydb;" && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpassword';" && \
    mysql -e "FLUSH PRIVILEGES;" && \
    service mysql stop

# Configurar SSH
RUN echo 'root:rootpassword' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Generar claves SSH
RUN ssh-keygen -A

EXPOSE 3306 22

# Comando de inicio (mantiene servicios activos)
CMD service mysql start && service ssh start && tail -f /dev/null
