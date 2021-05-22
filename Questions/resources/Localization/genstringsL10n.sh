#!/bin/bash

genstrings L10n.swift -o ./en.lproj

if [ $? -eq 0 ]; then
    echo "File successfully generated"
else
    echo "ERROR!"
fi
