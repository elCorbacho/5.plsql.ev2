-- Este archivo contiene código PL/SQL

/* ********************************************************************************************************
                           Procedimiento registro de atención
******************************************************************************************************** */

CREATE OR REPLACE PROCEDURE registro_atencion (
    p_ate_id IN NUMBER,
    p_fecha_atencion IN DATE,
    p_hr_atencion IN VARCHAR2,
    p_costo IN NUMBER,
    p_med_run IN NUMBER,
    p_esp_id IN NUMBER,
    p_pac_run IN NUMBER
) IS
BEGIN
    INSERT INTO atencion (ate_id, fecha_atencion, hr_atencion, costo, med_run, esp_id, pac_run)
    VALUES (p_ate_id, p_fecha_atencion, p_hr_atencion, p_costo, p_med_run, p_esp_id, p_pac_run);
END;

/* ********************************************************************************************************
                           Función consulta de atenciones por fecha
******************************************************************************************************** */

CREATE OR REPLACE FUNCTION consulta_atenciones (
    f_fecha_inicio DATE,
    f_fecha_fin DATE
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
    SELECT ate.fecha_atencion AS "Fecha de atención", med.pnombre || ' ' || med.apaterno AS "Nombre Médico", pac.pnombre || ' ' || pac.apaterno  AS "Nombre Paciente", esp.nombre as "Especialidad"
    FROM atencion ate
    JOIN medico med ON ate.med_run = med.med_run
    JOIN paciente pac ON ate.pac_run = pac.pac_run
    JOIN especialidad esp ON ate.esp_id = esp.esp_id
    WHERE ate.fecha_atencion BETWEEN f_fecha_inicio AND f_fecha_fin;
    
    RETURN v_cursor;
END;

/* ********************************************************************************************************
                           Procedimiento para actualización de sueldos
******************************************************************************************************** */

CREATE OR REPLACE PROCEDURE actualizacion_sueldos (
    p_sueldo_base IN NUMBER,
    p_medico_id IN VARCHAR2
) IS 
BEGIN
    UPDATE medico SET sueldo_base = p_sueldo_base
    WHERE p_medico_id = med_run || '-' || dv_run;
END;

/* ********************************************************************************************************
                           Función para calcular la edad de los pacientes
******************************************************************************************************** */

CREATE OR REPLACE FUNCTION calcular_edad (
    f_rut_paciente VARCHAR2
) RETURN NUMBER IS
    v_edad NUMBER;
    v_fecha_nac DATE;
BEGIN
    SELECT fecha_nacimiento
    INTO v_fecha_nac
    FROM paciente
    WHERE f_rut_paciente = pac_run || '-' || dv_run;
    
    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);

    RETURN v_edad;
END;

/* ********************************************************************************************************
                           Función para verificar registro de pacientes
******************************************************************************************************** */    
    
CREATE OR REPLACE FUNCTION verificar_pacientes(
    p_rut_paciente VARCHAR2
) RETURN VARCHAR2 IS
    v_existe VARCHAR2(100);
BEGIN
    SELECT CASE WHEN COUNT(*) > 0 THEN 'El paciente ya está registrado' ELSE 'El paciente no se encuentra en nuestros registros' END
    INTO v_existe
    FROM paciente
    WHERE pac_run || '-' || dv_run = p_rut_paciente;
    
    RETURN v_existe;
END;