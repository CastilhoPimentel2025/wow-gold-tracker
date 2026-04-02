#!/bin/bash

ADDON_NAME="GoldTracker"
VERSION=$(grep "## Version" addon/GoldTracker.toc | awk '{print $3}')

mkdir -p dist

# Copia o conteúdo de addon/ para uma pasta com o nome correto
cp -r addon/ "dist/${ADDON_NAME}"

# Empacota com a estrutura correta
cd dist
zip -r "${ADDON_NAME}-${VERSION}.zip" "${ADDON_NAME}/"

# Limpa a pasta temporária
rm -rf "${ADDON_NAME}"