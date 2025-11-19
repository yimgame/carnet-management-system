-- JD Edwards EnterpriseOne Database Setup
-- Sistema de Gestión de Carnets - ARCOR
-- Compatible con Oracle/SQL Server según implementación de JDE

/*
NOTAS IMPORTANTES PARA JD EDWARDS:
- JDE utiliza prefijos de tabla según el sistema (F para archivos maestros)
- Los campos siguen convenciones de naming de JDE
- Se recomienda crear tabla custom con prefijo F55 (para desarrollo custom)
- Data dictionary items deben crearse en OMW (Object Management Workbench)
*/

-- Tabla custom siguiendo estándares JDE
-- Prefijo F55 para aplicaciones custom
CREATE TABLE F55CARN (
    -- Campos de control JDE estándar
    SYEDUS VARCHAR2(10),          -- User ID
    SYEDUP VARCHAR2(10),          -- Program ID  
    SYEDBT VARCHAR2(10),          -- User ID - Last Updated
    SYEDSP VARCHAR2(10),          -- Program ID - Last Updated
    SYUPMJ NUMBER(6),             -- Date - Updated (Julian)
    SYUPMT NUMBER(6),             -- Time - Updated
    SYEDCT NUMBER(6),             -- Date - Created (Julian)
    SYEDIT NUMBER(6),             -- Time - Created
    
    -- Campos específicos del carnet
    C5CRID NUMBER(10) PRIMARY KEY, -- ID Carnet (Custom ID)
    C5APEL VARCHAR2(100),         -- Apellido
    C5NOMB VARCHAR2(100),         -- Nombre
    C5DNI VARCHAR2(20) UNIQUE,    -- DNI
    C5LEGA VARCHAR2(50),          -- Legajo
    C5FCAL NUMBER(6),             -- Fecha Calificación (Julian)
    C5FVEN NUMBER(6),             -- Fecha Vencimiento (Julian)
    C5APTM VARCHAR2(2),           -- Apto Médico (AT=Apto, NA=No Apto)
    C5EMPR VARCHAR2(100),         -- Empresa
    C5TAUT VARCHAR2(200),         -- Tipo Autorización
    C5RESO VARCHAR2(50),          -- Resolución
    C5ACTV VARCHAR2(1) DEFAULT 'Y' -- Activo (Y/N)
);

-- Índices siguiendo estándares JDE
CREATE INDEX F55CARN_1 ON F55CARN(C5DNI);
CREATE INDEX F55CARN_2 ON F55CARN(C5APEL);
CREATE INDEX F55CARN_3 ON F55CARN(C5FVEN);
CREATE INDEX F55CARN_4 ON F55CARN(C5LEGA);

-- Secuencia para IDs
CREATE SEQUENCE SEQ_F55CARN
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Función para convertir fecha Gregoriana a Juliana (formato JDE)
-- JDE usa formato CYYDDD donde C=siglo, YY=año, DDD=día del año
CREATE OR REPLACE FUNCTION fn_fecha_a_julian(p_fecha DATE)
RETURN NUMBER
IS
    v_julian NUMBER(6);
    v_year NUMBER(4);
    v_day_of_year NUMBER(3);
BEGIN
    v_year := TO_NUMBER(TO_CHAR(p_fecha, 'YYYY'));
    v_day_of_year := TO_NUMBER(TO_CHAR(p_fecha, 'DDD'));
    
    -- Formato: 1YYDDD (1 para siglo 2000+)
    v_julian := 100000 + ((v_year - 2000) * 1000) + v_day_of_year;
    
    RETURN v_julian;
END;
/

-- Función para convertir fecha Juliana a Gregoriana
CREATE OR REPLACE FUNCTION fn_julian_a_fecha(p_julian NUMBER)
RETURN DATE
IS
    v_year NUMBER(4);
    v_day_of_year NUMBER(3);
    v_fecha DATE;
BEGIN
    -- Extraer año y día del formato CYYDDD
    v_year := 2000 + FLOOR((p_julian - 100000) / 1000);
    v_day_of_year := MOD(p_julian, 1000);
    
    -- Construir fecha
    v_fecha := TO_DATE(v_year || '-' || LPAD(v_day_of_year, 3, '0'), 'YYYY-DDD');
    
    RETURN v_fecha;
END;
/

