-- PostgreSQL Database Setup
-- Sistema de Gestión de Carnets - ARCOR

CREATE DATABASE carnets_arcor;
\c carnets_arcor;

-- Tipo ENUM para apto médico
CREATE TYPE tipo_apto AS ENUM ('Apto', 'No Apto');

-- Tabla principal de carnets
CREATE TABLE carnets (
    id SERIAL PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    legajo VARCHAR(50) NOT NULL,
    fecha_calificacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    apto_medico tipo_apto DEFAULT 'Apto',
    empresa VARCHAR(100) DEFAULT 'ARCOR SAIC',
    tipo_autorizacion VARCHAR(200) DEFAULT 'Autoelevador 2240 Kg',
    resolucion VARCHAR(50) DEFAULT '960/2015',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- Índices
CREATE INDEX idx_carnets_dni ON carnets(dni);
CREATE INDEX idx_carnets_apellido ON carnets(apellido);
CREATE INDEX idx_carnets_vencimiento ON carnets(fecha_vencimiento);
CREATE INDEX idx_carnets_legajo ON carnets(legajo);

-- Trigger para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_carnets_actualizacion
    BEFORE UPDATE ON carnets
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Vista para carnets con estado
CREATE OR REPLACE VIEW v_carnets_estado AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CURRENT_DATE THEN 'VENCIDO'
        WHEN (c.fecha_vencimiento - CURRENT_DATE) <= 30 THEN 'POR_VENCER'
        ELSE 'VIGENTE'
    END AS estado,
    (c.fecha_vencimiento - CURRENT_DATE) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = TRUE;

-- Vista para alertas de vencimiento
CREATE OR REPLACE VIEW v_alertas_vencimiento AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CURRENT_DATE THEN 'VENCIDO'
        ELSE 'POR_VENCER'
    END AS tipo_alerta,
    (c.fecha_vencimiento - CURRENT_DATE) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = TRUE 
  AND (c.fecha_vencimiento < CURRENT_DATE 
       OR (c.fecha_vencimiento - CURRENT_DATE) <= 30)
ORDER BY c.fecha_vencimiento ASC;

-- Función para insertar nuevo carnet
CREATE OR REPLACE FUNCTION f_insertar_carnet(
    p_apellido VARCHAR(100),
    p_nombre VARCHAR(100),
    p_dni VARCHAR(20),
    p_legajo VARCHAR(50),
    p_fecha_calificacion DATE,
    p_fecha_vencimiento DATE,
    p_apto_medico VARCHAR(20)
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO carnets (
        apellido, nombre, dni, legajo, 
        fecha_calificacion, fecha_vencimiento, apto_medico
    ) VALUES (
        p_apellido, p_nombre, p_dni, p_legajo,
        p_fecha_calificacion, p_fecha_vencimiento, p_apto_medico::tipo_apto
    )
    RETURNING id INTO v_id;
    
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar carnet
CREATE OR REPLACE FUNCTION f_actualizar_carnet(
    p_id INTEGER,
    p_apellido VARCHAR(100),
    p_nombre VARCHAR(100),
    p_dni VARCHAR(20),
    p_legajo VARCHAR(50),
    p_fecha_calificacion DATE,
    p_fecha_vencimiento DATE,
    p_apto_medico VARCHAR(20)
)
RETURNS VOID AS $$
BEGIN
    UPDATE carnets 
    SET apellido = p_apellido,
        nombre = p_nombre,
        dni = p_dni,
        legajo = p_legajo,
        fecha_calificacion = p_fecha_calificacion,
        fecha_vencimiento = p_fecha_vencimiento,
        apto_medico = p_apto_medico::tipo_apto
    WHERE id = p_id AND activo = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener estadísticas
CREATE OR REPLACE FUNCTION f_obtener_estadisticas()
RETURNS TABLE (
    total_carnets BIGINT,
    vigentes BIGINT,
    por_vencer BIGINT,
    vencidos BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_carnets,
        COUNT(*) FILTER (WHERE fecha_vencimiento >= CURRENT_DATE 
                         AND (fecha_vencimiento - CURRENT_DATE) > 30) as vigentes,
        COUNT(*) FILTER (WHERE fecha_vencimiento >= CURRENT_DATE 
                         AND (fecha_vencimiento - CURRENT_DATE) <= 30) as por_vencer,
        COUNT(*) FILTER (WHERE fecha_vencimiento < CURRENT_DATE) as vencidos
    FROM carnets
    WHERE activo = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Datos de ejemplo
INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) VALUES
('GONZALEZ', 'JUAN', '28567123', '1001', '2024-11-30', '2025-11-29', 'Apto'),
('MARTINEZ', 'CARLOS', '32456789', '1002', '2024-12-15', '2025-12-14', 'Apto'),
('RODRIGUEZ', 'MARIA', '35123456', '1003', '2023-06-20', '2024-06-19', 'Apto');
