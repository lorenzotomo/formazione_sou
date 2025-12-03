# ESERCIZIO KUBERNETES: NFS Share su Kubernetes (Minikube)

Questo progetto documenta come ho configurato e utilizzato uno storage condiviso NFS all'interno di un cluster Kubernetes (Minikube). L'esercizio copre due modalità di montaggio:

Direct Mount: Definizione del volume direttamente nel Pod.

PV & PVC: Astrazione tramite Persistent Volume e Persistent Volume Claim.

## 1. Setup Infrastruttura: Server NFS Interno

Poiché non avevo un NAS esterno, ho simulato un server NFS all'interno del cluster.

File: nfs-server-setup.yml

Questo file crea un server NFS usando un'immagine compatibile ARM (itsthenetwork/nfs-server-alpine) e lo espone tramite un Service.

kubectl apply -f nfs-server-arm.yaml

Fondamentale: Dopo aver avviato il server, è stato necessario recuperare il ClusterIP assegnato poiché serviva per configurare i client.

kubectl get svc nfs-service

Ho copiato l'IP sotto la colonna CLUSTER-IP che nel mio caso era 10.107.98.215. 

## 2. Modalità A: Direct Volume Mount

In questo scenario, il Pod conosce direttamente l'indirizzo IP del server. È un metodo veloce ma poco flessibile.

Configurazione

Nel file pod-nfs-direct.yml, ho modificato la sezione nfs:

YAML
  nfs:
    server: 10.107.98.215  # ho inserito l'IP recuperato al punto 1
    path: /                  # IMPORTANTE: ho usato "/" perché il server usa fsid=0

Esecuzione

kubectl apply -f pod-nfs-direct.yaml

## 3. Modalità B: Persistent Volume (PV) & PVC 

In questo scenario, ho disaccoppiato la configurazione fisica (PV) dalla richiesta logica (PVC).

- Passo 1: Persistent Volume (nfs-pv.yml)

Ho configurato il puntatore allo storage reale.

Modificato server: con l'IP del Service NFS.

Modificato path: con /.

kubectl apply -f nfs-pv.yaml

- Passo 2: Persistent Volume Claim (nfs-pvc.yaml)

Il Pod richiede spazio generico.

kubectl apply -f nfs-pvc.yaml

- Passo 3: Il Pod (pod-nfs-pvc.yaml)

Il Pod usa la Claim. Non conosce l'IP del server.

kubectl apply -f pod-nfs-pvc.yaml

## Verifica e Test

Per confermare che tutto funzioni e che lo storage sia effettivamente condiviso tra i due Pod:

  - Ho controllato che i Pod fossero Running:

kubectl get pods

  - Ho scritto un file dal Pod "PVC":

kubectl exec -it nfs-pod-pvc -- sh -c "echo 'test' > /usr/share/nginx/html/test.txt"

  - Ed ho letto il file dal Pod "Direct":

kubectl exec -it nfs-pod-direct -- cat /usr/share/nginx/html/test.txt

  - Vedendo "test", è chiaro che i due Pod stavano leggendo dallo stesso disco NFS.

## Problematiche riscontrate

Durante l'esercizio ho dovuto risolvere i seguenti problemi:

  - Compatibilità ARM64:

Inizialmente stavo utilizzando un immagine standard gcr.io/google_samples/nfs-server ma non funzionava su Mac.

Soluzione: ho usato itsthenetwork/nfs-server-alpine:latest.

  - Mount Path e fsid=0:

L'immagine server configurava la cartella condivisa con il flag fsid=0. Questo significava che per il client la "radice" del mount era / e non il path fisico /nfsshare.

Soluzione: ho impostato path: / nei file YAML del client, altrimenti avrei ricevuto l'errore MountVolume.SetUp failed: ... No such file or directory.
