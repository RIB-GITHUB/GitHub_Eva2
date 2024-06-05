# Dockerfile + Nagios Prueba 2 Virtualizacion

# Se usa la version mas reciente de ubuntu
FROM ubuntu:latest

# Establece variables de entorno (desactiva la interaccion del usuario durante la instalacion)
ENV DEBIAN_FRONTEND=noninteractive

# La imagen debe incluir todas las dependencias necesarias para que Nagios funcione correctamente
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-gd \
    libgd-dev \
    wget \
    build-essential \
    unzip \
    autoconf \
    gcc \
    libc6 \
    make \
    snmp \
    libnet-snmp-perl \
    gettext \
    && apt-get clean

# Se crea el usuario nagios y se configuran los permisos que tendra
RUN useradd nagios && \
    groupadd nagcmd && \
    usermod -a -G nagcmd nagios && \
    usermod -a -G nagcmd www-data

# Se descarga y se instala nagios core
RUN cd /tmp && \
    wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz && \
    tar xzf nagios-4.4.6.tar.gz && \
    cd nagios-4.4.6 && \
    ./configure --with-command-group=nagcmd && \
    make all && \
    make install && \
    make install-init && \
    make install-commandmode && \
    make install-config && \
    make install-webconf

# Se descarga y se instala los plugins de nagios core
RUN cd /tmp && \
    wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz && \
    tar xzf nagios-plugins-2.3.3.tar.gz && \
    cd nagios-plugins-2.3.3 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && \
    make install

# Se configurea Apache para Nagios core
RUN a2enmod rewrite && \
    a2enmod cgi

# Se configura usuario y contraseña para nagios core
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiospassword

# Considera exponer el puerto 80 para acceder a la interfaz web de Nagios
EXPOSE 80

# Configura Nagios para que inicie automáticamente al arrancar el contenedor. Se configura log para registrar errores
CMD ["/bin/bash", "-c", "service apache2 start && service nagios start && tail -f /var/log/apache2/error.log"]
