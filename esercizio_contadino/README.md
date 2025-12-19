# Esercitazione Contadino

Questa esercitazione consiste in una simulazione dell'indovinello lupo-capra-cavolo realizzata utilizzando Docker e Bash Scripting.
Le due rive del fiume sono rappresentate da due container Docker ed i personaggi (lupo, capra, cavolo) sono processi in background che vivono all'interno di questi container.
L'obiettivo è spostare tutti i personaggi dalla riva sinistra (riva_sx) alla rive destra (riva_dx) senza lasciare una preda con il suo predatore in assenza del contadino (la barca).

## Architettura

Il sistema è composto da:

1. Due Container (riva_sx, riva_dx): Alpine Linux isolati.
2. Manager (manager.sh): Lo script principale che funge da motore del gioco. Orchestra gli spostamenti e gestisce l'input utente.
3. Processi animali/verdura (animale.sh): Script in esecuzione all'interno dei container che monitorano costantemente l'ambiente.
4. Volume Condiviso (/dati_barca): Un volume Docker condiviso utilizzato per mantenere lo stato della barca e comunicare il game over.
5. Rete (fiume_net): Una rete bridge per permettere la comunicazione tra i container.

## Struttura dei file

- manager.sh: Il controller principale (Host) che gestisce l'input e coordina i container.
- animale.sh: La logica dei singoli personaggi e gira dentro i container.
- entrypoint.sh: Mantiene il container attivo (tail -f) e ascolta per messaggi di game over via rete.
- docker-compose.yml: Definisce l'infrastruttura (servizi, rete e volume).
- Dockerfile: Crea l'immagine base che ci servirà per l'esercizio (Alpine + Bash + Procps + Netcat).

## Avvio

1. Prima di tutto bisogna avere Docker e Docker Compose installati.

2. Ho dato i permessi di esecuzione allo script manager:

```bash
chmod +x manager.sh
```
3. E ho avviato il gioco lanciando lo script:

```bash
./manager.sh
```
