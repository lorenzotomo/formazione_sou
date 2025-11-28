ESERCIZIO CONTAINER/NFS-SHARE

Questa repository documenta l'esercitazione sulla gestione dello storage di rete con Docker. L'obiettivo è esportare una share NFS da una VM Server e montarla all'interno di un container Docker su una seconda VM Client situata sulla stessa subnet.

Infrastruttura:

Ho utilizzato Vagrant e VirtualBox per realizzare l’ambiente che consiste in due VM Ubuntu 22.04 LTS. La prima VM1 (Server) l’ho configurata con il server NFS (nfs-kernel-server) e ho esportato la share /srv/nfs/share. La VM2 (Client) l’ho configurata con Docker Engine e nfs-common. Tutto questo tramite Vagrantfile. Entrambe le VM le ho configurate con interfaccia Public Network (Bridge) per comunicare sulla stessa subnet.

Svolgimento:

- Bind Mount

In questa modalità, la share NFS viene montata prima sulla VM2 e successivamente passata al container.

vagrant@docker-client:~$ mkdir -p /home/vagrant/nfs_bind

vagrant@docker-client:~$ sudo mount -t nfs 192.168.1.62:/srv/nfs/share /home/vagrant/nfs_bind

vagrant@docker-client:~$ docker run -d --name es-1-bind \

> -v /home/vagrant/nfs_bind:/data \

> alpine sleep 3600

Unable to find image 'alpine:latest' locally

latest: Pulling from library/alpine

2d35ebdb57d9: Pull complete 

Digest: sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

Status: Downloaded newer image for alpine:latest

91faf31aa1355089ee443f0ae712d801ab67c90fc1346388b0310948ed732536

Come prova del nove ho creato un file.txt dentro il container e sono andato sul terminale della VM1 (server) per vedere se era presente anche li.

vagrant@docker-client:~$ docker exec -it es-1-bind touch /data/bind_mount.txt

vagrant@nfs-server:~$ ls /srv/nfs/share/
bind_mount.txt

- Docker Volume (CLI e Compose)

In questo caso, Docker gestisce direttamente la connessione NFS tramite il suo driver interno, senza dipendere da mount preventivi sulla VM2.

Metodo CLI:

vagrant@docker-client:~$ docker volume create --driver local \

> --opt type=nfs \

> --opt o=addr=192.168.1.62,rw \

> --opt device=:/srv/nfs/share \

> volume_nfs

volume_nfs

vagrant@docker-client:~$ docker run -d --name es-2-volume \

> -v volume_nfs:/data \

> alpine sleep 3600

acaf241c69147f295035eea032ad2a40868219b393b85119c29549db0e32a584

Metodo Docker Compose:

Ho creato un file docker-compose.yml per automatizzare la definizione del volume e del servizio. Il file di configurazione è situato nella cartella vm2-client.

vagrant@docker-client:~$ docker-compose up -d

Creating network "vagrant_default" with the default driver

Creating volume "vagrant_nfs-data-bonus" with local driver

Creating vagrant_app-bonus_1 ... done

- Mount diretto

In questa modalità, il container agisce come un host indipendente, prendendo e montando la share NFS direttamente al suo interno. Il container l’ho dovuto avviare con privilegi elevati (--privileged) per poter eseguire comandi di mount e ho dovuto installare al suo interno il client NFS (nfs-common) all’interno del container. Ho fatto tutto da container.

vagrant@docker-client:~$ docker run -it --privileged --name es-3-direct ubuntu:22.04 /bin/bash

Unable to find image 'ubuntu:22.04' locally

22.04: Pulling from library/ubuntu

7e49dc6156b0: Pull complete 

Digest: sha256:104ae83764a5119017b8e8d6218fa0832b09df65aae7d5a6de29a85d813da2fb

Status: Downloaded newer image for ubuntu:22.04

root@75217dbf460e:/# apt-get update && apt-get install -y nfs-common

Get:1 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]

Get:2 http://archive.ubuntu.com/ubuntu jammy InRelease [270 kB]

Get:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]

…(DOWNLOAD)...

Processing triggers for libc-bin (2.35-0ubuntu3.11) ...

root@75217dbf460e:/# mkdir -p /mnt/nfs_interno

root@75217dbf460e:/# mount -t nfs 192.168.1.62:/srv/nfs/share /mnt/nfs_interno
