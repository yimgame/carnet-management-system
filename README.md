# 🚗 Sistema de Gestión de Carnets

**Sistema web completo para gestionar carnets de conducir de autoelevadores con alertas automáticas de vencimiento**

[![Versión](https://img.shields.io/badge/versión-1.4-blue.svg)](CAMBIOS_RECIENTES.md)
[![Última actualización](https://img.shields.io/badge/actualización-Nov%202025-green.svg)](CAMBIOS_RECIENTES.md)
[![Documentación](https://img.shields.io/badge/docs-completa-brightgreen.svg)](GUIA_COMPLETA.md)

---

## ✨ Características Principales

- ✅ **Dashboard interactivo** con estadísticas en tiempo real
- ⚠️ **Alertas automáticas** de vencimientos (30 días de anticipación)
- 📂 **Carga masiva** desde archivos Excel
- ✏️ **Edición completa** de carnets y fotos
- 🖨️ **Impresión profesional** con diseño oficial
- 📸 **Gestión de fotos** (Base64 o carpeta local)
- 🔍 **Búsqueda y filtrado** avanzado
- 💾 **Exportación** a Excel
- 🗄️ **5 bases de datos** soportadas (MySQL, PostgreSQL, SQL Server, Oracle, JD Edwards)

## 🚀 Inicio Rápido (3 pasos)

1. **Abrir** `index.html` en tu navegador
2. **Cargar** el archivo `template_carnets.xlsx` de ejemplo
3. **¡Listo!** Ya puedes gestionar carnets

### 🎯 Acciones Principales

| Acción | Botón | Descripción |
|--------|-------|-------------|
| Cargar datos | 📂 Cargar Excel | Importar múltiples carnets desde Excel |
| Nuevo carnet | ➕ Nuevo Carnet | Agregar carnet con foto |
| Editar | ✏️ Editar | Modificar datos y foto de carnet existente |
| Imprimir rápido | 🖨️ 10 por Hoja | Imprimir todos los carnets (10 por A4) |
| Configurar impresión | 🖨️ Configurar | Personalizar cantidad y filtros |
| Exportar | 💾 Exportar Datos | Descargar todo a Excel |

## 📊 Formato del Excel

El archivo Excel debe contener las siguientes columnas:

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| Apellido | Apellido del conductor | GONZALEZ |
| Nombre | Nombre del conductor | JUAN |
| DNI | Documento de identidad | 28567123 |
| Legajo | Número de legajo | 1001 |
| Fecha_Calificacion | Fecha de calificación | 30/11/2024 |
| Fecha_Vencimiento | Fecha de vencimiento | 29/11/2025 |
| Apto_Medico | Estado del apto médico | Apto |

## 🗄️ Migración a Base de Datos

El sistema incluye scripts SQL para migrar a bases de datos empresariales:

### Bases de datos soportadas:

1. **MySQL** → `database/mysql_setup.sql`
2. **PostgreSQL** → `database/postgresql_setup.sql`
3. **SQL Server** → `database/sqlserver_setup.sql`
4. **Oracle** → `database/oracle_setup.sql`
5. **JD Edwards EnterpriseOne** → `database/jdedwards_setup.sql`

### Instalación en MySQL:

```bash
mysql -u root -p < database/mysql_setup.sql
```

### Instalación en PostgreSQL:

```bash
psql -U postgres -f database/postgresql_setup.sql
```

### Instalación en SQL Server:

```bash
sqlcmd -S localhost -U sa -P password -i database/sqlserver_setup.sql
```

### Instalación en Oracle:

```bash
sqlplus usuario/password@database @database/oracle_setup.sql
```

### Instalación en JD Edwards:

Ver instrucciones detalladas en el archivo `database/jdedwards_setup.sql`

## 🎯 Características de las Bases de Datos

Todos los scripts SQL incluyen:

- ✅ Tabla principal de carnets con índices optimizados
- ✅ Vistas para carnets con estado (VIGENTE/POR_VENCER/VENCIDO)
- ✅ Vista de alertas de vencimiento
- ✅ Stored Procedures para operaciones CRUD
- ✅ Triggers para auditoría
- ✅ Datos de ejemplo para testing

### Especial: JD Edwards EnterpriseOne

El script de JD Edwards incluye:

- ✅ Tabla custom F55CARN siguiendo estándares JDE
- ✅ Campos de control estándar de JDE (SYEDUS, SYEDUP, etc.)
- ✅ Formato de fechas Julian (CYYDDD)
- ✅ Business Functions (BSFN) personalizadas
- ✅ Funciones de conversión de fechas
- ✅ Instrucciones completas para implementación en OMW

## 📱 Funcionalidades del Sistema Web

### Dashboard Principal

- Contador de carnets totales
- Carnets vigentes
- Carnets por vencer (próximos 30 días)
- Carnets vencidos

### Alertas Visuales

- 🔴 **Rojo**: Carnets vencidos (requieren acción inmediata)
- 🟡 **Amarillo**: Carnets por vencer en los próximos 30 días
- 🟢 **Verde**: Carnets vigentes

### Búsqueda y Filtros

- Búsqueda por nombre, apellido o DNI
- Filtro por estado (Todos/Vigentes/Por vencer/Vencidos)
- Actualización en tiempo real

### Exportación

- Exportar todos los datos a Excel
- Incluye columna de estado calculado
- Nombre de archivo con fecha automática

## 📚 Documentación

| Documento | Descripción | Cuándo usar |
|-----------|-------------|-------------|
| **[GUIA_COMPLETA.md](GUIA_COMPLETA.md)** | 📖 Guía detallada de todo el sistema | Para aprender a fondo |
| **[CAMBIOS_RECIENTES.md](CAMBIOS_RECIENTES.md)** | 🆕 Últimas actualizaciones y mejoras | Para ver novedades |
| **[fotos/LEEME.txt](fotos/LEEME.txt)** | 📸 Instrucciones para gestión de fotos | Para organizar fotos |

### 🎓 Guías por Tema

- **Uso básico** → [GUIA_COMPLETA.md - Cómo Usar](GUIA_COMPLETA.md#-cómo-usar-el-sistema)
- **Gestión de fotos** → [GUIA_COMPLETA.md - Fotos](GUIA_COMPLETA.md#-gestión-de-fotos)
- **Impresión** → [GUIA_COMPLETA.md - Impresión](GUIA_COMPLETA.md#️-impresión-de-carnets)
- **Base de datos** → [GUIA_COMPLETA.md - Base de Datos](GUIA_COMPLETA.md#-base-de-datos)
- **Problemas** → [GUIA_COMPLETA.md - Troubleshooting](GUIA_COMPLETA.md#-troubleshooting)
- **FAQ** → [GUIA_COMPLETA.md - FAQ](GUIA_COMPLETA.md#-faq)

---

## 🔧 Tecnologías

**Frontend:** HTML5, CSS3, JavaScript ES6+, SheetJS (xlsx.js), jsPDF  
**Backend (opcional):** Python 3.9+, Flask, SQLAlchemy, Pandas  
**Bases de datos:** MySQL, PostgreSQL, SQL Server, Oracle, JD Edwards

---

## 📦 Estructura del Proyecto

```
carnets/
├── index.html                    # ⭐ Aplicación principal
├── template_carnets.xlsx         # 📋 Plantilla Excel
├── GUIA_COMPLETA.md             # 📖 Documentación completa
├── CAMBIOS_RECIENTES.md         # 🆕 Novedades
├── README.md                    # 📄 Este archivo
├── fotos/                       # 📸 Carpeta para fotos
│   └── LEEME.txt               # Instrucciones
├── database/                    # 🗄️ Scripts SQL
│   ├── mysql_setup.sql
│   ├── postgresql_setup.sql
│   ├── sqlserver_setup.sql
│   ├── oracle_setup.sql
│   └── jdedwards_setup.sql
└── backend/                     # 🔧 API opcional
    ├── backend_api.py
    └── requirements.txt
```

---

## 🆕 Novedades v1.4 (Nov 2025)

- ✅ **Editar carnets** existentes (datos y fotos)
- ✅ **Eliminar carnets** con confirmación
- ✅ **Gestión de fotos** mejorada (Base64 o carpeta local)
- ✅ **Impresión masiva** con botón rápido "10 por Hoja"
- ✅ **Diseño mejorado** coincide con imagen oficial
- ✅ **Documentación unificada** en GUIA_COMPLETA.md

Ver todos los cambios en [CAMBIOS_RECIENTES.md](CAMBIOS_RECIENTES.md)

---

## ❓ FAQ Rápido

**P: ¿Necesito instalar algo?**  
R: No, solo abre `index.html` en tu navegador.

**P: ¿Funciona sin internet?**  
R: Sí, completamente offline una vez abierto.

**P: ¿Los datos están seguros?**  
R: Se guardan solo en tu navegador, no se envían a ningún servidor.

**P: ¿Cuántos carnets puedo tener?**  
R: ~500 sin fotos, ~20-50 con fotos (depende del tamaño).

**P: ¿Puedo usar en varios equipos?**  
R: Cada navegador tiene sus datos. Para compartir, usa base de datos.

**P: ¿Cómo agrego fotos?**  
R: Al crear/editar carnet, campo "Foto del Conductor".

**P: ¿Cómo imprimo carnets?**  
R: Botón "🖨️ 10 por Hoja" para impresión rápida.

Más preguntas: [GUIA_COMPLETA.md - FAQ](GUIA_COMPLETA.md#-faq)

---

## 📞 Soporte

- **Documentación completa:** [GUIA_COMPLETA.md](GUIA_COMPLETA.md)
- **Problemas comunes:** [Troubleshooting](GUIA_COMPLETA.md#-troubleshooting)
- **Preguntas frecuentes:** [FAQ](GUIA_COMPLETA.md#-faq)
- **Contacto IT:** Equipo de IT

---

**Desarrollado para ARCOR SAIC** - Sistema de Gestión de Carnets de Conducir
