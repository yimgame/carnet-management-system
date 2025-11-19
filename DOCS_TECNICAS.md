# 🛠️ Documentación Técnica para Desarrolladores

## Sistema de Gestión de Carnets - ARCOR SAIC

---

## 📐 Arquitectura del Sistema

### Frontend (SPA - Single Page Application)

```
index.html
├── HTML5 Semantic
├── CSS3 (Grid, Flexbox, Gradientes)
├── JavaScript Vanilla (ES6+)
└── SheetJS (xlsx.js) para Excel
```

**Características:**
- Sin frameworks (Vanilla JS)
- localStorage para persistencia
- Responsive design
- Progressive Web App ready

### Backend (Opcional)

```
Python Flask API
├── Flask (Web Framework)
├── SQLAlchemy (ORM)
├── Pandas (Procesamiento Excel)
└── Flask-CORS (CORS handling)
```

### Base de Datos

Soporta múltiples engines:
- MySQL 8.0+
- PostgreSQL 12+
- SQL Server 2019+
- Oracle 19c+
- JD Edwards EnterpriseOne

---

## 🗂️ Estructura de Datos

### Modelo de Datos Principal

```javascript
{
  id: Number,                    // ID único
  apellido: String,              // Apellido del conductor
  nombre: String,                // Nombre del conductor
  dni: String,                   // DNI único
  legajo: String,                // Legajo empleado
  fecha_calificacion: Date,      // Fecha de calificación
  fecha_vencimiento: Date,       // Fecha de vencimiento
  apto_medico: String,           // "Apto" o "No Apto"
  empresa: String,               // "ARCOR SAIC"
  tipo_autorizacion: String,     // "Autoelevador 2240 Kg"
  resolucion: String,            // "960/2015"
  fecha_creacion: Timestamp,     // Auto-generado
  fecha_actualizacion: Timestamp, // Auto-actualizado
  activo: Boolean                // Soft delete
}
```

### Estados de Carnet

```javascript
const ESTADOS = {
  ACTIVE: 'active',      // > 30 días hasta vencimiento
  WARNING: 'warning',    // <= 30 días hasta vencimiento
  EXPIRED: 'expired'     // Fecha vencimiento < hoy
};
```

---

## 💻 Frontend - Funciones JavaScript Principales

### 1. Gestión de Datos

#### `loadFromLocalStorage()`
Carga datos del localStorage al iniciar la aplicación.

```javascript
function loadFromLocalStorage() {
    const stored = localStorage.getItem('carnetsData');
    if (stored) {
        carnetsData = JSON.parse(stored);
    }
}
```

#### `saveToLocalStorage()`
Persiste datos en localStorage.

```javascript
function saveToLocalStorage() {
    localStorage.setItem('carnetsData', JSON.stringify(carnetsData));
}
```

### 2. Procesamiento de Excel

#### `loadExcel(event)`
Procesa archivo Excel y convierte a JSON.

```javascript
function loadExcel(event) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = function(e) {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { type: 'array' });
        const firstSheet = workbook.Sheets[workbook.SheetNames[0]];
        const jsonData = XLSX.utils.sheet_to_json(firstSheet);
        // Procesar datos...
    };
    reader.readAsArrayBuffer(file);
}
```

**Dependencia:** SheetJS (xlsx.js)
- CDN: https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js

### 3. Cálculo de Estados

#### `getStatus(vencimiento)`
Calcula el estado basado en fecha de vencimiento.

```javascript
function getStatus(vencimiento) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const vencDate = parseDate(vencimiento);
    
    if (!vencDate || isNaN(vencDate)) return 'unknown';
    
    const diffTime = vencDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 0) return 'expired';
    if (diffDays <= 30) return 'warning';
    return 'active';
}
```

**Lógica:**
- `expired`: `diffDays < 0`
- `warning`: `0 <= diffDays <= 30`
- `active`: `diffDays > 30`

### 4. Parsing de Fechas

#### `parseDate(dateStr)`
Parsea diferentes formatos de fecha.

```javascript
function parseDate(dateStr) {
    if (!dateStr) return null;
    
    // Formato DD/MM/YYYY
    if (dateStr.includes('/')) {
        const parts = dateStr.split('/');
        return new Date(parts[2], parts[1] - 1, parts[0]);
    }
    // Formato YYYY-MM-DD
    return new Date(dateStr);
}
```

