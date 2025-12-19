FROM alpine:latest
RUN apk add --no-cache bash netcat-openbsd procps
WORKDIR /app
COPY animale.sh .
RUN chmod +x animale.sh
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]
