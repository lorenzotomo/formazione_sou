# Network Policies

Ho configurato un architettura sicura a tre livelli (Frontend, Backend e Database).
Ho fatto un deployment di frontend e di backend Nginx e di database Redis.
Per supportare le network policies ho dovuto riconfigurare il cluster con un plugin di rete (CNI) che supportava il filtraggio del traffico. Ho utilizzato Calico.

minikube start --network-plugin=cni --cni=calico

Le Network Policies sono state configurate in questo modo:

- Frontend: Può comunicare solo verso il Backend. Accetta traffico esterno.
- Backend: Può comunicare solo verso il Database. Accetta traffico solo dal Frontend. Accesso a internet bloccato.
- Database: Accetta traffico solo dal Backend. Isolato da tutto il resto.

Per verificare che le policies fossero attive ho eseguito i seguenti test di connettività:

- kubectl exec -it deploy/frontend -- curl backend  
Frontend --> Backend: OK

- kubectl exec -it deploy/backend -- curl google.com
Backend --> Google (Internet): BLOCCATO (Timeout)

- kubectl exec -it deploy/backend -- nc -zv database 6379
Backend --> Database: OK