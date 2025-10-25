#!/usr/bin/env bash

CONTAINER_NAME="echo"
IMAGE="ealen/echo-server"
SLEEP_TIME=60

CURRENT_NODE="nodo1"

echo "Avvio del ciclo di migrazione del container..."
while true; do
  echo "Avvio del container su $CURRENT_NODE..."

  vagrant ssh -c "docker rm -f $CONTAINER_NAME 2>/dev/null || true && \
  docker run -d --name $CONTAINER_NAME -p 8080:80 $IMAGE" $CURRENT_NODE

  echo "Il container PingPong è ora in esecuzione su $CURRENT_NODE."
  echo "Attesa di $SLEEP_TIME secondi..."
  sleep $SLEEP_TIME

  echo "Arresto del container su $CURRENT_NODE..."
  vagrant ssh -c "docker rm -f $CONTAINER_NAME 2>/dev/null || true" $CURRENT_NODE

  if [ "$CURRENT_NODE" == "nodo1" ]; then
    CURRENT_NODE="nodo2"
  else
    CURRENT_NODE="nodo1"
  fi

  echo "Passaggio al nodo $CURRENT_NODE..."
done
