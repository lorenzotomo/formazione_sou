# Progetto Vagrant "Ping-Pong" con Docker

Questo progetto crea due VM Linux (nodo1 e nodo2) con Docker installato.  
Un container (`ealen/echo-server`) viene fatto "migrare" ogni 60 secondi da un nodo all'altro.

Avvia le VM:
```bash
vagrant up
