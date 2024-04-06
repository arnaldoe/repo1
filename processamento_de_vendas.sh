#!/bin/bash

# Criação de diretório vendas e cópia do arquivo dados_de_vendas.csv
cd ./ecommerce
mkdir -p vendas
cp dados_de_vendas.csv vendas/

# Criação de subdiretório backup e cópia do arquivo com data no nome
mkdir vendas/backup
cp vendas/dados_de_vendas.csv vendas/backup/dados-$(date +%Y%m%d).csv

# Renomeação do arquivo dentro do diretório backup
mv vendas/backup/dados-$(date +%Y%m%d).csv vendas/backup/backup-dados-$(date +%Y%m%d).csv

total_unique_items=$(grep '^[0-9]' vendas/dados_de_vendas.csv | cut -d',' -f2 | sort | uniq | wc -l)
# Criação do arquivo relatorio.txt
echo "Data do sistema operacional: $(date '+%Y/%m/%d %H:%M')" > vendas/backup/relatorio.txt
echo "Data do primeiro registro de venda: $(head -n 2 vendas/dados_de_vendas.csv | tail -n 1 | cut -d',' -f5)" >> vendas/backup/relatorio.txt
echo "Data do último registro de venda: $(tail -n 1 vendas/dados_de_vendas.csv | cut -d',' -f5)" >> vendas/backup/relatorio.txt
total_unique_items=$(grep '^[0-9]' vendas/dados_de_vendas.csv | cut -d',' -f2 | sort | uniq | wc -l)
echo "Quantidade total de itens diferentes vendidos: $total_unique_items" >> vendas/backup/relatorio.txt
echo "Primeiras 10 linhas do arquivo backup-dados-$(date +%Y%m%d).csv:" >> vendas/backup/relatorio.txt
head vendas/backup/backup-dados-$(date +%Y%m%d).csv >> vendas/backup/relatorio.txt

# Comprimir arquivo para redução de espaço em disco
cd ./vendas
cd ./backup
zip dados-$(date +%Y%m%d).zip backup-dados-$(date +%Y%m%d).csv
cd ..
cd ..

# Remoção dos arquivos originais
rm vendas/backup/backup-dados-$(date +%Y%m%d).csv
rm vendas/dados_de_vendas.csv