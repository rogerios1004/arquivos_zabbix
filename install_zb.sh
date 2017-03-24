#!/bin/bash
#-------------------------------------------------------
# author:       Rogério Sardinha de Jesus <rogeriosardinha3@gmail.com>
# date:         16-mar-2017
#-------------------------------------------------------
#
# Variaveis de ambiente

PHPINI="/etc/php5/apache2/php.ini"
ZBX_VER="3.0.8";

#"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'
# VARIAVEIS QUE DEVEM SEREM ALTERADAS, LINHAS: 20 ao 23.
# !!!ATENÇÃO!!! 
# AS ALTERAÇÕES SÃO PARA O PADRÃO DA EMPRES!
# ALTERAR SOMENTE OS CAMPOS: "SENHA", "SENHAROOT",#"NOMEBANCO" E "USUARIODB"
#MAS NENHUM CAMPO. DEPOIS DE ALTERADO, SALVAR E EXECUTAR NOVAMENTE " Script: InstalarZB.sh.
#""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#????????????????????????
SENHA="zabbix";        #?
SENHAROOT="123456";    #?
NOMEBANCO="zabbix";    #?
USUARIODB="zabbix";    #?
#????????????????????????

WWW_PATH="/var/www/html/";

# Criando e acessando o diretorio temporario de instalacao

#mkdir /install 
#cd /install

echo  "Prepara e instala ambiente java."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read

# Realizando Update
apt-get update

# Instalando biblioteca 
apt-get -y install build-essential snmp vim libssh2-1-dev libssh2-1 libopenipmi-dev libsnmp-dev wget libcurl4-gnutls-dev fping libxml2 libxml2-dev curl libcurl3-gnutls libcurl3-gnutls-dev libiksemel-dev libiksemel-utils libiksemel3 sudo

# Populando o source list do Debian
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list

# Add chave do server ubuntu.
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# Realizando 2º Update.
apt-get update

# Instalando complemento do Java
apt-get -y install oracle-java8-installer oracle-java8-set-default

echo  "Inicio da instalação do Banco de Dados Mysql no Debian"
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read

#Instalação do apache/ Php5 e Mysql.
apt-get install -y apache2 php5 php5-mysql libapache2-mod-php5 php5-gd php-net-socket libpq5 libpq-dev mysql-server mysql-client libmysqld-dev

echo "Final da instalação do Banco de Dados Mysql"
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read 
echo ".............................................."
echo ".............................................."
echo "Criando o Banco de Dados Zabbix."
echo "Aperte <ENTER> para continuar..."
read

# Configurando o banco de dados
echo "create database $NOMEBANCO character set utf8;" | mysql -uroot -p$SENHAROOT
echo "GRANT ALL PRIVILEGES ON $NOMEBANCO.* TO $USUARIODB@localhost IDENTIFIED BY '$SENHA' WITH GRANT OPTION;" | mysql -uroot -p$SENHAROOT

echo "Final de criação do BD Zabbix"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Inicializando a configurando o php.ini."
echo "Aperte <ENTER> para continuar..."
read

# Configurando o php.ini
sed -i "s/date.timezone/;date.timezone/" $PHPINI;
sed -i "s/max_execution_time/;max_execution_time/" $PHPINI;
sed -i "s/max_input_time/;max_input_time/" $PHPINI;
sed -i "s/post_max_size/;post_max_size/" $PHPINI;

echo "date.timezone =America/Sao_Paulo" >> $PHPINI;
echo "max_execution_time = 300" >> $PHPINI;
echo "max_input_time = 300" >> $PHPINI;
echo "post_max_size = 16M" >> $PHPINI;
echo "always_populate_raw_post_data=-1" >> $PHPINI

# Restando o apache2
service apache2 restart

echo "Final da configuração PHP.INI"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Inicializando a criação do usuário do Zabbix."
echo "Aperte <ENTER> para continuar..."
read

# Criando o usuario zabbix
useradd zabbix -s /bin/false

echo "Final da criação"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Baixando a Versão zabbix 3.0.8 e descompactando."
echo "Aperte <ENTER> para continuar..."
read
# Baixando a Versão zabbix 3.0.8 e descompactando

export ZBX_VER

wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/$ZBX_VER/zabbix-$ZBX_VER.tar.gz

tar xzvf zabbix-$ZBX_VER.tar.gz

chmod -R +x zabbix-$ZBX_VER

echo "Finalizado baixa e descompactação do Zabbix"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Populando a base de dados do Zabbix."
echo "Aperte <ENTER> para continuar..."
read

# Populando a base de dados
cd zabbix-$ZBX_VER
cat database/mysql/schema.sql | mysql -u $USUARIODB -p$SENHA $NOMEBANCO && cat database/mysql/images.sql | mysql -u $USUARIODB -p$SENHA $NOMEBANCO && cat database/mysql/data.sql | mysql -u $USUARIODB -p$SENHA $NOMEBANCO;

echo "Finalizado população da BD Zabbix"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Compilando Zabbix."
echo "Aperte <ENTER> para continuar..."
read

