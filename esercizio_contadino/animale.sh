#!/bin/bash

IO_SONO=$1
PREDA=$2

# Appena sbarcato, aspetto un attimo che il contadino (barca) si sistemi
# Questo per evitare che qualcuno mangi prima che il file della barca venga aggiornato
sleep 2

echo "--- PROCESSO AVVIATO: $IO_SONO (Preda: $PREDA) ---"

while true; do
    # 1. Controllo barca
    DOVE_SONO=$(hostname)
    POSIZIONE_BARCA=$(cat /dati_barca/posizione 2>/dev/null | tr -d '\n' || echo "boh")

    # 2. Controllo preda
    if pgrep -f "animale.sh $PREDA " > /dev/null; then
        PREDA_PRESENTE=true
    else
        PREDA_PRESENTE=false
    fi

    # 3. Logica di caccia
    # Mangio SOLO se: la preda è qui E la barca NON è qui
    if [ "$PREDA_PRESENTE" = true ] && [ "$POSIZIONE_BARCA" != "$DOVE_SONO" ]; then
        
        MSG="Il $IO_SONO ha mangiato la $PREDA su $DOVE_SONO!"
        echo "GNAM! $MSG"
        
        # Invio messaggio rete
        echo "$MSG" | nc -w 1 riva_sx 5000 2>/dev/null
        echo "$MSG" | nc -w 1 riva_dx 5000 2>/dev/null

        pkill -f "animale.sh $PREDA "
        exit 1
    fi

    sleep 1
done
