#!/bin/bash

# Cria o diretório vendas e copia o arquivo "dados_de_vendas.csv" para dentro dele
mkdir -p vendas
cp dados_de_vendas.csv vendas/

# Obtém a data atual no formato YYYYMMDD
data=$(date +%Y%m%d)

# Cria o subdiretório backup e faz uma cópia do arquivo "dados_de_vendas.csv" com a data de execução como parte do nome do arquivo
mkdir vendas/backup
cp dados_de_vendas.csv vendas/backup/dados-$data.csv

# Renomeia o arquivo no diretório backup para seguir o padrão especificado
mv vendas/backup/dados-$data.csv vendas/backup/backup-dados-$data.csv

#========================================================
# Obtém informações sobre o arquivo "dados_de_vendas.csv"
#sed -i '57s/\,/./4' dados_de_vendas.csv
#sed -i '68s/31\/01\/2023/31\/03\/2023/' dados_de_vendas.csv

first_sale_date=$(awk -F ',' '$1+0 == $1 && NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/ {print $NF; exit}' dados_de_vendas.csv)
last_sale_date=$(grep '^[0-9]' dados_de_vendas.csv | awk -F ',' 'BEGIN {OFS=","} {if (NF == 5 && $NF ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($NF, d, "/"); print d[3] d[2] d[1],$0} else if (NF == 6 && $(NF-1) ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/) {split($(NF-1), d, "/"); print d[3] d[2] d[1],$0}}' | tail -n 1 | cut -d',' -f6)

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