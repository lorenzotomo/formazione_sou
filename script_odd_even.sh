#!/bin/bash

# Controlla se è stato passato un argomento
if [ $# -ne 1 ]
then
  echo "Error: Devi inserire un numero!"
  exit 1
fi

# Prende il numero dall'argomento
N=$1

# Controlla che l'argomento sia un numero
if ! [ "$N" -eq "$N" ] 2>/dev/null
then
  echo "Error: l'argomento deve essere un numero!"
  exit 1
fi

# Ciclo da 1 a N
for (( i=1; i<=N; i++ ))
do
  resto=$(( i % 2 ))

  if [ $resto -eq 0 ]
  then
    echo "$i è pari"
  else
    echo "$i è dispari"
  fi
done
