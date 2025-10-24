#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Inizio provisioning: installazione Apache e creazione pagina web"

sudo apt-get update -y

sudo apt-get install -y apache2

sudo systemctl enable apache2

# Crea una cartella personalizzata per il nostro sito
sudo mkdir -p /var/www/devops_apache

# Crea una pagina HTML personalizzata
sudo tee /var/www/devops_apache/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>DevOps Everywhere - Apache Edition</title>
  <style>
    body { font-family: sans-serif; background: #1b1b2f; color: #dcdcdc; text-align: center; padding: 5rem; }
    h1 { color: #ff6f61; }
    p { color: #ccc; }
  </style>
</head>
<body>
  <h1>🔥 DevOps Everywhere - Apache Edition</h1>
  <p>Questa pagina è stata generata automaticamente dal provisioning Vagrant + Bash.</p>
  <p>Server: <strong>Apache2</strong></p>
  <p>Accesso: <a href="http://localhost:8080" style="color:#9df;">http://localhost:8080</a></p>
</body>
</html>
EOF

# Crea un VirtualHost per il nostro sito
sudo tee /etc/apache2/sites-available/devops_apache.conf > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/devops_apache
    ErrorLog ${APACHE_LOG_DIR}/devops_error.log
    CustomLog ${APACHE_LOG_DIR}/devops_access.log combined
</VirtualHost>
EOF

# Abilita il nuovo sito e disabilita quello di default
sudo a2dissite 000-default.conf
sudo a2ensite devops_apache.conf

# Ricarica Apache per applicare i cambiamenti
sudo systemctl reload apache2

echo "✅ Provisioning completato! Apri http://localhost:8080"

