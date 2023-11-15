#!/bin/bash
##export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:110906      Nome:Alexandre Miguel Sargento Carvoeiro 
## Nome do Módulo: compra.sh
## Descrição/Explicação do Módulo: 
##Está nos comentarios.
##
###############################################################################

#2.1. VALIDAÇÕES E PEDIDO DE INFORMAÇÕES INTERATIVO
# VERIFICA SE OS ARQUIVOS PRODUTOS.TXT E UTILIZADORES.TXT EXISTEM
if [ ! -f produtos.txt ] || [ ! -f utilizadores.txt ]; then
  	./error 2.1.1
  	exit 
fi

# LISTA OS PRODUTOS DISPONÍVEIS
echo "Produtos disponíveis:"
contador=0
while IFS=: read -r produto categoria preco stock stock_maximo; do
  if [ $stock -gt 0 ]; then
    contador=$((contador+1))
    echo "$contador: $produto: $preco EUR"
  fi
done < produtos.txt
echo "0: Sair"

# PEDE AO USUÁRIO QUE SELECIONE UM PRODUTO
read -p "Insira a sua opção: " opcao
if [ $opcao -eq 0 ]; then
  	./success 2.1.2
  	exit 
fi

# VERIFICA SE A OPÇÃO SELECIONADA PELO USUÁRIO É VÁLIDA
contador=0
produto_selecionado=""
while IFS=: read -r produto categoria preco stock stock_maximo; do
  	if [ $stock -gt 0 ]; then
    	contador=$((contador+1))
    	if [ $contador -eq $opcao ]; then
      		produto_selecionado=$produto
     		 break
    	fi
  	fi
done < produtos.txt

if [ -z "$produto_selecionado" ]; then
  	./error 2.1.2
  	exit
else
	./success 2.1.2 "$produto_selecionado"
fi

# PEDE AO USUÁRIO QUE INSIRA SEU ID
read -p "Insira o ID do seu utilizador: " id

# VERIFICA SE O ID DO USUÁRIO É VÁLIDO
nome_usuario=""
while IFS=: read -r id_arq nome senha; do
  if [ $id_arq -eq $id ]; then
    nome_usuario=$nome
	saldo_utilizador=$saldo
    break
  fi
done < utilizadores.txt

if [ -z "$nome_usuario" ]; then
  	./error 2.1.3
  	exit 1
else
  	./success 2.1.3 "$nome_usuario"
fi

# PEDE AO USUÁRIO QUE INSIRA SUA SENHA
read -p "Insira a senha do seu utilizador: " senha_usuario

# VERIFICA SE A SENHA DO USUÁRIO É VÁLIDA
senha_correta=""
while IFS=: read -r id_arq nome senha; do
  	if [ $id_arq -eq $id ] && [ "$senha" = "$senha_usuario" ]; then
    	senha_correta="true"
    	break
 	fi
done < utilizadores.txt

if [ -z "$senha_correta" ]; then
  	./error 2.1.4
  	exit 1
else
  	./success 2.1.4
fi

# VERIFICA O PREÇO DO PRODUTO SELECIONADO
preco_produto=$(grep -w "$produto_selecionado" produtos.txt | cut -d ':' -f 3)

# VERIFICA SE O USUÁRIO POSSUI SALDO SUFICIENTE PARA A COMPRA
if [ $saldo_utilizador -lt $preco_produto ]; then
	./error 2.2.1 $preco_produto $saldo_utilizador
	exit 
else
	./success 2.2.1
fi

# VERIFICA SE O UTILIZADOR TEM SALDO SUFICIENTE PARA COMPRAR O PRODUTO
if (( $saldo_utilizador < $preco_produto )); then
  	./error 2.2.1
  	exit
fi
# DECREMENTA O VALOR DO PREÇO DO PRODUTO DO SALDO DO UTILIZADOR
novo_saldo=$(($saldo_utilizador - $preco_produto))

# ATUALIZA O FICHEIRO UTILIZADORES.TXT
sed -i "s/^$id:.*/$id:$nome:$senha:$novo_saldo/" utilizadores.txt
./success 2.2.2

# DECREMENTA UMA UNIDADE AO STOCK DO PRODUTO RESPETIVO
produto_encontrado=""
while IFS=: read -r id_produto nome_produto categoria preco stock; do
  if [ "$nome_produto" = "$produto" ]; then
    produto_encontrado="true"
    novo_stock=$(($stock - 1))
    if [ $novo_stock -lt 0 ]; then
      ./error 2.2.3
      exit 
    fi
    sed -i "s/^$id_produto:.*/$id_produto:$nome_produto:$categoria:$preco:$novo_stock/" produtos.txt
    break
  fi
done < produtos.txt

if [ -z "$produto_encontrado" ]; then
  ./error 2.2.3
  exit 
fi
./success 2.2.3

# REGISTA A COMPRA NO FICHEIRO RELATORIO_COMPRAS.TXT
data=$(date +%Y-%m-%d)
echo "$produto:$(grep -w $produto produtos.txt | cut -d ':' -f 3):$id:$data" >> relatorio_compras.txt
./success 2.2.4

# LISTA AS COMPRAS EFETUADAS PELO UTILIZADOR
compras_utilizador=$(grep ":$id:$data$" relatorio_compras.txt | cut -d ':' -f 1)
if [ -z "$compras_utilizador" ]; then
  	./error 2.2.5
  	exit 
fi

echo "**** $data: Compras de $nome ****" > lista-compras-utilizador.txt
echo "$compras_utilizador" | while read -r compra; do
  echo "$compra, $data" >> lista-compras-utilizador.txt
done

lista_compras=""
while IFS=: read -r produto categoria preco stock; do
	if [ "$produto" = "$produto_escolhido" ]; then
		novo_stock=$((stock-1))
			if [ $novo_stock -lt 0 ]; then
				./error "$preco" "$saldo_atual"
				exit 
			fi
		sed -i "s/^$produto:$categoria:$preco:$stock$/$produto:$categoria:$preco:$novo_stock/" produtos.txt 
		novo_saldo=$(($saldo_atual-$preco))
		sed -i "s/^$id:$nome:$senha:$saldo_atual$/$id:$nome:$senha:$novo_saldo/" utilizadores.txt 
		echo "$produto,$data" >> relatorio_compras.txt  
		lista_compras+=" $produto,$data"
	fi
done < produtos.txt

echo "**** $data: Compras de $nome ****" > lista-compras-utilizador.txt
if [ -n "$lista_compras" ]; then
	echo "${lista_compras}" >> lista-compras-utilizador.txt 
else
	echo "Nenhuma compra efetuada." >> lista-compras-utilizador.txt
	./error 2.2.5
	exit
fi

./success 2.2.5