**Formatos soportados:**
- DD/MM/YYYY (ejemplo: 30/11/2024)
- YYYY-MM-DD (ejemplo: 2024-11-30)

### 5. Renderizado

#### `renderCarnets(filteredData)`
Renderiza tarjetas de carnets en el DOM.

```javascript
function renderCarnets(filteredData = null) {
    const data = filteredData || carnetsData;
    const grid = document.getElementById('carnetsGrid');
    
    grid.innerHTML = data.map(carnet => {
        const status = getStatus(carnet.fecha_vencimiento);
        // Generar HTML...
    }).join('');
    
    updateStats(data);
    updateAlerts(data);
}
```

**Optimización:**
- Template literals para HTML
- `.map().join('')` para mejor performance que `+=`
- Actualización stats y alerts en un solo pase

### 6. Estadísticas

#### `updateStats(data)`
Calcula y actualiza contadores.

```javascript
function updateStats(data) {
    const total = data.length;
    const active = data.filter(c => getStatus(c.fecha_vencimiento) === 'active').length;
    const warning = data.filter(c => getStatus(c.fecha_vencimiento) === 'warning').length;
    const expired = data.filter(c => getStatus(c.fecha_vencimiento) === 'expired').length;
    
    document.getElementById('totalCarnets').textContent = total;
    document.getElementById('activeCount').textContent = active;
    document.getElementById('warningCount').textContent = warning;
    document.getElementById('expiredCount').textContent = expired;
}
```

### 7. Alertas

#### `updateAlerts(data)`
Muestra carnets vencidos o por vencer.

```javascript
function updateAlerts(data) {
    const alerts = data.filter(c => {
        const status = getStatus(c.fecha_vencimiento);
        return status === 'expired' || status === 'warning';
    });
    
    const alertsSection = document.getElementById('alertsSection');
    
    if (alerts.length === 0) {
        alertsSection.style.display = 'none';
        return;
    }
    
    alertsSection.style.display = 'block';
    // Renderizar alertas...
}
```

### 8. Filtrado y Búsqueda

#### `filterCarnets()`
Filtra carnets por texto y estado.

```javascript
function filterCarnets() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const statusFilter = document.getElementById('statusFilter').value;

    let filtered = carnetsData;

    // Búsqueda por texto
    if (searchTerm) {
        filtered = filtered.filter(c => 
            c.nombre.toLowerCase().includes(searchTerm) ||
            c.apellido.toLowerCase().includes(searchTerm) ||
            c.dni.includes(searchTerm)
        );
    }

    // Filtrar por estado
    if (statusFilter !== 'all') {
        filtered = filtered.filter(c => getStatus(c.fecha_vencimiento) === statusFilter);
    }

    renderCarnets(filtered);
}
```

**Características:**
- Case-insensitive search
- Búsqueda por múltiples campos
- Filtrado combinado (texto + estado)

### 9. Exportación

#### `exportData()`
Exporta datos a Excel.

```javascript
function exportData() {
    if (carnetsData.length === 0) {
        alert('No hay datos para exportar');
        return;
    }

    const ws = XLSX.utils.json_to_sheet(carnetsData.map(c => ({
        Apellido: c.apellido,
        Nombre: c.nombre,
        DNI: c.dni,
        Legajo: c.legajo,
        Fecha_Calificacion: formatDate(c.fecha_calificacion),
        Fecha_Vencimiento: formatDate(c.fecha_vencimiento),
        Apto_Medico: c.apto_medico,
        Estado: getStatus(c.fecha_vencimiento) === 'expired' ? 'Vencido' : 
               getStatus(c.fecha_vencimiento) === 'warning' ? 'Por Vencer' : 'Vigente'
    })));

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Carnets");
    XLSX.writeFile(wb, `carnets_arcor_${new Date().toISOString().split('T')[0]}.xlsx`);
}
```

---

## 🔌 Backend API - Endpoints

### Base URL
```
http://localhost:5000/api
```

### 1. Listar Carnets

**GET** `/carnets`