# Compilando Zabbix.
./configure --enable-server --enable-agent --enable-java --with-mysql --with-net-snmp --with-jabber=/usr --with-libcurl=/usr/bin/curl-config --with-ssh2 --with-openipmi --with-libxml2
make install

echo "Finalizado compilação do Zabbix"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Configurando o arquivo zabbix_Server.Conf."
echo "Aperte <ENTER> para continuar..."
read

# Configurando o arquivo zabbix_Server.Conf
CONF_SERVER=/usr/local/etc/zabbix_server.conf

# Backup do arquivo original do server, importante guarda-lo para referencias
mv $CONF_SERVER $CONF_SERVER.ori.$$

echo "DBHost=localhost" >> $CONF_SERVER
echo "DBUser=$USUARIODB" > $CONF_SERVER
echo "DBPassword=$SENHA" >> $CONF_SERVER
echo "DBName=$NOMEBANCO" >> $CONF_SERVER
echo "CacheSize=32M" >> $CONF_SERVER

echo "DebugLevel=3" >> $CONF_SERVER
echo "PidFile=/tmp/zabbix_server.pid" >> $CONF_SERVER
echo "LogFile=/tmp/zabbix_server.log" >> $CONF_SERVER
echo "Timeout=3" >> $CONF_SERVER
echo "ListenPort=10051" >> $CONF_SERVER
echo "LogFileSize=2" >> $CONF_SERVER
echo "StartIPMIPollers=1" >> $CONF_SERVER
echo "StartDiscoverers=5" >> $CONF_SERVER

PATH_FPING=$(which fping);
echo "FpingLocation=$PATH_FPING" >> $CONF_SERVER

echo "Finalizado configuração do arquivo zabbix_server.conf."
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo  "Configurando o arquivo zabbix_agentd.Conf."
echo "Aperte <ENTER> para continuar..."
read

CONF_AGENTE=/usr/local/etc/zabbix_agentd.conf

# Backup do arquivo original do agente, importante guarda-lo para referencias
mv $CONF_AGENTE $CONF_AGENTE.ori.$$

# Criando um arquivo de configuração do agente
echo "Server=127.0.0.1" > $CONF_AGENTE
echo "StartAgents=3" >> $CONF_AGENTE
echo "DebugLevel=3" >> $CONF_AGENTE
echo "Hostname=$(hostname)" >> $CONF_AGENTE
echo "PidFile=/tmp/zabbix_agentd.pid" >> $CONF_AGENTE
echo "LogFile=/tmp/zabbix_agentd.log" >> $CONF_AGENTE
echo "Timeout=3" >> $CONF_AGENTE
echo "EnableRemoteCommands=1" >> $CONF_AGENTE
echo "LogFileSize=2" >> $CONF_AGENTE
echo "ListenPort=10050" >> $CONF_AGENTE

echo  "Finalizado configuração do arquivo zabbix_agentd.conf."
echo  ".............................................."
echo  ".............................................."
echo  ".............................................."
echo  "Copiando os arquivos de frontend do /install/zabbix para o diretório /var/www/html/zabbix."

mkdir /var/www/html/zabbix
cp -R /install/zabbix-$ZBX_VER/frontends/php/* /var/www/html/zabbix/
chown -R www-data:www-data /var/www/html/zabbix/

echo "Finalizado copia dos arquivos."
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Restart do Apache2."
echo "Aperte <ENTER> para continuar..."
read

service apache2 restart

echo "Finalizado restart do apache2."
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Desabilitado firewall do Debian."
echo "Aperte <ENTER> para continuar..."
read

iptables -F

echo "Firewall desabilitado."
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Copiando os arquivos: Zabbix_server e Zabbix_agentd, para /etc/init.d/ ."
echo "Aperte <ENTER> para continuar..."
read	
	cd /install
	
	wget https://raw.githubusercontent.com/rogerios1004/arquivos_zabbix/master/zabbix_agentd
	wget https://raw.githubusercontent.com/rogerios1004/arquivos_zabbix/master/zabbix_server
	
    mv /install/zabbix_agentd /etc/init.d/
	mv /install/zabbix_server /etc/init.d/ 	
	 	
	

echo "Finalizado copia dos arquivos."
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Tornnado os arquivos: Zabbix_server e Zabbix_agentd, executáveis..."
echo "Aperte <ENTER> para continuar..."
read	
	
	chmod 775 /etc/init.d/zabbix_server /etc/init.d/zabbix_agentd
	
echo "Finalizado processo"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Startando os processos: Zabbix_server e Zabbix_agentd..."
echo "Aperte <ENTER> para continuar..."
read
	
	/etc/init.d/zabbix_server start
	/etc/init.d/zabbix_agentd start #Verificar porque o processo não sob...

echo "Finalizado processo"
echo ".............................................."
echo ".............................................."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "Acesse o navegador com Host do servidor zabbix: IP_SERVER/zabbix, para finalização da instalação."
echo "Aperte <ENTER> para continuar..."
read
echo ".............................................."
echo "PROCESSO FINALIZADO, PASTA DE CACHE DE INSTALAÇÃO SERÁ DELETADA!"
echo "Aperte <ENTER> para continuar..."
read




