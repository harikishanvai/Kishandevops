#!/bin/bash

if [ ! -e components/$1.sh ]; then
  echo "component doesnot exit"
  exit
fi
bash components/$1.sh