-- Vista para carnets con estado (compatible JDE)
CREATE OR REPLACE VIEW V55CARN_ESTADO AS
SELECT 
    c.*,
    fn_julian_a_fecha(c.C5FCAL) as FECHA_CALIFICACION,
    fn_julian_a_fecha(c.C5FVEN) as FECHA_VENCIMIENTO,
    CASE 
        WHEN fn_julian_a_fecha(c.C5FVEN) < TRUNC(SYSDATE) THEN 'VENCIDO'
        WHEN (fn_julian_a_fecha(c.C5FVEN) - TRUNC(SYSDATE)) <= 30 THEN 'POR_VENCER'
        ELSE 'VIGENTE'
    END AS ESTADO,
    (fn_julian_a_fecha(c.C5FVEN) - TRUNC(SYSDATE)) AS DIAS_VENCIMIENTO
FROM F55CARN c
WHERE c.C5ACTV = 'Y';

-- Vista para alertas siguiendo estándares JDE
CREATE OR REPLACE VIEW V55CARN_ALERTA AS
SELECT 
    c.*,
    fn_julian_a_fecha(c.C5FCAL) as FECHA_CALIFICACION,
    fn_julian_a_fecha(c.C5FVEN) as FECHA_VENCIMIENTO,
    CASE 
        WHEN fn_julian_a_fecha(c.C5FVEN) < TRUNC(SYSDATE) THEN 'VENCIDO'
        ELSE 'POR_VENCER'
    END AS TIPO_ALERTA,
    (fn_julian_a_fecha(c.C5FVEN) - TRUNC(SYSDATE)) AS DIAS_VENCIMIENTO
FROM F55CARN c
WHERE c.C5ACTV = 'Y' 
  AND (fn_julian_a_fecha(c.C5FVEN) < TRUNC(SYSDATE) 
       OR (fn_julian_a_fecha(c.C5FVEN) - TRUNC(SYSDATE)) <= 30)
ORDER BY c.C5FVEN ASC;

-- Business Function: Insertar Carnet (siguiendo estándares BSFN de JDE)
CREATE OR REPLACE PROCEDURE B55CARN_INSERT (
    p_apellido IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_dni IN VARCHAR2,
    p_legajo IN VARCHAR2,
    p_fecha_calificacion IN DATE,
    p_fecha_vencimiento IN DATE,
    p_apto_medico IN VARCHAR2,
    p_user_id IN VARCHAR2 DEFAULT 'JDE',
    p_program_id IN VARCHAR2 DEFAULT 'P55CARN',
    p_carnet_id OUT NUMBER
)
AS
    v_julian_cal NUMBER(6);
    v_julian_ven NUMBER(6);
    v_apto_code VARCHAR2(2);
    v_fecha_julian NUMBER(6);
    v_time NUMBER(6);
BEGIN
    -- Convertir fechas a formato Julian JDE
    v_julian_cal := fn_fecha_a_julian(p_fecha_calificacion);
    v_julian_ven := fn_fecha_a_julian(p_fecha_vencimiento);
    
    -- Convertir apto médico a código JDE
    v_apto_code := CASE WHEN p_apto_medico = 'Apto' THEN 'AT' ELSE 'NA' END;
    
    -- Obtener fecha/hora actual en formato JDE
    v_fecha_julian := fn_fecha_a_julian(SYSDATE);
    v_time := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24MISS'));
    
    -- Obtener siguiente ID
    SELECT SEQ_F55CARN.NEXTVAL INTO p_carnet_id FROM DUAL;
    
    INSERT INTO F55CARN (
        C5CRID, C5APEL, C5NOMB, C5DNI, C5LEGA,
        C5FCAL, C5FVEN, C5APTM, C5EMPR, C5TAUT, C5RESO,
        SYEDUS, SYEDUP, SYEDBT, SYEDSP,
        SYUPMJ, SYUPMT, SYEDCT, SYEDIT, C5ACTV
    ) VALUES (
        p_carnet_id, p_apellido, p_nombre, p_dni, p_legajo,
        v_julian_cal, v_julian_ven, v_apto_code, 
        'ARCOR SAIC', 'Autoelevador 2240 Kg', '960/2015',
        p_user_id, p_program_id, p_user_id, p_program_id,
        v_fecha_julian, v_time, v_fecha_julian, v_time, 'Y'
    );
    
    COMMIT;
END;
/

