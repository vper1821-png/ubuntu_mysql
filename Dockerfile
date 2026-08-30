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

# Configurar SSH (contraseña root y permitir login)
RUN echo 'root:rootpassword' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# Copiar script de entrada y dar permisos
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306 22

ENTRYPOINT ["/entrypoint.sh"]
