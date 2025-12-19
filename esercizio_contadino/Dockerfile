FROM alpine:latest

# Installiamo bash, netcat e procps (pgrep, pkill)
RUN apk add --no-cache bash netcat-openbsd procps

WORKDIR /app

# Copiamo lo script che rappresenta l'animale
COPY animale.sh .
RUN chmod +x animale.sh

# Copiamo un entrypoint che tiene vivo il container
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
