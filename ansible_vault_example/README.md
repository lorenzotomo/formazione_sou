# Esercizio Ansible Vault

Questo esercizio dimostra come utilizzare Ansible Vault per crittografare variabili sensibili e come includerle in un playbook tramite la direttiva 'vars_files'.

L'obiettivo principale è imparare a gestire le informazioni sensibili (come chiavi API, password) in modo sicuro, separandole dalla logica del playbook e proteggendole con crittografia AES256.

# 1. Creazione del Vault

Il file 'vault_vars.yml' è stato creato e immediatamente crittografato usando il comando 'ansible-vault create vault_vars.yml'.

# 2. Creazione del Playbook

Il file playbook.yml è responsabile di caricare le variabili e stamparle a video per verificarne il corretto caricamento.

# 3. Esecuzione del playbook

Ho utilizzato il comando 'ansible-playbook playbook.yml' con il flag '--ask-vault-pass' per attivare il prompt della password e consentire ad Ansible di decifrare vault_vars.yml.

Come risultato ho avuto il seguente:

MacBook-Pro-di-Lorenzo:ansible_vault_example lorenzotomo$ ansible-playbook playbook.yml --ask-vault-pass
Vault password: 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit
localhost does not match 'all'

PLAY [Esercizio Ansible Vault e vars_files] *******************************************************

TASK [Gathering Facts] ****************************************************************************
ok: [localhost]

TASK [Stampa a video il valore di database_host] **************************************************
ok: [localhost] => {
    "msg": "Host del database: db_server_01"
}

TASK [Stampa a video il valore di database_port] **************************************************
ok: [localhost] => {
    "msg": "Porta del database: 5432"
}

TASK [Stampa a video il valore di secret_key (variabile segreta)] *********************************
ok: [localhost] => {
    "msg": "Chiave segreta: password_segreta"
}

PLAY RECAP ****************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


