#!/bin/bash
##export SHOW_DEBUG=1    ## Comment this line to remove @DEBUG statements

###############################################################################
## ISCTE-IUL: Trabalho prático de Sistemas Operativos 2022/2023
##
## Aluno: Nº:110906     Nome:Alexandre Miguel Sargento Carvoeiro 
## Nome do Módulo: refill.sh
## Descrição/Explicação do Módulo: 
## Esta nos comentarios.
##
###############################################################################

#VERIFICA SE O FICHEIRO produtos.txt EXISTE
if [ ! -f "produtos.txt" ]; then
  ./error 3.1.1
  exit
fi

#VERIFICA SE O FICHEIRO reposicao.txt EXISTE
 if [ ! -f "reposicao.txt" ]; then
   ./error 3.1.1
     exit
 fi
 ./success 3.1.1

 # VERIFICA O FICHEIRO reposicao.txt PARA VER SE EXISTEM E TEM O FORMATO CERTO
while read linha; do
  produto=$(echo "$linha" | cut -d ':' -f 1)
  Nr_itens_a_adicionar=$(echo "$linha" | cut -d ':' -f 3)
  # VERIFICA SE O NUMERO DE ITENS A ADICIONAR É UM NUMERO INTEIRO POSITVO OU ZERO
  if ! [[ "$Nr_itens_a_adicionar" =~ ^[0-9]+$ ]]; then
    ./error 3.1.2 "$produto"
    exit
  fi
  
  # VERIFICA SE O PRODUTO EXISTE NO produtos.txt
  if ! grep -q "^$produto:" produtos.txt; then
    ./error 3.1.2 "$produto"
    exit
  fi
done < reposicao.txt
./success 3.1.2

data_atual=$(date +%Y-%m-%d)
ficheiro="produtos-em-falta.txt"

if ! test -e "produtos.txt"; then
  echo "Arquivo 'produtos.txt' não encontrado"
  exit 
fi

echo "**** Produtos em falta em $data_atual ****" >> $ficheiro

while IFS= read -r linha; do
  produto=$(echo "$linha" | cut -d ':' -f 1)
  stock_atual=$(echo "$linha" | cut -d ':' -f 4)
  stock_max=$(echo "$linha" | cut -d ':' -f 5)

  if (( stock_atual < stock_max )); then
    produtos_em_falta=$(( stock_max - stock_atual ))
    echo "$produto: $produtos_em_falta unidades" >> $ficheiro
  fi
done < "produtos.txt"

if [ -s $ficheiro ]; then
  ./success 3.2.1
else
  ./error 3.2.1
  exit
fi

# ATUALIZA O FICHEIRO produtos.txt
while IFS= read -r linha; do
  produto=$(echo "$linha" | cut -d ':' -f 1)
  categoria=$(echo "$linha" | cut -d ':' -f 2)
  preco=$(echo "$linha" | cut -d ':' -f 3)
  stock_atual=$(echo "$linha" | cut -d ':' -f 4)
  stock_max=$(echo "$linha" | cut -d ':' -f 5)

  reposicao=$(grep "^$produto:" reposicao.txt | cut -d ':' -f 3)

  # CONFIRMA SE O PRODUTO TEM REPOSICAO DEFINIDA EM reposicao.txt
  if [ -z "$reposicao" ]; then
    # ST NAO TIVER
    novo_stock="$stock_atual"
  else
    # SE TIVER
    novo_stock=$(( stock_atual + reposicao ))
    # VERIFICA SE O NOVO EXCEDE O MAX
    if (( novo_stock > stock_max )); then
      novo_stock="$stock_max"
    fi
  fi

# ATUALIZA A LINHA NO FICHEIRO produtos.txt COM A DEVIDA NOVA LINHA
  sed -i "s/^$produto:$categoria:$preco:$stock_atual:$stock_max/$produto:$categoria:$preco:$novo_stock:$stock_max/" "produtos.txt"

  done < "produtos.txt"

if [ $? -eq 0 ]; then
  ./success 3.2.2
else
  ./error 3.2.2
  exit
fi