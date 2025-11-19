# 🚀 Guía de Despliegue en Producción

## Sistema de Gestión de Carnets - ARCOR SAIC

---

## 📋 Requisitos Previos

### Hardware Mínimo

- **CPU**: 2 cores
- **RAM**: 4 GB
- **Disco**: 20 GB disponibles
- **Red**: Conexión estable

### Software

- Servidor web (Apache, Nginx, IIS)
- Base de datos (MySQL 8.0+, PostgreSQL 12+, SQL Server 2019+)
- Python 3.9+ (si usas backend API)
- Navegadores modernos (Chrome 90+, Firefox 88+, Edge 90+)

---

## 🌐 Opción 1: Despliegue Simple (Solo Frontend)

### Ventajas
- ✅ Sin configuración de servidor
- ✅ Funciona inmediatamente
- ✅ Ideal para uso local/intranet

### Pasos

1. **Copiar archivos al servidor web**
   ```bash
   # Windows (IIS)
   xcopy /E /I carnet C:\inetpub\wwwroot\carnet

   # Linux (Apache/Nginx)
   sudo cp -r carnet /var/www/html/
   ```

2. **Configurar permisos**
   ```bash
   # Linux
   sudo chown -R www-data:www-data /var/www/html/carnet
   sudo chmod -R 755 /var/www/html/carnet
   ```

3. **Acceder desde navegador**
   ```
   http://servidor-interno/carnet/index.html
   ```

### Configuración IIS (Windows Server)

1. Abrir IIS Manager
2. Agregar nuevo sitio web
3. Configurar:
   - **Nombre**: Carnets ARCOR
   - **Ruta física**: `C:\inetpub\wwwroot\carnet`
   - **Puerto**: 80 (o el que prefieras)
4. Configurar MIME types si es necesario:
   - `.json` → `application/json`
   - `.xlsx` → `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

### Configuración Apache (Linux)

```apache
# /etc/apache2/sites-available/carnets.conf

<VirtualHost *:80>
    ServerName carnets.arcor.local
    DocumentRoot /var/www/html/carnet

    <Directory /var/www/html/carnet>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/carnets-error.log
    CustomLog ${APACHE_LOG_DIR}/carnets-access.log combined
</VirtualHost>
```

Activar sitio:
```bash
sudo a2ensite carnets.conf
sudo systemctl reload apache2
```

### Configuración Nginx

```nginx
# /etc/nginx/sites-available/carnets

server {
    listen 80;
    server_name carnets.arcor.local;
    root /var/www/html/carnet;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|xlsx)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Activar sitio:
```bash
sudo ln -s /etc/nginx/sites-available/carnets /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔧 Opción 2: Despliegue Completo (Frontend + Backend + DB)

### Arquitectura Recomendada

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Navegador  │────▶│  Backend API │────▶│  Base Datos │
│   (HTML/JS) │◀────│   (Python)   │◀────│  (MySQL)    │
└─────────────┘     └──────────────┘     └─────────────┘
```

### Paso 1: Configurar Base de Datos

#### MySQL

```bash
# Instalar MySQL
sudo apt-get install mysql-server  # Linux
# O descargar desde https://dev.mysql.com/downloads/

# Crear base de datos
mysql -u root -p < database/mysql_setup.sql

# Crear usuario para la aplicación
mysql -u root -p
```

```sql
CREATE USER 'carnet_user'@'localhost' IDENTIFIED BY 'password_seguro_aqui';
GRANT ALL PRIVILEGES ON carnets_arcor.* TO 'carnet_user'@'localhost';
FLUSH PRIVILEGES;
```

#### PostgreSQL

```bash
# Instalar PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Crear base de datos
sudo -u postgres psql -f database/postgresql_setup.sql

# Crear usuario
sudo -u postgres psql
```

```sql
CREATE USER carnet_user WITH PASSWORD 'password_seguro_aqui';
GRANT ALL PRIVILEGES ON DATABASE carnets_arcor TO carnet_user;
```

#### SQL Server

