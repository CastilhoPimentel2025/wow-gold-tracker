#!/bin/bash

ADDON_NAME="GoldTracker"
VERSION=$(grep "## Version" addon/GoldTracker.toc | awk '{print $3}')

mkdir -p dist

zip -r "dist/${ADDON_NAME}-${VERSION}.zip" addon/