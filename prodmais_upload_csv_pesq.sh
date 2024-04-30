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
while IFS=$'\t' read -r ID_LATTES NM_PROGRAMA_IES NM_ENTIDADE_ENSINO
do
    # Faz o download do XML do Lattes e salva em um arquivo temporário
    tmpfile=$(mktemp)
    curl -s "http://pesq.ufrgs.br:81/api/proxy/$ID_LATTES" -o "$tmpfile.xml"

    # Verifica se o download foi bem-sucedido
    if [ ! -s "$tmpfile.xml" ]; then
        echo "Erro ao baixar o XML para o ID_LATTES: $ID_LATTES"
        rm "$tmpfile.xml"
        continue
    fi

    # Envia o XML por POST para a API
    response=$(curl -s -X POST -k -H "Content-Type: multipart/form-data" -F "file=@$tmpfile.xml" \
        -F "ppg_nome=$NM_PROGRAMA_IES" \
        -F "instituicao=$NM_ENTIDADE_ENSINO" \
        "https://pesq.ufrgs.br/import_lattes_to_elastic_dedup.php?lattesID=$ID_LATTES")

    echo "Resposta da API para o ID_LATTES $ID_LATTES: $response"

    # Remove o arquivo temporário
    rm "$tmpfile.xml"
done < "$ARQUIVO_TSV"

