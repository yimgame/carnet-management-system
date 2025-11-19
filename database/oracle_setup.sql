-- Oracle Database Setup
-- Sistema de Gestión de Carnets - ARCOR

-- Crear secuencia para IDs
CREATE SEQUENCE seq_carnets_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Tabla principal de carnets
CREATE TABLE carnets (
    id NUMBER(10) PRIMARY KEY,
    apellido VARCHAR2(100) NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    dni VARCHAR2(20) NOT NULL UNIQUE,
    legajo VARCHAR2(50) NOT NULL,
    fecha_calificacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    apto_medico VARCHAR2(20) DEFAULT 'Apto' NOT NULL,
    empresa VARCHAR2(100) DEFAULT 'ARCOR SAIC',
    tipo_autorizacion VARCHAR2(200) DEFAULT 'Autoelevador 2240 Kg',
    resolucion VARCHAR2(50) DEFAULT '960/2015',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo NUMBER(1) DEFAULT 1,
    CONSTRAINT CHK_apto_medico CHECK (apto_medico IN ('Apto', 'No Apto')),
    CONSTRAINT CHK_activo CHECK (activo IN (0, 1))
);

-- Índices
CREATE INDEX idx_carnets_dni ON carnets(dni);
CREATE INDEX idx_carnets_apellido ON carnets(apellido);
CREATE INDEX idx_carnets_vencimiento ON carnets(fecha_vencimiento);
CREATE INDEX idx_carnets_legajo ON carnets(legajo);

-- Trigger para auto-incrementar ID
CREATE OR REPLACE TRIGGER trg_carnets_id
BEFORE INSERT ON carnets
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT seq_carnets_id.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- Trigger para actualizar fecha_actualizacion
CREATE OR REPLACE TRIGGER trg_carnets_actualizacion
BEFORE UPDATE ON carnets
FOR EACH ROW
BEGIN
    :NEW.fecha_actualizacion := CURRENT_TIMESTAMP;
END;
/

-- Vista para carnets con estado
CREATE OR REPLACE VIEW v_carnets_estado AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < TRUNC(SYSDATE) THEN 'VENCIDO'
        WHEN (c.fecha_vencimiento - TRUNC(SYSDATE)) <= 30 THEN 'POR_VENCER'
        ELSE 'VIGENTE'
    END AS estado,
    (c.fecha_vencimiento - TRUNC(SYSDATE)) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = 1;

-- Vista para alertas de vencimiento
CREATE OR REPLACE VIEW v_alertas_vencimiento AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < TRUNC(SYSDATE) THEN 'VENCIDO'
        ELSE 'POR_VENCER'
    END AS tipo_alerta,
    (c.fecha_vencimiento - TRUNC(SYSDATE)) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = 1 
  AND (c.fecha_vencimiento < TRUNC(SYSDATE) 
       OR (c.fecha_vencimiento - TRUNC(SYSDATE)) <= 30)
ORDER BY c.fecha_vencimiento ASC;

-- Procedimiento para insertar nuevo carnet
CREATE OR REPLACE PROCEDURE sp_insertar_carnet (
    p_apellido IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_dni IN VARCHAR2,
    p_legajo IN VARCHAR2,
    p_fecha_calificacion IN DATE,
    p_fecha_vencimiento IN DATE,
    p_apto_medico IN VARCHAR2,
    p_carnet_id OUT NUMBER
)
AS
BEGIN
    INSERT INTO carnets (
        apellido, nombre, dni, legajo, 
        fecha_calificacion, fecha_vencimiento, apto_medico
    ) VALUES (
        p_apellido, p_nombre, p_dni, p_legajo,
        p_fecha_calificacion, p_fecha_vencimiento, p_apto_medico
    )
    RETURNING id INTO p_carnet_id;
    
    COMMIT;
END;
/

-- Procedimiento para actualizar carnet
CREATE OR REPLACE PROCEDURE sp_actualizar_carnet (
    p_id IN NUMBER,
    p_apellido IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_dni IN VARCHAR2,
    p_legajo IN VARCHAR2,
    p_fecha_calificacion IN DATE,
    p_fecha_vencimiento IN DATE,
    p_apto_medico IN VARCHAR2
)
AS
BEGIN
    UPDATE carnets 
    SET apellido = p_apellido,
        nombre = p_nombre,
        dni = p_dni,
        legajo = p_legajo,
        fecha_calificacion = p_fecha_calificacion,
        fecha_vencimiento = p_fecha_vencimiento,
        apto_medico = p_apto_medico
    WHERE id = p_id AND activo = 1;
    
    COMMIT;
END;
/

-- Procedimiento para obtener estadísticas
CREATE OR REPLACE PROCEDURE sp_obtener_estadisticas (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        COUNT(*) as total_carnets,
        SUM(CASE WHEN fecha_vencimiento >= TRUNC(SYSDATE) 
                      AND (fecha_vencimiento - TRUNC(SYSDATE)) > 30 
                THEN 1 ELSE 0 END) as vigentes,
        SUM(CASE WHEN fecha_vencimiento >= TRUNC(SYSDATE) 
                      AND (fecha_vencimiento - TRUNC(SYSDATE)) <= 30 
                THEN 1 ELSE 0 END) as por_vencer,
        SUM(CASE WHEN fecha_vencimiento < TRUNC(SYSDATE) 
                THEN 1 ELSE 0 END) as vencidos
    FROM carnets
    WHERE activo = 1;
END;
/

-- Datos de ejemplo
INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) 
VALUES ('GONZALEZ', 'JUAN', '28567123', '1001', TO_DATE('2024-11-30', 'YYYY-MM-DD'), TO_DATE('2025-11-29', 'YYYY-MM-DD'), 'Apto');

INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) 
VALUES ('MARTINEZ', 'CARLOS', '32456789', '1002', TO_DATE('2024-12-15', 'YYYY-MM-DD'), TO_DATE('2025-12-14', 'YYYY-MM-DD'), 'Apto');

INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) 
VALUES ('RODRIGUEZ', 'MARIA', '35123456', '1003', TO_DATE('2023-06-20', 'YYYY-MM-DD'), TO_DATE('2024-06-19', 'YYYY-MM-DD'), 'Apto');

COMMIT;
