-- SQL Server Database Setup
-- Sistema de Gestión de Carnets - ARCOR

CREATE DATABASE carnets_arcor;
GO

USE carnets_arcor;
GO

-- Tabla principal de carnets
CREATE TABLE carnets (
    id INT IDENTITY(1,1) PRIMARY KEY,
    apellido NVARCHAR(100) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    dni NVARCHAR(20) NOT NULL UNIQUE,
    legajo NVARCHAR(50) NOT NULL,
    fecha_calificacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    apto_medico NVARCHAR(20) NOT NULL DEFAULT 'Apto',
    empresa NVARCHAR(100) DEFAULT 'ARCOR SAIC',
    tipo_autorizacion NVARCHAR(200) DEFAULT 'Autoelevador 2240 Kg',
    resolucion NVARCHAR(50) DEFAULT '960/2015',
    fecha_creacion DATETIME2 DEFAULT GETDATE(),
    fecha_actualizacion DATETIME2 DEFAULT GETDATE(),
    activo BIT DEFAULT 1,
    CONSTRAINT CHK_apto_medico CHECK (apto_medico IN ('Apto', 'No Apto'))
);
GO

-- Índices
CREATE INDEX idx_carnets_dni ON carnets(dni);
CREATE INDEX idx_carnets_apellido ON carnets(apellido);
CREATE INDEX idx_carnets_vencimiento ON carnets(fecha_vencimiento);
CREATE INDEX idx_carnets_legajo ON carnets(legajo);
GO

-- Trigger para actualizar fecha_actualizacion
CREATE TRIGGER trg_carnets_actualizacion
ON carnets
AFTER UPDATE
AS
BEGIN
    UPDATE carnets
    SET fecha_actualizacion = GETDATE()
    FROM carnets c
    INNER JOIN inserted i ON c.id = i.id;
END;
GO

-- Vista para carnets con estado
CREATE VIEW v_carnets_estado AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CAST(GETDATE() AS DATE) THEN 'VENCIDO'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.fecha_vencimiento) <= 30 THEN 'POR_VENCER'
        ELSE 'VIGENTE'
    END AS estado,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.fecha_vencimiento) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = 1;
GO

-- Vista para alertas de vencimiento
CREATE VIEW v_alertas_vencimiento AS
SELECT 
    c.*,
    CASE 
        WHEN c.fecha_vencimiento < CAST(GETDATE() AS DATE) THEN 'VENCIDO'
        ELSE 'POR_VENCER'
    END AS tipo_alerta,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.fecha_vencimiento) AS dias_hasta_vencimiento
FROM carnets c
WHERE c.activo = 1 
  AND (c.fecha_vencimiento < CAST(GETDATE() AS DATE) 
       OR DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.fecha_vencimiento) <= 30);
GO

-- Stored Procedure para insertar nuevo carnet
CREATE PROCEDURE sp_insertar_carnet
    @apellido NVARCHAR(100),
    @nombre NVARCHAR(100),
    @dni NVARCHAR(20),
    @legajo NVARCHAR(50),
    @fecha_calificacion DATE,
    @fecha_vencimiento DATE,
    @apto_medico NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO carnets (
        apellido, nombre, dni, legajo, 
        fecha_calificacion, fecha_vencimiento, apto_medico
    ) VALUES (
        @apellido, @nombre, @dni, @legajo,
        @fecha_calificacion, @fecha_vencimiento, @apto_medico
    );
    
    SELECT SCOPE_IDENTITY() as carnet_id;
END;
GO

-- Stored Procedure para actualizar carnet
CREATE PROCEDURE sp_actualizar_carnet
    @id INT,
    @apellido NVARCHAR(100),
    @nombre NVARCHAR(100),
    @dni NVARCHAR(20),
    @legajo NVARCHAR(50),
    @fecha_calificacion DATE,
    @fecha_vencimiento DATE,
    @apto_medico NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE carnets 
    SET apellido = @apellido,
        nombre = @nombre,
        dni = @dni,
        legajo = @legajo,
        fecha_calificacion = @fecha_calificacion,
        fecha_vencimiento = @fecha_vencimiento,
        apto_medico = @apto_medico
    WHERE id = @id AND activo = 1;
END;
GO

-- Stored Procedure para obtener estadísticas
CREATE PROCEDURE sp_obtener_estadisticas
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(*) as total_carnets,
        SUM(CASE WHEN fecha_vencimiento >= CAST(GETDATE() AS DATE) 
                      AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), fecha_vencimiento) > 30 
                THEN 1 ELSE 0 END) as vigentes,
        SUM(CASE WHEN fecha_vencimiento >= CAST(GETDATE() AS DATE) 
                      AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), fecha_vencimiento) <= 30 
                THEN 1 ELSE 0 END) as por_vencer,
        SUM(CASE WHEN fecha_vencimiento < CAST(GETDATE() AS DATE) 
                THEN 1 ELSE 0 END) as vencidos
    FROM carnets
    WHERE activo = 1;
END;
GO

-- Datos de ejemplo
INSERT INTO carnets (apellido, nombre, dni, legajo, fecha_calificacion, fecha_vencimiento, apto_medico) VALUES
('GONZALEZ', 'JUAN', '28567123', '1001', '2024-11-30', '2025-11-29', 'Apto'),
('MARTINEZ', 'CARLOS', '32456789', '1002', '2024-12-15', '2025-12-14', 'Apto'),
('RODRIGUEZ', 'MARIA', '35123456', '1003', '2023-06-20', '2024-06-19', 'Apto');
GO