-- Business Function: Actualizar Carnet
CREATE OR REPLACE PROCEDURE B55CARN_UPDATE (
    p_id IN NUMBER,
    p_apellido IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_dni IN VARCHAR2,
    p_legajo IN VARCHAR2,
    p_fecha_calificacion IN DATE,
    p_fecha_vencimiento IN DATE,
    p_apto_medico IN VARCHAR2,
    p_user_id IN VARCHAR2 DEFAULT 'JDE',
    p_program_id IN VARCHAR2 DEFAULT 'P55CARN'
)
AS
    v_julian_cal NUMBER(6);
    v_julian_ven NUMBER(6);
    v_apto_code VARCHAR2(2);
    v_fecha_julian NUMBER(6);
    v_time NUMBER(6);
BEGIN
    v_julian_cal := fn_fecha_a_julian(p_fecha_calificacion);
    v_julian_ven := fn_fecha_a_julian(p_fecha_vencimiento);
    v_apto_code := CASE WHEN p_apto_medico = 'Apto' THEN 'AT' ELSE 'NA' END;
    v_fecha_julian := fn_fecha_a_julian(SYSDATE);
    v_time := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24MISS'));
    
    UPDATE F55CARN 
    SET C5APEL = p_apellido,
        C5NOMB = p_nombre,
        C5DNI = p_dni,
        C5LEGA = p_legajo,
        C5FCAL = v_julian_cal,
        C5FVEN = v_julian_ven,
        C5APTM = v_apto_code,
        SYEDBT = p_user_id,
        SYEDSP = p_program_id,
        SYUPMJ = v_fecha_julian,
        SYUPMT = v_time
    WHERE C5CRID = p_id AND C5ACTV = 'Y';
    
    COMMIT;
END;
/

-- Business Function: Obtener Estadísticas
CREATE OR REPLACE PROCEDURE B55CARN_STATS (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        COUNT(*) as TOTAL_CARNETS,
        SUM(CASE WHEN fn_julian_a_fecha(C5FVEN) >= TRUNC(SYSDATE) 
                      AND (fn_julian_a_fecha(C5FVEN) - TRUNC(SYSDATE)) > 30 
                THEN 1 ELSE 0 END) as VIGENTES,
        SUM(CASE WHEN fn_julian_a_fecha(C5FVEN) >= TRUNC(SYSDATE) 
                      AND (fn_julian_a_fecha(C5FVEN) - TRUNC(SYSDATE)) <= 30 
                THEN 1 ELSE 0 END) as POR_VENCER,
        SUM(CASE WHEN fn_julian_a_fecha(C5FVEN) < TRUNC(SYSDATE) 
                THEN 1 ELSE 0 END) as VENCIDOS
    FROM F55CARN
    WHERE C5ACTV = 'Y';
END;
/

-- Datos de ejemplo
DECLARE
    v_id NUMBER;
BEGIN
    B55CARN_INSERT('GONZALEZ', 'JUAN', '28567123', '1001', 
                   TO_DATE('2024-11-30', 'YYYY-MM-DD'), 
                   TO_DATE('2025-11-29', 'YYYY-MM-DD'), 
                   'Apto', 'ADMIN', 'P55CARN', v_id);
    
    B55CARN_INSERT('MARTINEZ', 'CARLOS', '32456789', '1002', 
                   TO_DATE('2024-12-15', 'YYYY-MM-DD'), 
                   TO_DATE('2025-12-14', 'YYYY-MM-DD'), 
                   'Apto', 'ADMIN', 'P55CARN', v_id);
    
    B55CARN_INSERT('RODRIGUEZ', 'MARIA', '35123456', '1003', 
                   TO_DATE('2023-06-20', 'YYYY-MM-DD'), 
                   TO_DATE('2024-06-19', 'YYYY-MM-DD'), 
                   'Apto', 'ADMIN', 'P55CARN', v_id);
END;
/

/*
INSTRUCCIONES PARA IMPLEMENTAR EN JD EDWARDS:

1. Crear tabla F55CARN usando este script en la base de datos JDE
2. Registrar la tabla en JDE usando OMW:
   - Crear Object: F55CARN (tipo: Table)
   - Definir Data Dictionary Items para cada campo
   
3. Crear Business Functions:
   - B55CARN_INSERT
   - B55CARN_UPDATE  
   - B55CARN_STATS
   
4. Crear UBE (Universal Batch Engine) para reportes
5. Crear aplicación interactiva (P55CARN) usando FDA (Form Design Aid)
6. Configurar seguridad en User Defined Codes (UDC)
7. Crear Processing Options según necesidad

8. Para integración con web:
   - Usar JD Edwards Orchestrator para exponer REST APIs
   - O usar AIS (Application Interface Services)
   - O crear JDE Web Services personalizados
*/
