-- MySQL Database Setup
-- Sistema de Gestión de Carnets - ARCOR

CREATE DATABASE IF NOT EXISTS carnets_arcor;
USE carnets_arcor;

-- Tabla principal de carnets
CREATE TABLE carnets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    legajo VARCHAR(50) NOT NULL,
    fecha_calificacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    apto_medico ENUM('Apto', 'No Apto') DEFAULT 'Apto',
    empresa VARCHAR(100) DEFAULT 'ARCOR SAIC',
    tipo_autorizacion VARCHAR(200) DEFAULT 'Autoelevador 2240 Kg',
    resolucion VARCHAR(50) DEFAULT '960/2015',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_dni (dni),
    INDEX idx_apellido (apellido),
    INDEX idx_vencimiento (fecha_vencimiento),
    INDEX idx_legajo (legajo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vista para carnets con estado
CREATE OR REPLACE VIEW v_carnets_estado AS
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

-- Vista para alertas de vencimiento
CREATE OR REPLACE VIEW v_alertas_vencimiento AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CURDATE() THEN 'VENCIDO'
        ELSE 'POR_VENCER'
    END AS tipo_alerta,
    DATEDIFF(c.fecha_vencimiento, CURDATE()) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = TRUE 
  AND (c.fecha_vencimiento < CURDATE() 
       OR DATEDIFF(c.fecha_vencimiento, CURDATE()) <= 30)
ORDER BY c.fecha_vencimiento ASC;

-- Stored Procedure para insertar nuevo carnet
DELIMITER //
CREATE PROCEDURE sp_insertar_carnet(
    IN p_apellido VARCHAR(100),
    IN p_nombre VARCHAR(100),
    IN p_dni VARCHAR(20),
    IN p_legajo VARCHAR(50),
    IN p_fecha_calificacion DATE,
    IN p_fecha_vencimiento DATE,
    IN p_apto_medico VARCHAR(20)
)
BEGIN
    INSERT INTO carnets (
        apellido, nombre, dni, legajo, 
        fecha_calificacion, fecha_vencimiento, apto_medico
    ) VALUES (
        p_apellido, p_nombre, p_dni, p_legajo,
        p_fecha_calificacion, p_fecha_vencimiento, p_apto_medico
    );
    
    SELECT LAST_INSERT_ID() as carnet_id;
END //
DELIMITER ;

-- Stored Procedure para actualizar carnet
DELIMITER //
CREATE PROCEDURE sp_actualizar_carnet(
    IN p_id INT,
    IN p_apellido VARCHAR(100),
    IN p_nombre VARCHAR(100),
    IN p_dni VARCHAR(20),
    IN p_legajo VARCHAR(50),
    IN p_fecha_calificacion DATE,
    IN p_fecha_vencimiento DATE,
    IN p_apto_medico VARCHAR(20)
)
BEGIN
    UPDATE carnets 
    SET apellido = p_apellido,
        nombre = p_nombre,
        dni = p_dni,
        legajo = p_legajo,
        fecha_calificacion = p_fecha_calificacion,
        fecha_vencimiento = p_fecha_vencimiento,
        apto_medico = p_apto_medico
    WHERE id = p_id AND activo = TRUE;
END //
DELIMITER ;

-- Stored Procedure para obtener estadísticas
DELIMITER //
CREATE PROCEDURE sp_obtener_estadisticas()
BEGIN
    SELECT 
        COUNT(*) as total_carnets,
        SUM(CASE WHEN fecha_vencimiento >= CURDATE() 
                  AND DATEDIFF(fecha_vencimiento, CURDATE()) > 30 
            THEN 1 ELSE 0 END) as vigentes,
        SUM(CASE WHEN fecha_vencimiento >= CURDATE() 
                  AND DATEDIFF(fecha_vencimiento, CURDATE()) <= 30 
            THEN 1 ELSE 0 END) as por_vencer,
        SUM(CASE WHEN fecha_vencimiento < CURDATE() 
            THEN 1 ELSE 0 END) as vencidos
    FROM carnets
    WHERE activo = TRUE;
END //
DELIMITER ;

-- Datos de ejemplo
INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) VALUES
('GONZALEZ', 'JUAN', '28567123', '1001', '2024-11-30', '2025-11-29', 'Apto'),
('MARTINEZ', 'CARLOS', '32456789', '1002', '2024-12-15', '2025-12-14', 'Apto'),
('RODRIGUEZ', 'MARIA', '35123456', '1003', '2023-06-20', '2024-06-19', 'Apto');
