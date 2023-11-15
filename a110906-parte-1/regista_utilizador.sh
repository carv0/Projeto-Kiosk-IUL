#!/bin/bash

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:a110906       Nome:Alexandre Miguel Sargento Carvoeiro
## Nome do Módulo: regista_utilizador.sh
## Descrição/Explicação do Módulo:
## Está nos comentarios.
##
###############################################################################



#1.1 VALIDAR OS ARGUMENTOS PASSADOS E OS SEUS FORMADOS TERMINANDO NO CASO DE ERRO
#VALIDA O NUMERO DE ARGUMENTOS, MIN3 e MAX4
if [[ $# -lt 3 || $# -gt 4 ]]; then
	./error 1.1.1
	exit
else	
	./success 1.1.1
fi

#TRADUZ OS ARGUMENTOS EM VARIAVEIS
nome="$1"
senha="$2"
saldo="$3"
nif="$4"

#VALIDA SE O CAMPO NOME CORRESPONDE A UM ALUNO DE SO
if  grep -q ":$nome,.*:" /etc/passwd; then
	./success 1.1.2
else
	./error 1.1.2
	exit
fi

#VALIDA SE O CAMPO SALDO TEM UM FORMATO DE NUMBER
if ! [[ "$saldo" =~ ^[0-9]+$ ]]; then 
	./error 1.1.3
	exit
else
	./success 1.1.3
fi

#VALIDA O CAMPO NIF no caso de ter sido passado
if [[ -n  "$nif" ]] && ! [[ "$nif" =~ ^[0-9]{9}$ ]]; then
	./error 1.1.4
	exit
else	
	./success 1.1.4	
fi

#1.2 ASSOCIA OS DADOS PASSADOS COM A BASE DE DADOS DE UTILIZADORES
#VERIFICA SE O FICHEIRO utilizadores.txt existe, se existir passa para o passo 1.2.3, se não existir da erro mas nao termina
if [[ -f utilizadores.txt ]]; then
	./success 1.2.1
	#PASSO 1.2.3
	#SE O NOME PASSADO ESTIVER NO FICHERIO utilizadores.txt DA SUCESS E PROSSEGUE PARA O 1.3 se nao DA ERRO E NAO TERMINA
	if grep -q "^${nome}:" utilizadores.txt; then
		./success 1.2.3

		# PASSO 1.3 ADICIONA CREDITOS NA CONTA DO UTILIZADOR QUE EXISTE NO FICHEIRO
		# TENDO ENCONTRADO UM "match" VALIDA SE O CAMPO SENHA PASSADO CORRESPONDE AO REGISTADO NO FICHEIRO
		linha=$(grep -n "^$nome:" utilizadores.txt | cut -d ":" -f 1)
		if [ -n "$linha" ]; then
  			id_senha=$(sed -n "${linha}p" utilizadores.txt | cut -d ":" -f 3)
  			if [ "$id_senha" == "$senha" ]; then
    			saldo_atual=$(sed -n "${linha}p" utilizadores.txt | cut -d ":" -f 4)
    			novo_saldo=$(($saldo_atual+$saldo))
    			sed -i "${linha}s/:.*$/:$novo_saldo/" utilizadores.txt 
				./success 1.3.2 $novo_saldo 
  			else
    			./error 1.3.2
    			exit
  			fi
		else
  			./error 1.3.1
  			exit
		fi

	else
		./error 1.2.3
	fi
else 
	./error 1.2.1	
fi

#CRIA O FICHEIRO utilizadores.txt
touch utilizadores.txt
if [ $? -eq 0 ]; then
	./success 1.2.2
else
	./error 1.2.2
	exit
fi

#COMO NAO EXISTE O UTILIZADOR TERA DE O REGISTAR 
#VALIDA SE O NIF FOI MESMO PASSADO SE NAO FOI DA ERRO E TERMINA SE FOI DA SUCESS
if [ -z "$nif" ]; then
	./error 1.2.4
	exit
else
	./success 1.2.4
fi

#DEFINE O CAMPO id_utilizador
if [ ! -s utilizadores.txt ]; then
	id_utilizador=1
	./error 1.2.5
else
	./success 1.2.5 $id_utilizador
fi
id_utilizador=$(( $(tail -n 1 utilizadores.txt | cut -d ":" -f 1) + 1 ))

#DEFINE O CAMPO EMAIL GERADO A PARTIR DO NOME USANDO APENAS O PRIMEIRO E ULTIMO
pri_nome=$(echo $nome | cut -d " " -f 1 | tr '[:upper:]' '[:lower:]')
ult_nome=$(echo $nome | rev | cut -d " " -f 1 | rev | tr '[:upper:]' '[:lower:]')
if [ -z "$pri_nome" ] || [ -z "$ult_nome" ]; then
	./error 1.2.6
	exit
fi	

email="$pri_nome.$ult_nome@kiosk-iul.pt"
./success 1.2.6 $email


linha="$id_utilizador:$nome:$senha:$email:$nif:$saldo"
echo "$linha" >> utilizadores.txt
if [ $? -eq 0 ]; then
	./success 1.2.7
else
	./error 1.2.7
	exit
fi

#1.4 LISTA TODOS OS UTILIZADORES REGISTADOS
#CRIA UM FICHEIRO SALDOS-ORDENADOS.txt IGUAL AO QUE ESTA NO utilizadores.txt COM OS REGISTOS ORDENADOS POR ORDEM DECRESCENTE
sort -t: -k3rn utilizadores.txt > saldos-ordenados.txt

#VERIFICA SE HA ALGUM ERRO NA CRIACAO
if [ $? -eq 0 ]; then
	./success 1.4.1
else
	./error 1.4.1
fi
