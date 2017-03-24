#!/bin/bash
#Autor: Rogério Sardinha de Jesus
#E-mail: rogeriosardinha3@gmail.com
#
mkdir /install
cd /install
wget https://raw.githubusercontent.com/rogerios1004/arquivos_zabbix/master/install_zb.sh 

chmod 777 install_zb.sh

	echo -n "ALTEROU OS DADOS DO BANCO DE DADOS?  (N)Não! Desejo Alterar. (S)Sim! Continuar instalação. (E) Vou sair somente! "

 read resposta 
 case "$resposta" in
 	n|N|"")
 		echo "Alterar dados =)"
	nano /install/install_zb.sh
	bash /install/install_zb.sh
exit
 ;;
	 s|S)       
 		echo "Continuando instalação."
	bash /install/install_zb.sh
exit
 ;;
 e|E)
 	echo "Exit..."
	cd /
	rm -R /install
exit
;;

 esac  
