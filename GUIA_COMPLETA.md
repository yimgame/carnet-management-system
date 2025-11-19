# 📖 Guía Completa del Sistema de Carnets ARCOR

**Versión:** 1.4  
**Última actualización:** 19 de Noviembre de 2025  
**Sistema completo para gestionar carnets de conducir de autoelevadores**

---

## 📑 Índice

1. [Inicio Rápido](#-inicio-rápido)
2. [Funcionalidades Principales](#-funcionalidades-principales)
3. [Cómo Usar el Sistema](#-cómo-usar-el-sistema)
4. [Gestión de Fotos](#-gestión-de-fotos)
5. [Impresión de Carnets](#-impresión-de-carnets)
6. [Base de Datos](#-base-de-datos)
7. [Producción y Despliegue](#-producción-y-despliegue)
8. [Troubleshooting](#-troubleshooting)
9. [FAQ](#-faq)

---

## 🚀 Inicio Rápido

### ¿Qué es este sistema?

Sistema web para gestionar carnets de conducir de autoelevadores con:
- ✅ Alertas automáticas de vencimiento
- ✅ Gestión completa de conductores
- ✅ Impresión de carnets físicos
- ✅ Carga masiva desde Excel
- ✅ Búsqueda y filtrado avanzado

### Empezar en 3 pasos

1. **Abrir** `index.html` en tu navegador
2. **Cargar** el archivo `template_carnets.xlsx`
3. **¡Listo!** Ya puedes gestionar carnets

---

## ⭐ Funcionalidades Principales

### 📊 Dashboard

- **Total de carnets** registrados
- **Carnets vigentes** (más de 30 días)
- **Por vencer** (próximos 30 días)
- **Vencidos** (requieren renovación)

### ⚠️ Alertas Automáticas

El sistema revisa automáticamente y muestra:
- 🔴 **Carnets vencidos** (acción inmediata requerida)
- 🟡 **Por vencer** (renovar en 30 días)
- 🟢 **Vigentes** (OK)

### 📂 Carga de Datos

**Opción A: Desde Excel**
- Carga masiva de múltiples carnets
- Formato simple (ver `template_carnets.xlsx`)
- Validación automática

**Opción B: Manual**
- Formulario web intuitivo
- Agregar carnet por carnet
- Incluye campo de foto

### 🔍 Búsqueda y Filtros

- Buscar por **nombre**, **apellido** o **DNI**
- Filtrar por **estado** (Todos/Vigentes/Por vencer/Vencidos)
- Resultados en tiempo real

### ✏️ Edición

- **Editar** cualquier carnet después de creado
- Modificar todos los datos incluida la **foto**
- Opción para **eliminar** carnets

### 🖨️ Impresión

- **Imprimir individual**: Un carnet a la vez
- **Imprimir en masa**: Múltiples carnets
- **Configuración flexible**: 2-10 carnets por hoja A4
- **Botón rápido**: 10 carnets por hoja (2×5)
- **Diseño oficial ARCOR**: Coincide con imagen corporativa

### 💾 Exportación

- Exportar todos los datos a **Excel**
- Incluye columna de **estado** calculado
- Nombre de archivo con **fecha** automática

---

## 🎯 Cómo Usar el Sistema

### 1️⃣ Cargar Datos desde Excel

**Paso a paso:**

1. Haz clic en **"📂 Cargar Excel"**
2. Selecciona tu archivo Excel
3. El sistema carga automáticamente todos los carnets
4. Verás las tarjetas aparecer en la pantalla

**Formato del Excel:**

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| Apellido | Apellido del conductor | GONZALEZ |
| Nombre | Nombre del conductor | JUAN |
| DNI | Documento (solo números) | 28567123 |
| Legajo | Número de legajo | 1001 |
| Fecha_Calificacion | Fecha de calificación | 30/11/2024 |
| Fecha_Vencimiento | Fecha de vencimiento | 29/11/2025 |
| Apto_Medico | Estado médico | Apto |

**Formatos de fecha aceptados:**
- `DD/MM/YYYY` → 30/11/2025
- `YYYY-MM-DD` → 2025-11-30

📋 **Plantilla:** Usa `template_carnets.xlsx` como base

---

### 2️⃣ Agregar Carnet Nuevo

**Paso a paso:**

1. Haz clic en **"➕ Nuevo Carnet"**
2. Completa el formulario:
   - Apellido *
   - Nombre *
   - DNI *
   - Legajo *
   - Fecha de Calificación *
   - Fecha de Vencimiento *
   - Apto Médico *
   - **Foto** (opcional)
3. Sube una foto (JPG/PNG)
4. Haz clic en **"Guardar"**

**Sobre las fotos:**
- Opcional pero recomendado
- Formatos: JPG, PNG
- Tamaño máximo: 2 MB (recomendado: 100-200 KB)
- Dimensiones ideales: 400×500 px

---

### 3️⃣ Editar Carnet Existente

**Paso a paso:**

1. Busca el carnet que quieres editar
2. Haz clic en **"✏️ Editar"**
3. Modifica los datos necesarios
4. **Cambiar foto:**
   - Selecciona nueva foto en el campo
   - O haz clic en "🗑️ Eliminar foto" para borrarla
5. Haz clic en **"💾 Actualizar"**

**Puedes editar:**
- ✅ Todos los datos personales
- ✅ Fechas de calificación y vencimiento
- ✅ Apto médico
- ✅ Foto (cambiar o eliminar)

---

### 4️⃣ Eliminar Carnet

**Paso a paso:**

1. Busca el carnet a eliminar
2. Haz clic en **"🗑️ Eliminar"**
3. Confirma la acción en el diálogo

⚠️ **IMPORTANTE:** Esta acción es **permanente** y no se puede deshacer.

---

### 5️⃣ Buscar Carnets

**Búsqueda por texto:**
1. Escribe en el campo de búsqueda:
   - Nombre
   - Apellido
   - DNI
2. Los resultados se filtran automáticamente

**Filtro por estado:**
1. Selecciona en el desplegable:
   - **Todos:** Muestra todos los carnets
   - **Vigentes:** Solo carnets OK
   - **Por vencer:** Próximos 30 días
   - **Vencidos:** Requieren renovación
2. Haz clic en "Filtrar"

---

### 6️⃣ Exportar a Excel

**Paso a paso:**

1. Haz clic en **"💾 Exportar Datos"**
2. El archivo se descarga automáticamente
3. Nombre: `carnets_arcor_YYYY-MM-DD.xlsx`

**El archivo incluye:**
- Todos los datos de los carnets
- Columna de **estado** calculado
- Formato listo para importar nuevamente

---

## 📸 Gestión de Fotos

### Dos Opciones Disponibles

#### **Opción A: Base64 (Actual)**

**✅ Características:**
- Las fotos se guardan dentro del navegador
- Todo en un solo lugar (localStorage)
- Fácil de respaldar
- Sin configuración adicional

**❌ Limitaciones:**
- Límite total: ~5-10 MB
- Capacidad: 20-50 carnets con fotos
- Más lento con muchas fotos

**📊 Cuándo usar:**
- Menos de 30 empleados
- Uso personal o de oficina pequeña
- No tienes servidor web

---

#### **Opción B: Carpeta Local**

**✅ Características:**
- Sin límite de tamaño
- Mejor rendimiento
- Fotos organizadas

**❌ Requisitos:**
- Estructura de carpetas
- Copiar fotos manualmente
- Servidor web recomendado

**📁 Estructura:**
```
carnets/
├── index.html
├── fotos/
│   ├── LEEME.txt
│   ├── 12345678.jpg    ← DNI.jpg
│   ├── 23456789.jpg
│   └── ...
```

**🏷️ Nomenclatura:**
- Nombre del archivo: `DNI.extensión`
- Ejemplos:
  - DNI 12345678 → `12345678.jpg`
  - DNI 23456789 → `23456789.png`

**📊 Cuándo usar:**
- Más de 30 empleados
- Uso en producción
- Necesitas alta calidad

---

### Agregar Fotos

**Al crear carnet nuevo:**
1. En el formulario, campo "Foto del Conductor"
2. Haz clic en **"Seleccionar archivo"**
3. Elige la foto (JPG/PNG)
4. Verás la vista previa
5. Guarda el carnet

**Al editar carnet existente:**
1. Botón **"✏️ Editar"**
2. Sección "Foto del Conductor"
3. Verás la foto actual (si existe)
4. Opciones:
   - **Mantener:** No hagas nada
   - **Cambiar:** Selecciona nueva foto
   - **Eliminar:** Click en "🗑️ Eliminar foto"

---

### Optimizar Fotos

**Herramientas recomendadas:**
- **TinyPNG** → https://tinypng.com/ (online)
- **ImageOptim** (Mac)
- **RIOT** (Windows)
- **Squoosh** → https://squoosh.app/ (online)

**Configuración ideal:**
- **Dimensiones:** 400 × 500 píxeles
- **Peso:** 100-150 KB
- **Formato:** JPG (calidad 80-85%)
- **Recorte:** Centrado en la cara

---

## 🖨️ Impresión de Carnets

### 3 Formas de Imprimir

#### 1️⃣ Imprimir Individual

**Uso:** Un carnet específico

**Paso a paso:**
1. Busca el carnet
2. Haz clic en **"🖨️ Imprimir"**
3. Se genera PDF con ese carnet
4. Se descarga automáticamente

**Resultado:** PDF con un carnet centrado en página A4

---

#### 2️⃣ Imprimir 10 por Hoja (Rápido)

**Uso:** Todos los carnets en formato estándar

**Paso a paso:**
1. Haz clic en **"🖨️ 10 por Hoja"** (botón morado)
2. Se genera PDF automáticamente
3. Formato: 2 columnas × 5 filas

**Resultado:** PDF con todos tus carnets, 10 por página A4

⚡ **Ventaja:** No necesitas configurar nada

---

#### 3️⃣ Imprimir Personalizado

**Uso:** Configuración avanzada

**Paso a paso:**
1. Haz clic en **"🖨️ Configurar"**
2. Se abre modal de configuración
3. Elige opciones:
   - **Carnets por hoja:** 2, 4, 6, 8, 10
   - **Orientación:** Vertical/Horizontal
   - **Filtrar por estado:** Todos/Vigentes/Por vencer/Vencidos
   - **Logo:** Incluir/No incluir
4. Vista previa muestra primeros 10
5. Haz clic en **"Generar PDF"**

**Resultado:** PDF personalizado según tu configuración

---

### Configuración de Impresión

**Carnets por hoja:**
- **2 carnets:** Muy grandes, máximo detalle
- **4 carnets:** Grande, buena legibilidad
- **6 carnets:** Mediano, equilibrado
- **8 carnets:** Pequeño, compacto
- **10 carnets:** Estándar recomendado (2×5)

**Orientación:**
- **Vertical (Portrait):** Para 10, 8, 6 carnets
- **Horizontal (Landscape):** Para 2, 4 carnets

**Consejos:**
- Para imprimir en papel adhesivo: 10 por hoja
- Para carnets de prueba: 4-6 por hoja
- Para carnets premium: 2 por hoja

---

### Diseño del Carnet

**Elementos incluidos:**

🔵 **Header azul (degradado)**
- Título: "Chofer Autorizado para manejar autoelevador de 2240 Kg"

📸 **Foto**
- 20×25 mm
- Esquina superior izquierda
- O emoji 👤 si no hay foto

📋 **Datos del conductor**
- Empresa: ARCOR SAIC
- Apellido
- Nombre
- DNI
- Legajo
- Fecha de Calificación
- Fecha de Vencimiento
- Apto Médico

🔵 **Footer azul (degradado)**
- "Resolución 960/2015"
- "AUTORIZADO POR LA EMPRESA"

🎨 **Indicador de estado**
- Verde: Vigente
- Amarillo: Por vencer
- Rojo: Vencido

---

### Impresión Física

**Materiales recomendados:**
- **Papel:** Cartulina 200-250 gsm
- **Tamaño:** A4 (210×297 mm)
- **Acabado:** Mate o brillante según preferencia
- **Opcional:** Papel adhesivo para stickers

**Configuración de impresora:**
1. Calidad: **Alta** o **Máxima**
2. Tipo de papel: **Cartulina** o **Fotográfico**
3. Orientación: **Vertical**
4. Escala: **100%** (no ajustar)
5. Márgenes: **Predeterminados**

**Post-impresión:**
- Cortar con guillotina para mejor resultado
- Plastificar para durabilidad
- O usar papel adhesivo para evitar plastificado

---

## 💾 Base de Datos

### Opción 1: Sin Base de Datos (Actual)

**Cómo funciona:**
- Los datos se guardan en el navegador (localStorage)
- Capacidad: hasta 5-10 MB
- Aprox 100-500 carnets sin fotos
- Aprox 20-50 carnets con fotos

**Ventajas:**
- ✅ Sin instalación
- ✅ Sin configuración
- ✅ Funciona offline
- ✅ Gratis

**Desventajas:**
- ❌ Solo un usuario
- ❌ Datos por navegador
- ❌ Límite de capacidad

**Backup:**
- Exporta a Excel periódicamente
- Guarda el archivo en lugar seguro

---

### Opción 2: Con Base de Datos

**Bases de datos soportadas:**

1. **MySQL** 8.0+
2. **PostgreSQL** 12+
3. **SQL Server** 2019+
4. **Oracle** 19c+
5. **JD Edwards** EnterpriseOne

**Archivos SQL incluidos:**
- `database/mysql_setup.sql`
- `database/postgresql_setup.sql`
- `database/sqlserver_setup.sql`
- `database/oracle_setup.sql`
- `database/jdedwards_setup.sql`

**Qué incluyen:**
- ✅ Tabla de carnets
- ✅ Índices optimizados
- ✅ Vistas (vigentes, vencidos, alertas)
- ✅ Stored Procedures (CRUD)
- ✅ Triggers de auditoría
- ✅ Datos de ejemplo

---

### Instalación de Base de Datos

#### MySQL

```bash
# Instalar
mysql -u root -p < database/mysql_setup.sql

# Verificar
mysql -u root -p carnets_db
SHOW TABLES;
```

#### PostgreSQL

```bash
# Instalar
psql -U postgres -f database/postgresql_setup.sql

# Verificar
psql -U postgres -d carnets_db
\dt
```

#### SQL Server

```bash
# Instalar
sqlcmd -S localhost -U sa -P password -i database/sqlserver_setup.sql

# Verificar
sqlcmd -S localhost -U sa -P password -d carnets_db -Q "SELECT * FROM carnets"
```

---

### Backend API (Opcional)

**Si usas base de datos, puedes usar el backend:**

```bash
# Instalar dependencias
cd backend
pip install -r requirements.txt

# Configurar
# Editar backend_api.py con tus credenciales de DB

# Ejecutar
python backend_api.py
```

**Endpoints disponibles:**
- `GET /api/carnets` - Listar todos
- `POST /api/carnets` - Crear nuevo
- `GET /api/carnets/<id>` - Obtener uno
- `PUT /api/carnets/<id>` - Actualizar
- `DELETE /api/carnets/<id>` - Eliminar
- `GET /api/carnets/alertas` - Carnets por vencer
- `POST /api/carnets/import-excel` - Importar Excel

**Tecnologías:**
- Python 3.9+
- Flask 3.0.0
- SQLAlchemy 2.0.23
- Pandas 2.1.4
- Flask-CORS 4.0.0

---

## 🚀 Producción y Despliegue

### Para Uso Empresarial

**Requerimientos:**

1. **Servidor web:**
   - Apache, Nginx, IIS
   - HTTPS configurado
   - Certificado SSL válido

2. **Base de datos:**
   - MySQL/PostgreSQL/SQL Server
   - Backup automático diario
   - Réplica recomendada

3. **Backend API:**
   - Servidor Python
   - PM2 o Systemd para mantener activo
   - Logs configurados

4. **Seguridad:**
   - Autenticación de usuarios
   - Restricción por IP/red
   - Auditoría de cambios
   - Encriptación de datos sensibles

---

### Arquitectura Recomendada

```
┌─────────────────┐
│   Navegadores   │ ← Usuarios
│  (Frontend)     │
└────────┬────────┘
         │ HTTPS
         ▼
┌─────────────────┐
│  Nginx/Apache   │ ← Servidor Web
│   (Proxy)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend API    │ ← Python Flask
│  (REST API)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Base de Datos  │ ← MySQL/PostgreSQL
│   (Persistencia)│
└─────────────────┘
```

---

### Checklist de Despliegue

**Antes de producción:**

- [ ] Instalar base de datos
- [ ] Ejecutar script SQL
- [ ] Configurar backend API
- [ ] Probar conexión a DB
- [ ] Configurar HTTPS
- [ ] Implementar autenticación
- [ ] Configurar backups automáticos
- [ ] Restricción de acceso por red
- [ ] Logs de auditoría
- [ ] Testing completo
- [ ] Documentar credenciales
- [ ] Capacitar usuarios
- [ ] Plan de rollback

---

## 🔧 Troubleshooting

### Problemas Comunes

#### ❌ "No puedo cargar el Excel"

**Causas:**
- Archivo con formato incorrecto
- Columnas mal nombradas
- Fechas en formato no válido

**Soluciones:**
1. Usa `template_carnets.xlsx` como referencia
2. Verifica nombres de columnas exactos
3. Fechas en formato DD/MM/YYYY o YYYY-MM-DD
4. Abre consola (F12) para ver error exacto

---

#### ❌ "Los datos desaparecieron"

**Causas:**
- Limpiaste datos del navegador
- Usaste modo incógnito
- Cambiaste de navegador

**Soluciones:**
1. Siempre exporta a Excel como backup
2. No uses modo incógnito para trabajo real
3. Usa el mismo navegador siempre
4. Considera usar base de datos

---

#### ❌ "El botón imprimir no funciona"

**Causas:**
- Librería jsPDF no cargó
- Sin conexión a internet
- JavaScript bloqueado

**Soluciones:**
1. Recarga la página (F5 o Ctrl+F5)
2. Verifica conexión a internet
3. Desactiva bloqueadores de JavaScript
4. Prueba en otro navegador
5. Abre consola (F12) para ver error

---

#### ❌ "Las fotos no se ven"

**Causas:**
- Foto muy pesada
- Formato no soportado
- localStorage lleno

**Soluciones:**
1. Optimiza foto a menos de 200 KB
2. Usa formato JPG o PNG
3. Exporta datos y limpia localStorage
4. Considera usar carpeta local para fotos

---

#### ❌ "El PDF se ve cortado"

**Causas:**
- Demasiados carnets por hoja
- Fotos muy grandes
- Configuración de impresora

**Soluciones:**
1. Reduce carnets por hoja (prueba con 6 en vez de 10)
2. Optimiza fotos
3. Verifica configuración de impresora (escala 100%)
4. Usa botón "10 por Hoja" que está optimizado

---

#### ❌ "No puedo editar un carnet"

**Causas:**
- Navegador desactualizado
- JavaScript con error
- localStorage corrupto

**Soluciones:**
1. Actualiza navegador
2. Recarga página (Ctrl+F5)
3. Exporta datos antes de limpiar
4. Prueba en otro navegador

---

## ❓ FAQ

### Preguntas Generales

**P: ¿Necesito instalar algo?**
R: No, abre `index.html` y funciona. Solo necesitas navegador moderno.

**P: ¿Funciona sin internet?**
R: Sí, una vez abierto funciona completamente offline.

**P: ¿Cuántos carnets puedo guardar?**
R: Sin fotos: ~500 carnets. Con fotos: ~20-50 carnets (depende del tamaño).

**P: ¿Los datos están seguros?**
R: Se guardan solo en tu navegador, no se envían a ningún servidor.

**P: ¿Puedo usar en varios equipos?**
R: Cada navegador tiene sus propios datos. Para compartir, necesitas base de datos.

---

### Preguntas sobre Fotos

**P: ¿Qué formatos de foto acepta?**
R: JPG, JPEG, PNG. Recomendado: JPG optimizado a 100-150 KB.

**P: ¿Puedo agregar foto después de crear el carnet?**
R: Sí, usa el botón "✏️ Editar" y sube la foto.

**P: ¿Cómo elimino una foto?**
R: Edita el carnet y haz clic en "🗑️ Eliminar foto" bajo la foto actual.

**P: ¿Dónde se guardan las fotos?**
R: En Base64 dentro del navegador o en carpeta `fotos/` si eliges esa opción.

---

### Preguntas sobre Impresión

**P: ¿Puedo imprimir sin fotos?**
R: Sí, si no hay foto aparece el emoji 👤.

**P: ¿Qué tamaño tienen los carnets impresos?**
R: Depende de carnets por hoja. Con 10 por hoja: ~8.5×5.5 cm cada uno.

**P: ¿En qué papel imprimo?**
R: Cartulina 200-250 gsm o papel adhesivo para stickers.

**P: ¿Los carnets tienen código QR?**
R: No en esta versión. Está en roadmap futuro.

---

### Preguntas Técnicas

**P: ¿En qué está hecho?**
R: HTML5, CSS3, JavaScript vanilla. Sin frameworks.

**P: ¿Puedo modificar el código?**
R: Sí, todo el código está en `index.html`. Es código abierto para ARCOR.

**P: ¿Funciona con JD Edwards?**
R: Sí, hay script SQL específico en `database/jdedwards_setup.sql`.

**P: ¿Necesito backend?**
R: No para uso básico. Opcional para múltiples usuarios con base de datos.

---

## 📚 Recursos Adicionales

### Archivos de Documentación

- **`README.md`** - Resumen ejecutivo
- **`GUIA_COMPLETA.md`** - Este documento
- **`CAMBIOS_RECIENTES.md`** - Últimas actualizaciones
- **`fotos/LEEME.txt`** - Instrucciones para carpeta fotos

### Archivos Técnicos

- **`DOCS_TECNICAS.md`** - Para desarrolladores
- **`backend/backend_api.py`** - Código de API
- **`database/*.sql`** - Scripts de base de datos

### Plantillas

- **`template_carnets.xlsx`** - Plantilla Excel con ejemplos

---

## 🎓 Mejores Prácticas

### Para Usuarios

1. **Exporta regularmente:** Haz backup mensual exportando a Excel
2. **Optimiza fotos:** Usa TinyPNG antes de subir fotos
3. **Usa el mismo navegador:** No cambies entre navegadores
4. **Revisa alertas:** Verifica semanalmente carnets por vencer
5. **Imprime con calidad:** Usa cartulina y calidad alta

### Para Administradores

1. **Capacita usuarios:** Muestra cómo usar el sistema
2. **Define proceso:** Establece quién renueva carnets
3. **Backup automático:** Configura exportación programada
4. **Monitorea alertas:** Revisa carnets por vencer
5. **Actualiza fotos:** Mantén fotos actualizadas

### Para IT

1. **Considera base de datos:** Para +30 usuarios o múltiples equipos
2. **Implementa HTTPS:** Si despliegas en red
3. **Configura backups:** Backup diario de base de datos
4. **Logs de auditoría:** Rastrea cambios importantes
5. **Plan de desastre:** Procedimiento de recuperación

---

## 🎉 ¡Felicitaciones!

Ahora conoces todo sobre el sistema de carnets ARCOR.

**Próximos pasos:**
1. Prueba con datos de ejemplo
2. Carga tus datos reales
3. Imprime carnets de prueba
4. Implementa en producción

**¿Necesitas ayuda?**
- Revisa la sección [Troubleshooting](#-troubleshooting)
- Consulta el [FAQ](#-faq)
- Contacta al equipo de IT de ARCOR

---

**Sistema de Gestión de Carnets v1.4**
© 2024-2025 ARCOR SAIC - Todos los derechos reservados

**Desarrollado con ❤️ para ARCOR**
