#!/bin/bash
##export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:110906      Nome:Alexandre Miguel Sargento Carvoeiro 
## Nome do Módulo: menu.sh
## Descrição/Explicação do Módulo: 
## Esta nos comentarios.
##
###############################################################################

#5.1 APRESENTAÇAO
#MOSTRA O MENU
while true; do
	clear
	echo "MENU:"
	echo "1: Regista/Atualiza saldo utilizador"
	echo "2: Compra produto"
	echo "3: Reposição de stock"
	echo "4: Estatísticas"
	echo "0: Sair"
	read -p "Opção: " opcao

	if ! [[ "$opcao" =~ ^[0-4]$ ]]; then
		./error 5.2.1  $opcao
	else	
		./success 5.2.1
	fi

	case "$opcao" in
		0)
			exit
		;;
		1)
		echo "Regista utilizador / Atualiza saldo utilizador:"
		echo -n "Indique o nome do utilizador: "
		read nome
		echo -n "Indique a senha do utilizador: "
		read senha
		echo -n "Para registar o utilizador, insira o NIF do utilizador: "
		read n_contribuinte
		echo -n "Indique o saldo a adicionar ao utilizador: "
		read saldo

		./regista_utilizador.sh "$nome" "$senha" "$saldo" "$n_contribuinte" 
		./success 5.2.2.1
		;;
		2)
		./compra.sh
		./success 5.2.2.2
		;;
		3)
		./refill.sh
		./success 5.2.2.3
		;;
		4)
		#STATS
		while true; do
			#MOSTRA O SUBMENU
				echo "Estatística:"
				echo "1: Listar utilizadores que já fizeram compras"
				echo "2: Listar os produtos mais vendidos"
				echo "3: Histograma de vendas"
				echo "0: Voltar ao menu principal"
				read -p "Opção: " subopcao
				
				#VALIDA A SUB OPCAO INTRODUZIDA
				if ! [[ "$subopcao" =~ ^[0-3]$ ]]; then
					./error 5.2.2.4
				else
					./success 5.2.2.4
				fi

				if [[ "$subopcao" == "0" ]]; then
				#SAI DO SUBMENU
				break
				elif [[ "$subopcao" == "1" ]]; then
					./stats.sh "listar"
					./success 5.2.2.4
				elif [[ "$subopcao" == "2" ]]; then
					./stats.sh "popular"
					./success 5.2.2.4
				elif [[ "$subopcao" == "3" ]]; then
					./stats.sh "histograma"
					./success 5.2.2.4
				fi
					
			done
			;;
		esac
		./success "$opcao"
done