Respuesta:
```json
[
  {
    "id": 1,
    "apellido": "GONZALEZ",
    "nombre": "JUAN",
    "dni": "28567123",
    "legajo": "1001",
    "fecha_calificacion": "2024-11-30",
    "fecha_vencimiento": "2025-11-29",
    "apto_medico": "Apto",
    "empresa": "ARCOR SAIC",
    "tipo_autorizacion": "Autoelevador 2240 Kg",
    "resolucion": "960/2015",
    "estado": "active"
  }
]
```

### 2. Obtener Carnet por ID

**GET** `/carnets/<id>`

Respuesta:
```json
{
  "id": 1,
  "apellido": "GONZALEZ",
  "nombre": "JUAN",
  ...
}
```

### 3. Crear Carnet

**POST** `/carnets`

Body:
```json
{
  "apellido": "PEREZ",
  "nombre": "JOSE",
  "dni": "30123456",
  "legajo": "2001",
  "fecha_calificacion": "2024-11-01",
  "fecha_vencimiento": "2025-10-31",
  "apto_medico": "Apto"
}
```

Respuesta: `201 Created`

### 4. Actualizar Carnet

**PUT** `/carnets/<id>`

Body: (campos a actualizar)
```json
{
  "fecha_vencimiento": "2026-10-31"
}
```

### 5. Eliminar Carnet

**DELETE** `/carnets/<id>`

Respuesta:
```json
{
  "message": "Carnet eliminado correctamente"
}
```

### 6. Obtener Alertas

**GET** `/carnets/alertas`

Respuesta: Array de carnets vencidos o por vencer

### 7. Estadísticas

**GET** `/estadisticas`

Respuesta:
```json
{
  "total_carnets": 10,
  "vigentes": 7,
  "por_vencer": 2,
  "vencidos": 1
}
```

### 8. Buscar

**GET** `/carnets/buscar?q=gonzalez&estado=active`

Parámetros:
- `q`: Término de búsqueda
- `estado`: active | warning | expired

### 9. Importar Excel

**POST** `/carnets/import-excel`

Content-Type: `multipart/form-data`
Field: `file`

Respuesta:
```json
{
  "message": "Importación completada",
  "importados": 5,
  "errores": []
}
```

### 10. Exportar Excel

**GET** `/carnets/export-excel`

Respuesta: Archivo Excel

---

## 🗃️ Esquema de Base de Datos

### Tabla: carnets

```sql
CREATE TABLE carnets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    legajo VARCHAR(50) NOT NULL,
    fecha_calificacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    apto_medico VARCHAR(20) DEFAULT 'Apto',
    empresa VARCHAR(100) DEFAULT 'ARCOR SAIC',
    tipo_autorizacion VARCHAR(200) DEFAULT 'Autoelevador 2240 Kg',
    resolucion VARCHAR(50) DEFAULT '960/2015',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_dni (dni),
    INDEX idx_apellido (apellido),
    INDEX idx_vencimiento (fecha_vencimiento)
);
```

### Índices

- `idx_dni`: Búsqueda por DNI
- `idx_apellido`: Ordenamiento y búsqueda
- `idx_vencimiento`: Cálculo de alertas

### Vistas Útiles

#### v_carnets_estado
Carnets con estado calculado

```sql
CREATE VIEW v_carnets_estado AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CURDATE() THEN 'VENCIDO'
        WHEN DATEDIFF(c.fecha_vencimiento, CURDATE()) <= 30 THEN 'POR_VENCER'
        ELSE 'VIGENTE'
    END AS estado,
    DATEDIFF(c.fecha_vencimiento, CURDATE()) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = TRUE;
```

#### v_alertas_vencimiento
Solo carnets con alertas

```sql
CREATE VIEW v_alertas_vencimiento AS
SELECT * FROM v_carnets_estado
WHERE estado IN ('VENCIDO', 'POR_VENCER')
ORDER BY fecha_vencimiento ASC;
```

---

## 🎨 CSS - Clases Principales

### Estados

```css
.carnet-card.active { }    /* Verde */
.carnet-card.warning { }   /* Amarillo */
.carnet-card.expired { }   /* Rojo */
```

### Badges

```css
.badge-success { }  /* Verde */
.badge-warning { }  /* Amarillo */
.badge-danger { }   /* Rojo */
```

### Botones

```css
.btn-primary { }    /* Azul */
.btn-success { }    /* Verde */
.btn-warning { }    /* Amarillo */
```

