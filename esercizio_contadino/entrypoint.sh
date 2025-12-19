#!/bin/bash

# Prepara il file di Game Over condiviso (se serve) o i log
touch /tmp/gameover_log

echo "Riva pronta. In ascolto sulla porta 5000..."

# Avvia un loop netcat in background per ascoltare messaggi di morte dalla rete
# Se riceve un messaggio, lo stampa e crea un file di allerta
while true; do
    MSG=$(nc -l -p 5000)
    if [ ! -z "$MSG" ]; then
        echo "RICEVUTO MESSAGGIO RETE: $MSG"
        echo "$MSG" > /dati_barca/GAMEOVER
    fi
done &

# Tiene vivo il container all'infinito
tail -f /dev/null
