Instalacion de nagios utilizando Docker

- Se hizo este proceso en windows 10, ademas se descarga e instala lo siguiente: 
Docker Desktop - git bash - notepad++
- Utilizando notepad++ se empieza a crear el Dockerfile
- Se utiliza la ultima version de ubuntu
  FROM ubuntu:latest
- Se establecen variables de entorno (Se desactiva la interaccion del usuario durante la instalacion)
  ENV DEBIAN_FRONTEND=noninteractive
- Se definen las dependencias para que nagios funcione
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
- Se crea usuario nagios, con permisos para crear, configurar usuarios y grupos en el sistema operativo dentro del contenedor
  RUN useradd nagios && \
    groupadd nagcmd && \
    usermod -a -G nagcmd nagios && \
    usermod -a -G nagcmd www-data
- Se realiza la descarga y se ejecuta la instalacion de nagios
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
  - Se obtienen pluggins de nagios y se instalan
    RUN cd /tmp && \
    wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz && \
    tar xzf nagios-plugins-2.3.3.tar.gz && \
    cd nagios-plugins-2.3.3 && \
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && \
    make install
  - Se configura Apache para nagios core
    RUN a2enmod rewrite && \
    a2enmod cgi
  - Se configura usuario y contraseña para nagios core (Para entrar por web)
    RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiospassword
  - Para revisar nagios en la web, se deja puerto 80 visible
    EXPOSE 80
  - Se realiza configuracion para que nagios se ejecute automaticamente al iniciar el contenedor, ademas de registar errores en log
    CMD ["/bin/bash", "-c", "service apache2 start && service nagios start && tail -f /var/log/apache2/error.log"]

- Luego de lo anterior, se guarda archivo con el nombre "Dockerfile" y el tipo para guardar es "All types"
- abre una terminal, y por comandos ingresa a la carpeta en donde se guardo el archivo Dockerfile (c:/tu-carpeta)
- ejecuta el siguiente comando: "docker build -t nagios-core ." con esto se empieza a construir la imagen Docker (Este proceso de demora unos 10 a 15 min)
- cuando termine, ejecuta el siguiente comando: "docker run -d -p 80:80 --name nagios-container nagios-core" Con esto se crea el contenedor docker
- Se pueden verificar que los pasos anteriores fueron exitosos con Docker Desktop. En las pestañas "Containers" e "Images" Deberia aparecer la configuracion que se ha hecho
- El status del container deberia ser "Running" y el de la imagen "In use"
- En el navegador de preferencia, debes ir a la siguiente pagina: "http://http://localhost/nagios/" esto es para revisar, de forma local, si la instalacion quedo ok
- Te pedira un usuario y contraseña. Utiliza nagiosadmin y nagiospassword respectivamente
- Si ingresaste, te deberia mostrar informacion basada en Nagios
- En docker Desktop, si detienes las instancias, ya no podras acceder al sitio local de nagios

- Para subir el dockerfile a la web, se debe hacer lo siguiente:
  crear cuenta en github
  dejar en publico
- Utilizando git bash, debes llegar por comandos a la carpeta en donde esta el archivo Dockerfile
- Ejecutar los siguientes comandos:
  git init
  git add Dockerfile
  git commit -m "Initial commit"
  git remote add origin https://github.com/el-usuario-que-creaste/nagios-docker.git
  git push -u origin master
  
- con esto se vera la informacion de tu Dockerfile en la web de github
