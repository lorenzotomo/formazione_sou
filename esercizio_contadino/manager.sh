#!/bin/bash

DATA_DIR="./stato_barca"
mkdir -p $DATA_DIR
rm -f $DATA_DIR/GAMEOVER

# Funzione per avviare un processo animale/verdura
avvia_processo() {
    RIVA=$1
    NOME=$2
    PREDA=$3
    docker exec -d $RIVA /bin/bash -c "nohup ./animale.sh $NOME $PREDA > /tmp/$NOME.log 2>&1 &"
}

# Funzione per uccidere un processo animale/verdura
uccidi_processo() {
    RIVA=$1
    NOME=$2
    docker exec $RIVA pkill -f "animale.sh $NOME " 2>/dev/null
}

# Funzione per controllare se un processo è presente (conta i processi)
controlla_processo() {
    RIVA=$1
    NOME=$2
    docker exec $RIVA pgrep -f "animale.sh $NOME " > /dev/null
}

inizializza_gioco() {
    echo "--- Inizializzazione Processi ---"
    docker-compose down >/dev/null 2>&1
    docker-compose up -d --build >/dev/null 2>&1
    
    echo -n "riva_sx" > $DATA_DIR/posizione
    
    echo "Creo i processi sulla riva sinistra..."
    avvia_processo "riva_sx" "lupo" "capra"
    avvia_processo "riva_sx" "capra" "cavolo"
    avvia_processo "riva_sx" "cavolo" "nessuno"
    sleep 2
}

disegna_scena() {
    clear
    POS_BARCA=$(cat $DATA_DIR/posizione | tr -d '\n')
    
    L_SX=" "; L_DX=" "; C_SX=" "; C_DX=" "; V_SX=" "; V_DX=" "
    
    if controlla_processo "riva_sx" "lupo"; then L_SX="🐺"; fi
    if controlla_processo "riva_dx" "lupo"; then L_DX="🐺"; fi
    if controlla_processo "riva_sx" "capra"; then C_SX="🐐"; fi
    if controlla_processo "riva_dx" "capra"; then C_DX="🐐"; fi
    if controlla_processo "riva_sx" "cavolo"; then V_SX="🥬"; fi
    if controlla_processo "riva_dx" "cavolo"; then V_DX="🥬"; fi

    B_SX="       "; B_DX="       "
    if [ "$POS_BARCA" == "riva_sx" ]; then B_SX="[🚣]"; else B_DX="[🚣]"; fi

    echo "============================================="
    echo "   RIVA SX (Container)  |   RIVA DX (Container)"
    echo "============================================="
    echo "   $L_SX  $C_SX  $V_SX    $B_SX   |    $B_DX    $L_DX  $C_DX  $V_DX" 
    echo "============================================="
}

logica_spostamento() {
    ATTORE=$1
    PREDA=$2
    
    RIVA_CORRENTE=$(cat $DATA_DIR/posizione | tr -d '\n')
    ALTRA_RIVA="riva_dx"
    if [ "$RIVA_CORRENTE" == "riva_dx" ]; then ALTRA_RIVA="riva_sx"; fi

    # Se l'attore non è sulla riva corrente, errore
    if ! controlla_processo "$RIVA_CORRENTE" "$ATTORE"; then
        echo "Errore: $ATTORE non è sulla riva dove c'è la barca ($RIVA_CORRENTE)!"
        sleep 2
        return
    fi

    # 1. Tolgo l'animale/verdura dalla vecchia riva
    uccidi_processo "$RIVA_CORRENTE" "$ATTORE"
    
    # 2. IMPORTANTE: Sposto PRIMA la barca (aggiorno il file)
    # Così quando l'animale/verdura arriva, la barca risulta già lì.
    echo -n "$ALTRA_RIVA" > $DATA_DIR/posizione

    # 3. Metto l'animale/verdura sulla nuova riva
    avvia_processo "$ALTRA_RIVA" "$ATTORE" "$PREDA"
}

muovi_barca() {
    CORRENTE=$(cat $DATA_DIR/posizione | tr -d '\n')
    if [ "$CORRENTE" == "riva_sx" ]; then NUOVA="riva_dx"; else NUOVA="riva_sx"; fi
    echo -n "$NUOVA" > $DATA_DIR/posizione
}

# Funzione principale
inizializza_gioco

while true; do
    disegna_scena
    
    if [ -f "$DATA_DIR/GAMEOVER" ]; then
        echo "☠️  GAME OVER ☠️"
        cat "$DATA_DIR/GAMEOVER"
        echo "Premi INVIO..."
        read
        docker-compose down
        exit
    fi
    
    # Controllo Vittoria
    if controlla_processo "riva_dx" "lupo" && controlla_processo "riva_dx" "capra" && controlla_processo "riva_dx" "cavolo"; then
        echo "🏆 VITTORIA! Tutti i processi sono migrati!"
        docker-compose down
        exit
    fi

    echo "Chi sposti?"
    echo "1) Lupo"
    echo "2) Capra"
    echo "3) Cavolo"
    echo "4) Solo Barca"
    echo "q) Esci"
    read -p "Scelta: " scelta

    case $scelta in
        1) logica_spostamento "lupo" "capra" ;;
        2) logica_spostamento "capra" "cavolo" ;;
        3) logica_spostamento "cavolo" "nessuno" ;;
        4) muovi_barca ;;
        q) docker-compose down; exit ;;
    esac
done
