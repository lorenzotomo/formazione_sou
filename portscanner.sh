#!/usr/bin/env bash
# Uso: ./portscanner.sh TARGET PORT_RANGE

if [ $# -ne 2 ]; then
  echo "Devi specificare un ip target ed una porta o un range di porte (es. 1-1024)"
  exit 1
fi

TARGET=$1
RANGE=$2

if [[ "$RANGE" == *"-"* ]]; then
  START=$(echo "$RANGE" | cut -d'-' -f1)
  END=$(echo "$RANGE" | cut -d'-' -f2)
else
  START=$RANGE
  END=$RANGE
fi

if ! [[ "$START" =~ ^[0-9]+$ && "$END" =~ ^[0-9]+$ ]]; then
  echo "Il range deve contenere solo numeri (es. 1-1024)." >&2
  exit 2
fi

START=$((START))
END=$((END))

if [ "$START" -lt 1 ] || [ "$END" -gt 65535 ] || [ "$START" -gt "$END" ]; then
  echo "Usa numeri tra 1 e 65535 ed il primo numero deve essere minore del secondo." >&2
  exit 3
fi

echo "Scansione di $TARGET, porte da $START a $END..."

for ((port=START; port<=END; port++)); do
  if nc -w 1 "$TARGET" "$port" >/dev/null 2>&1; then
    echo "Porta $port: Aperta"
  else
    echo "Porta $port: Chiusa o filtrata"
  fi
done
