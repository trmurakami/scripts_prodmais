#!/bin/bash

# Verifica se um arquivo foi passado como parâmetro
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 [caminho_para_arquivo_tsv]"
    exit 1
fi

ARQUIVO_TSV=$1

# Verifica se o arquivo existe
if [ ! -f "$ARQUIVO_TSV" ]; then
    echo "Erro: Arquivo '$ARQUIVO_TSV' não encontrado."
    exit 1
fi

# Lê o arquivo TSV linha por linha
while IFS=$'\t' read -r COD_LATTES_16 TIPVIN GENERO PPG_NOME INSTITUICAO
do
    # Envia o XML por POST para a API
    response=$(curl -s -X POST -k -H "Content-Type: multipart/form-data" -F "file=@/var/www/html/prodmais/data/$COD_LATTES_16.xml" \
        -F "ppg_nome=$PPG_NOME" \
        -F "instituicao=$INSTITUICAO" \
        -F "genero=$GENERO" \
        -F "tipvin=$TIPVIN" \
        "http://143.54.211.5/ppgcis/import_lattes_to_elastic_dedup.php?lattesID=$COD_LATTES_16")

    echo "Resposta da API para o ID_LATTES $COD_LATTES_16: $response"

done < "$ARQUIVO_TSV"