```powershell
# Instalar SQL Server desde Microsoft

# Ejecutar script
sqlcmd -S localhost -U sa -P YourPassword -i database/sqlserver_setup.sql

# Crear usuario
sqlcmd -S localhost -U sa -P YourPassword
```

```sql
CREATE LOGIN carnet_user WITH PASSWORD = 'password_seguro_aqui';
USE carnets_arcor;
CREATE USER carnet_user FOR LOGIN carnet_user;
EXEC sp_addrolemember 'db_datareader', 'carnet_user';
EXEC sp_addrolemember 'db_datawriter', 'carnet_user';
```

### Paso 2: Configurar Backend API

#### Instalación de Python y Dependencias

```bash
# Instalar Python 3.9+
sudo apt-get install python3 python3-pip python3-venv  # Linux
# O descargar desde https://www.python.org/downloads/

# Crear entorno virtual
cd backend
python3 -m venv venv

# Activar entorno virtual
# Linux/Mac:
source venv/bin/activate
# Windows:
.\venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

#### Configurar Variables de Entorno

Crear archivo `.env`:

```bash
# backend/.env

# Base de datos
DATABASE_URL=mysql+pymysql://carnet_user:password_seguro_aqui@localhost/carnets_arcor

# Configuración Flask
FLASK_ENV=production
FLASK_DEBUG=0
SECRET_KEY=tu_clave_secreta_muy_segura_aqui

# CORS (orígenes permitidos)
ALLOWED_ORIGINS=http://carnets.arcor.local,https://carnets.arcor.com

# Puerto
PORT=5000
```

#### Modificar backend_api.py para usar .env

Agregar al inicio del archivo:

```python
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///carnets.db')
```

Instalar python-dotenv:
```bash
pip install python-dotenv
```

### Paso 3: Configurar Servicio Systemd (Linux)

```bash
# /etc/systemd/system/carnets-api.service

[Unit]
Description=Carnets ARCOR API
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/carnets/backend
Environment="PATH=/var/www/carnets/backend/venv/bin"
ExecStart=/var/www/carnets/backend/venv/bin/python backend_api.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Activar servicio:
```bash
sudo systemctl daemon-reload
sudo systemctl enable carnets-api
sudo systemctl start carnets-api
sudo systemctl status carnets-api
```

### Paso 4: Configurar Reverse Proxy

#### Nginx como Reverse Proxy

```nginx
# /etc/nginx/sites-available/carnets-full

upstream carnets_backend {
    server 127.0.0.1:5000;
}

server {
    listen 80;
    server_name carnets.arcor.local;
    
    # Frontend
    location / {
        root /var/www/carnets/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Backend API
    location /api {
        proxy_pass http://carnets_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|xlsx)$ {
        root /var/www/carnets/frontend;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Paso 5: Configurar HTTPS con SSL

#### Usando Let's Encrypt (Gratuito)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtener certificado
sudo certbot --nginx -d carnets.arcor.com

# Auto-renovación
sudo certbot renew --dry-run
```

#### Configuración manual SSL

```nginx
server {
    listen 443 ssl http2;
    server_name carnets.arcor.com;
    
    ssl_certificate /etc/ssl/certs/carnets.crt;
    ssl_certificate_key /etc/ssl/private/carnets.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Resto de configuración...
}

# Redirigir HTTP a HTTPS
server {
    listen 80;
    server_name carnets.arcor.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 🔐 Seguridad en Producción

### 1. Configurar Firewall

```bash
# Linux (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp  # SSH
sudo ufw enable

# Windows Server (PowerShell)
New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
```

### 2. Configurar Autenticación (Opcional)

Agregar a `backend_api.py`:

```python
from functools import wraps
from flask import request, jsonify
import jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv('SECRET_KEY')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'Token requerido'}), 401
        
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user = data['username']
        except:
            return jsonify({'error': 'Token inválido'}), 401
        
        return f(current_user, *args, **kwargs)
    
    return decorated