---

## 🧪 Testing

### Frontend Testing (Manual)

```javascript
// Test 1: Cargar datos
localStorage.setItem('carnetsData', JSON.stringify([
    {
        id: 1,
        apellido: "TEST",
        nombre: "USUARIO",
        dni: "99999999",
        legajo: "9999",
        fecha_calificacion: "2024-01-01",
        fecha_vencimiento: "2025-12-31",
        apto_medico: "Apto"
    }
]));
location.reload();

// Test 2: Limpiar datos
localStorage.removeItem('carnetsData');
location.reload();
```

### Backend Testing (con curl)

```bash
# Test 1: Health check
curl http://localhost:5000/health

# Test 2: Listar carnets
curl http://localhost:5000/api/carnets

# Test 3: Crear carnet
curl -X POST http://localhost:5000/api/carnets \
  -H "Content-Type: application/json" \
  -d '{"apellido":"TEST","nombre":"USER","dni":"99999999","legajo":"9999","fecha_calificacion":"2024-01-01","fecha_vencimiento":"2025-12-31","apto_medico":"Apto"}'

# Test 4: Estadísticas
curl http://localhost:5000/api/estadisticas
```

---

## 🔧 Troubleshooting

### Problema: CORS Error

**Síntoma:** Error en consola del navegador

**Solución:**
```python
from flask_cors import CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})
```

### Problema: localStorage lleno

**Síntoma:** No se guardan datos nuevos

**Solución:**
```javascript
try {
    localStorage.setItem('carnetsData', JSON.stringify(carnetsData));
} catch (e) {
    if (e.name === 'QuotaExceededError') {
        alert('Almacenamiento lleno. Exporta y limpia datos antiguos.');
    }
}
```

### Problema: Fechas incorrectas

**Síntoma:** Fechas con desfase de 1 día

**Causa:** Timezone UTC conversion

**Solución:**
```javascript
function parseDate(dateStr) {
    const [year, month, day] = dateStr.split('-');
    return new Date(year, month - 1, day);  // Usar constructor con componentes
}
```

---

## 📚 Librerías y Dependencias

### Frontend

| Librería | Versión | Propósito |
|----------|---------|-----------|
| xlsx.js | 0.18.5 | Procesamiento Excel |

### Backend

| Librería | Versión | Propósito |
|----------|---------|-----------|
| Flask | 3.0.0 | Web framework |
| Flask-CORS | 4.0.0 | CORS handling |
| SQLAlchemy | 2.0.23 | ORM |
| Pandas | 2.1.4 | Data processing |
| openpyxl | 3.1.2 | Excel writer |

---

## 🚀 Mejoras Futuras

### Priority 1
- [ ] Autenticación JWT
- [ ] Roles y permisos
- [ ] Auditoría de cambios

### Priority 2
- [ ] Notificaciones por email
- [ ] Generación PDF de carnets
- [ ] Dashboard ejecutivo

### Priority 3
- [ ] App móvil (React Native)
- [ ] Integración WhatsApp
- [ ] Machine Learning para predicciones

---

## 📝 Convenciones de Código

### JavaScript

```javascript
// Usar camelCase para variables y funciones
let carnetData = {};
function getData() {}

// Usar UPPER_CASE para constantes
const MAX_UPLOAD_SIZE = 5242880;

// Documentar funciones complejas
/**
 * Calcula el estado del carnet basado en fecha de vencimiento
 * @param {string} vencimiento - Fecha de vencimiento (YYYY-MM-DD)
 * @returns {string} Estado: 'active', 'warning' o 'expired'
 */
function getStatus(vencimiento) { }
```

### Python

```python
# Usar snake_case para variables y funciones
carnet_data = {}
def get_data():
    pass

# Usar PascalCase para clases
class CarnetModel:
    pass

# Type hints
def create_carnet(data: dict) -> Carnet:
    pass
```

### SQL

```sql
-- Usar snake_case para tablas y columnas
CREATE TABLE carnets (
    fecha_vencimiento DATE
);

-- Prefijos claros para índices y constraints
INDEX idx_carnets_dni
CONSTRAINT fk_carnets_usuario
```

---

**Documentación Técnica v1.0**
Sistema de Gestión de Carnets - ARCOR SAIC
Noviembre 2024
