#!/bin/bash

# Função para verificar se uma linha segue o padrão do cabeçalho
function verificar_padrao_cabecalho() {
    local linha=$1
    local padrao="^id,produto,quantidade,preço,data$"
    if [[ $linha =~ $padrao ]]; then
        return 0  # Padrão válido
    else
        return 1  # Padrão inválido
    fi
}

# Ler o arquivo linha por linha
while IFS= read -r linha; do
    # Ignorar cabeçalhos e linhas vazias
    if [[ $linha == id* ]] || [[ -z $linha ]]; then
        continue
    fi

    # Verificar se a linha tem o mesmo número de colunas que o cabeçalho
    num_colunas_cabecalho=5
    num_colunas=$(echo "$linha" | awk -F ',' '{print NF}')
    if [[ $num_colunas -ne $num_colunas_cabecalho ]]; then
        # Extrair o ID da linha com anomalia
        id_anomalia=$(echo "$linha" | cut -d',' -f1)
        echo "Anomalia: ID $id_anomalia - A linha possui um número diferente de colunas do que o cabeçalho."
    fi
done < dados_de_vendas.csv

#=======================================================

# Função para verificar se uma linha segue o padrão do cabeçalho
function verificar_padrao_cabecalho() {
    local linha=$1
    local padrao="^id,produto,quantidade,preço,data$"
    if [[ $linha =~ $padrao ]]; then
        return 0  # Padrão válido
    else
        return 1  # Padrão inválido
    fi
}

# Função para verificar se uma data está em um formato válido
function verificar_formato_data() {
    local data=$1
    local formato="^[0-9]{2}/[0-9]{2}/[0-9]{4}$"
    if [[ $data =~ $formato ]]; then
        return 0  # Formato válido
    else
        return 1  # Formato inválido
    fi
}

# Função para comparar duas datas
function comparar_datas() {
    local data1=$1
    local data2=$2

    # Remover qualquer zero à esquerda
    data1=$(echo "$data1" | sed 's/^0*//')
    data2=$(echo "$data2" | sed 's/^0*//')

    local ano1=$(echo "$data1" | cut -d'/' -f3)
    local mes1=$(echo "$data1" | cut -d'/' -f2)
    local dia1=$(echo "$data1" | cut -d'/' -f1)

    local ano2=$(echo "$data2" | cut -d'/' -f3)
    local mes2=$(echo "$data2" | cut -d'/' -f2)
    local dia2=$(echo "$data2" | cut -d'/' -f1)

    # Comparar os anos
    if [[ $ano1 -gt $ano2 ]]; then
        return 0
    elif [[ $ano1 -lt $ano2 ]]; then
        return 1
    fi

    # Comparar os meses
    if [[ $mes1 -gt $mes2 ]]; then
        return 0
    elif [[ $mes1 -lt $mes2 ]]; then
        return 1
    fi

    # Comparar os dias
    if [[ $dia1 -gt $dia2 ]]; then
        return 0
    else
        return 1
    fi
}

# Cria o diretório vendas e copia o arquivo "dados_de_vendas.csv" para dentro dele
mkdir -p vendas
cp dados_de_vendas.csv vendas/

# Converter o formato da data e verificar se é válido
data_anterior=""
while IFS= read -r linha; do
    # Ignorar cabeçalhos e linhas vazias
    if [[ $linha == id* ]] || [[ -z $linha ]]; then
        continue
    fi

    # Extrair a data da linha atual
    data_atual=$(echo "$linha" | awk -F ',' '{print $NF}')

    # Verificar se a data segue o formato esperado
    if ! verificar_formato_data "$data_atual"; then
        echo "Anomalia: ID $(echo "$linha" | cut -d',' -f1) - A data '$data_atual' não segue o formato esperado."
    fi

    # Verificar se a data atual é mais recente que a anterior
    if [[ ! -z $data_anterior ]]; then
        if ! comparar_datas "$data_atual" "$data_anterior"; then
            echo "Anomalia: ID $(echo "$linha" | cut -d',' -f1) - A data '$data_atual' não é mais recente do que a data anterior."
        fi
    fi

    # Atualizar a data anterior para a data atual
    data_anterior=$data_atual
done < vendas/dados_de_vendas.csv




#=======================================================

# Cria o diretório vendas e copia o arquivo "dados_de_vendas.csv" para dentro dele
# mkdir -p vendas
# cp dados_de_vendas.csv vendas/

# Obtém a data atual no formato YYYYMMDD
data=$(date +%Y%m%d)

# Cria o subdiretório backup e faz uma cópia do arquivo "dados_de_vendas.csv" com a data de execução como parte do nome do arquivo
mkdir vendas/backup
cp dados_de_vendas.csv vendas/backup/dados-$data.csv

# Renomeia o arquivo no diretório backup para seguir o padrão especificado
mv vendas/backup/dados-$data.csv vendas/backup/backup-dados-$data.csv

#========================================================
# Obtém informações sobre o arquivo "dados_de_vendas.csv"
sed -i '57s/\,/./4' dados_de_vendas.csv
sed -i '68s/31\/01\/2023/31\/03\/2023/' dados_de_vendas.csv

#first_sale_date=$(grep '^[0-9]' dados_de_vendas.csv | awk -F ',' 'BEGIN {OFS=","} {if (NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($NF, d, "/"); print d[3] d[2] d[1],$0} else if (NF == 6 && $(NF-1) ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($(NF-1), d, "/"); print d[3] d[2] d[1],$0}}' | head -n 1 | cut -d',' -f6)
#last_sale_date=$(grep '^[0-9]' dados_de_vendas.csv | awk -F ',' 'BEGIN {OFS=","} {if (NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($NF, d, "/"); print d[3] d[2] d[1],$0} else if (NF == 6 && $(NF-1) ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($(NF-1), d, "/"); print d[3] d[2] d[1],$0}}' | tail -n 1 | cut -d',' -f6)

first_sale_date=$(awk -F ',' '$1 ~ /^[0-9]+$/ && NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/ {print $NF}' dados_de_vendas.csv | sort | head -n 1)
last_sale_date=$(awk -F ',' '$1 ~ /^[0-9]+$/ && NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/ {print $NF}' dados_de_vendas.csv | sort | tail -n 1)


total_unique_items=$(grep '^[0-9]' vendas/dados_de_vendas.csv | cut -d',' -f2 | sort | uniq | wc -l)

# Cria o arquivo "relatorio.txt" com as informações solicitadas
echo "Data do sistema operacional: $(date +%Y/%m/%d\ %H:%M)" > vendas/backup/relatorio.txt
echo "Data do primeiro registro de venda: $first_sale_date" >> vendas/backup/relatorio.txt
echo "Data do último registro de venda: $last_sale_date" >> vendas/backup/relatorio.txt
echo "Quantidade total de itens diferentes vendidos: $total_unique_items" >> vendas/backup/relatorio.txt

# Mostra as primeiras 10 linhas do arquivo "backup-dados-<yyyymmdd>.csv" e as inclui no arquivo "relatorio.txt"
head -n 10 vendas/backup/backup-dados-$data.csv >> vendas/backup/relatorio.txt

# Comprime o arquivo "backup-dados-<yyyymmdd>.csv" para "dados-<yyyymmdd>.zip"
zip -r vendas/backup/dados-$data.zip vendas/backup/backup-dados-$data.csv

# Remove os arquivos desnecessários
rm vendas/backup/backup-dados-$data.csv
rm vendas/dados_de_vendas.csv