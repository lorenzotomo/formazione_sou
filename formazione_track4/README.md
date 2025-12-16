# TRACK 4

Questa repo contiene tutti i file utilizzati per svolgere la track 4 del nostro percorso formativo.
L'obiettivo è stato simulare scenari reali come il deploy di applicazioni, monitoring tramite Prometheus Stack, gestione di dati sensibili, certificati, resource quotas e l'implementazione del supporto Kafka.
Tutto questo è stato realizzato su Minikube.

## 1. Deployment Openshift

Nel primo punto ho semplicemente creato un deployment Nginx ed il file YAML si chiama nginx-deploy.yaml

## 2. Gestione CSR per richiesta nuovo certificato

In questo passaggio ho creato la mia Certification Authority (CA) a cui ho inviato successivamente la mia CSR.
Per realizzare questi passaggi ho utilizzato OpenSSL.

Ho creato prima di tutto la root CA:

1. Ho generato la chiave privata della CA:

openssl genrsa -out rootCA.key 4096

Dico ad openssl di generare una chiave usando l'algoritmo RSA e mi salva quest'ultima nel file rootCA.key. Fondamentale per firmare i certificati.

2. Genero il certificato root self-signed:

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt

-x509: mi crea direttamente un certificato senza fare la richiesta, si usa per i certificati self-signed.
Tale certificato sarà rootCA.crt.

Dopodiché genero la richiesta del server (CSR):

3. Ho generato la chiave privata del server:

openssl genrsa -out server.key 2048

Simile al punto 1 ma per il server. Cambia solo che ho utilizzato 2048 bit invece di 4096 perchè sarà una chiave utilizzata per ogni connessione HTTPS. 2048 è più "leggera" per la CPU del server.

4. Ho creato la richiesta di firma (CSR)

openssl req -new -key server.key -out server.csr

Allega la chiave pubblica server.key alla richiesta server.csr.

5. Ora ho potuto firmare il certificato:

openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256

Prende il modulo di richiesta server.csr ed usa rootCA.crt come prova dell'autorità e rootCA.key per mettere la firma sul nuovo certificato server.crt.
Quest'ultimo è il certificato valido per Nginx.

## 3. Gestione Resource Quotas

Ho utilizzato il file YAML quota.yaml e l'ho applicato.
Per verificare l'effettivo funzionamento di tali quotas ho scalato le repliche a 6 tramite questo comando:

kubectl scale deployment nginx-deployment --replicas=6

Ovviamente le resource quotas proteggono il cluster e le repliche rimanevano a 5.

## 4. Gestione Prometheus Stack

In questa fase lo scopo era implementare uno stack di monitoraggio completo e configurare controlli attivi (Probe) sul servizio.

Ho installato Prometheus Stack (Prometheus + Grafana + AlertManager + NodeExporter) tramite helm in un namespace dedicato chiamato monitoring.

Prima di passare al Blackbox, ho esposto Grafana tramite port-forwarding sulla porta 3000. Ho visionato i grafici di consumo della mia app Nginx senza aver dovuto configurare nulla. 

Dopodichè ho installato il Blackbox exporter sempre tramite helm ed ho configurato il monitoraggio creando un oggetto Kubernetes chiamato Probe (nginx-probe.yaml).
Quest'ultimo dice a Prometheus di utilizzare il Blackbox exporter per controllare ogni 15 secondi il servizio nginx-service.
Per la creazione del mio service ho utilizzato un approccio imperativo (perdonatemi) lanciando tale comando:

kubectl expose deployment nginx-deployment --name=nginx-service --port=80 --target-port=80 --type=ClusterIP

In questa fase ho avuto ho avuto non pochi problemi riguardanti la pesantezza dell'intero stack. Ho stressato il cluster talmente tanto che avevo reso l'API server lentissimo.

## 5. Gestione Secret

Qui ne ho generati due tipi: uno generic (Opaque) per username e password di un db fittizio, ed uno TLS per i certificati HTTPS che ho generato prima.
Dopodichè, ho creato un pod dal file secret-test-pod.yaml che usasse contemporaneamente entrambi i secret per testarli.
Per fare questo ho lanciato due comandi di verifica:

kubectl exec secret-test-pod -- env | grep DB_

kubectl exec secret-test-pod -- ls -l /etc/ssl/certs/my-app

## 6. Supporto Kafka

Ho creato un cluster Kafka moderno e ho verificato la comunucazione tra Producer e Consumer.
Ho utilizzato l'operatore Strimzi per gestire Kafka su Minikube (installato tramite helm).
Non ho utilizzato Zookeeper ma KRaft.
Ho dovuto installare la versione 4.0.0 di Kafka perchè la versione di Strimzi era molto recente ed è stato rimosso il supporto per le versioni di Kafka precedenti. 
Tutti i file di configurazione e gli script in python li trovate nella cartella sup_kafka. 

Per verificare il corretto funzionamento ho, prima di tutto, verificato che i messaggi scorressero e che le app comunicassero col broker:

kubectl logs producer-app -n monitoring --tail=10

kubectl logs consumer-app -n monitoring --tail=10

Dopodichè ho simulato un ritardo (LAG) fermando il consumer (kubectl delete pod consumer-app).
Il producer, mentre il consumer è fermo, continua ad inviare messaggi creando "l'ingorgo".
Ho atteso 30 secondi e ho misurato il LAG tramite il seguente comando:

kubectl exec -it my-cluster-dual-role-0 -n monitoring -- bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --describe --group my-consumer-group

Nella colonna LAG il numero era 35 e aumentava più passava il tempo.
Riavviato il Consumer (kubectl apply -f consumer-pod.yaml), quel numero è tornato a 0.