@app.route('/api/login', methods=['POST'])
def login():
    auth = request.get_json()
    
    # Validar credenciales (implementar lógica real)
    if auth.get('username') == 'admin' and auth.get('password') == 'password':
        token = jwt.encode({
            'username': auth['username'],
            'exp': datetime.utcnow() + timedelta(hours=24)
        }, SECRET_KEY, algorithm="HS256")
        
        return jsonify({'token': token})
    
    return jsonify({'error': 'Credenciales inválidas'}), 401
```

### 3. Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/carnets')
@limiter.limit("10 per minute")
def get_carnets():
    # ...
```

### 4. Validación de Entrada

```python
from marshmallow import Schema, fields, validate

class CarnetSchema(Schema):
    apellido = fields.Str(required=True, validate=validate.Length(max=100))
    nombre = fields.Str(required=True, validate=validate.Length(max=100))
    dni = fields.Str(required=True, validate=validate.Regexp(r'^\d{7,8}$'))
    legajo = fields.Str(required=True)
    fecha_calificacion = fields.Date(required=True)
    fecha_vencimiento = fields.Date(required=True)
    apto_medico = fields.Str(validate=validate.OneOf(['Apto', 'No Apto']))
```

---

## 📊 Monitoreo y Logs

### Configurar Logging

```python
import logging
from logging.handlers import RotatingFileHandler

# Configurar logging
handler = RotatingFileHandler('logs/carnets.log', maxBytes=10000000, backupCount=5)
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
app.logger.addHandler(handler)
```

### Monitorear Performance

```bash
# Instalar herramientas
pip install prometheus-flask-exporter

# Agregar métricas
from prometheus_flask_exporter import PrometheusMetrics
metrics = PrometheusMetrics(app)
```

---

## 🔄 Backup y Recuperación

### Backup Automático de Base de Datos

#### MySQL

```bash
# Script: backup_mysql.sh
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/carnets"
mysqldump -u carnet_user -p carnets_arcor > $BACKUP_DIR/carnets_$DATE.sql
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
```

Agregar a crontab:
```bash
# Backup diario a las 2 AM
0 2 * * * /path/to/backup_mysql.sh
```

#### PostgreSQL

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/carnets"
pg_dump -U carnet_user carnets_arcor > $BACKUP_DIR/carnets_$DATE.sql
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
```

---

## 📱 Integración con Active Directory (Opcional)

```python
from ldap3 import Server, Connection, ALL

def authenticate_ad(username, password):
    server = Server('ldap://ad.arcor.local', get_info=ALL)
    conn = Connection(server, user=f'ARCOR\\{username}', password=password)
    
    if conn.bind():
        return True
    return False
```

---

## 🎯 Checklist de Producción

### Pre-Despliegue

- [ ] Base de datos configurada y probada
- [ ] Backend API funcionando
- [ ] Frontend apuntando a API correcta
- [ ] SSL/TLS configurado
- [ ] Firewall configurado
- [ ] Usuarios y permisos creados
- [ ] Backups automáticos configurados
- [ ] Logging configurado
- [ ] Monitoreo implementado

### Post-Despliegue

- [ ] Verificar conectividad desde clientes
- [ ] Probar carga de Excel
- [ ] Verificar alertas de vencimiento
- [ ] Confirmar exportación de datos
- [ ] Validar búsqueda y filtros
- [ ] Revisar logs por errores
- [ ] Confirmar backup automático funciona
- [ ] Documentar URLs y credenciales
- [ ] Capacitar usuarios finales

---

## 📞 Soporte y Mantenimiento

### Logs Importantes

```bash
# Backend API
tail -f /var/www/carnets/backend/logs/carnets.log

# Nginx
tail -f /var/log/nginx/carnets-error.log

# Systemd service
journalctl -u carnets-api -f
```

### Comandos Útiles

```bash
# Reiniciar servicio
sudo systemctl restart carnets-api

# Ver estado
sudo systemctl status carnets-api

# Verificar conexión DB
mysql -u carnet_user -p carnets_arcor
```

---

**Documentación preparada para ARCOR SAIC**
Versión 1.0 - Noviembre 2024
