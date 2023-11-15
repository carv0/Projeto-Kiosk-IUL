#!/bin/bash
##export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº: 110906      Nome: Alexandre Miguel Sargento Carvoeiro
## Nome do Módulo: stats.sh
## Descrição/Explicação do Módulo: 
## Esta nos comentarios.
##
###############################################################################



# 4.1. Validações
if [[ $# -ne 1 ]]; then
	./error 4.1.1
	exit
else
	./success 4.1.1
fi

if [[ $1 != "listar" && $1 != "popular" && $1 != "histograma" ]]; then
  	./error 4.1.1
  	exit 
else
	./success 4.1.1
fi

# 4.2. Invocação do script
#VALIDA SE O FICHEIRO compras.txt EXISTE
if [[ -f "relatorio_compras.txt" ]]; then
	./error 4.2.1
	exit
else
	./success 4.2.1
fi

if [ $1 == "listar" ]; then
	
  	awk -F ";" '{arr[$1]++}END{for(i in arr) print i": "arr[i]" compra(s)"}' relatorio_compras.txt | sort -k2 -rn > stats.txt
  	if [ $? -eq 0 ]; then
    	./success 4.2.1
    	exit 
  	else
    	./error 4.2.1
    	exit 
  	fi
fi

if [ $1 == "popular" ]; then
	if [ $# -ne 2 ]; then
		./error 4.2.2
		exit
	fi

  	if ! [[ "$2" =~ ^[0-9]+$ ]]; then
    	./error 4.2.2
    	exit 
  	fi

  	awk -F ";" '{arr[$2]+=$3}END{for(i in arr) print i";"arr[i]}' relatorio_compras.txt | sort -t ";" -k2 -rn | head -n $2 | awk -F ";" '{print $1": "$2" compra(s)"}' > stats.txt

  	if [ $? -eq 0 ]; then
    	./success 4.2.2
    	exit 
  	else
    	./error 4.2.2
    	exit 
  	fi
fi

if [ $1 == "histograma" ]; then
  	awk -F ";" '{arr[$1]++}END{for(i in arr){printf("%s", i);for(j=0;j<arr[i];j++) printf("*"); printf("\n")}}' relatorio_compras.txt > stats.txt
  	if [ $? -eq 0 ]; then
    	./success 4.2.3
    	exit 
  	else
    	./error 4.2.3
    	exit 
  	fi
fi

