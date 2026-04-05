CREATE VIEW view_all_patients_in_current_wards AS
SELECT 
    CONCAT(profiles.first_name, ' ', profiles.last_name) AS "patient",
    profiles.gender AS "gender", 
    patients.nuerotype AS "neurotypes",
    patients.chronic_diseases AS "chronic_diseases",
    wards.name AS "ward_name",
    wards.use_case AS "ward_use_case"
FROM
    patients
JOIN
    patients_in_wards
ON 
    patients.id = patients_in_wards.patient_id
JOIN
    wards
ON
    patients_in_wards.ward_name = wards.name
JOIN profiles ON patients.id = profiles.id
WHERE patients_in_wards.discharged_at IS NULL; 


CREATE VIEW view_all_patients_history_of_wards AS
SELECT 
    CONCAT(profiles.first_name, ' ', profiles.last_name) AS "patient_name",
    profiles.gender AS "gender", 
    patients.nuerotype AS "neurotypes",
    patients.chronic_diseases AS "chronic_diseases",
    wards.name AS "ward_name",
    wards.use_case AS "ward_use_case"
FROM
    patients
JOIN
    patients_in_wards
ON 
    patients.id = patients_in_wards.patient_id
JOIN
    wards
ON
    patients_in_wards.ward_name = wards.name
JOIN profiles ON patients.id = profiles.id
WHERE patients_in_wards.discharged_at IS NOT NULL; 


CREATE OR REPLACE FUNCTION add_patients_in_wards(
    f_patient_id UUID, f_ward_name ward_name, f_emergency BOOLEAN
)
RETURNS VOID
AS $$
DECLARE 
    v_beds_available INT;
    v_emergency_ward ward_name;
    v_patient_in_ward_record_id INT;
    v_manager_id UUID;
BEGIN
    
    v_manager_id = auth.uid();
    
    IF NOT EXISTS (SELECT 1 FROM management_staff WHERE id = v_manager_id) THEN
        RAISE EXCEPTION 'manager not found or not authorized';
    END IF; 
    
    -- SELECT id 
    -- INTO v_patient_in_ward_record_id
    -- FROM patients_in_wards
    -- WHERE patient_id = f_patient_id
    -- AND discharged_at IS NULL;
    
    -- IF v_patient_in_ward_record_id IS NOT NULL
    --     THEN
    --         RAISE EXCEPTION 'patient already exists in the ward'
    -- END IF;
    -- USE A PARTIAL UNIQUE INDEX INSTEAD


    SELECT beds_available
    INTO v_beds_available
    FROM wards
    WHERE "name" = f_ward_name
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ward_name % does not exist', f_ward_name;
    END IF;


    IF v_beds_available = 0 THEN
        RAISE NOTICE 'beds not available in desired ward';
        
        IF f_emergency = TRUE THEN
            SELECT "name" 
            INTO v_emergency_ward
            FROM wards
            WHERE beds_available > 0
            ORDER BY beds_available DESC
            LIMIT 1
            FOR UPDATE; 


            IF NOT FOUND THEN
                RAISE EXCEPTION 'no emergency wards available';
            END IF;

            RAISE NOTICE 'adding into emergency ward "%"', v_emergency_ward;
            
            INSERT INTO patients_in_wards 
            (patient_id, ward_name, added_under_emergency)
            VALUES (f_patient_id, v_emergency_ward, TRUE);

            UPDATE wards
            SET beds_available = beds_available - 1
            WHERE "name" = v_emergency_ward;

        ELSE
            RAISE EXCEPTION 'ward not available';
        END IF;
    
    ELSE 
        
        RAISE NOTICE 'adding into ward "%"', f_ward_name;
            
        INSERT INTO patients_in_wards 
        (patient_id, ward_name, added_under_emergency)
        VALUES (f_patient_id, f_ward_name, FALSE);

        UPDATE wards
        SET beds_available = beds_available - 1
        WHERE "name" = f_ward_name;

    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION discharge_patients_from_wards
(f_patient_id UUID, f_discharge_time TIMESTAMP)
RETURNS VOID
AS $$
DECLARE
    v_ward_name ward_name;
    v_record_id INT;
    v_manager_id UUID;
BEGIN
    
    v_manager_id = auth.uid();
    
    IF NOT EXISTS (SELECT 1 FROM management_staff WHERE id = v_manager_id) THEN
        RAISE EXCEPTION 'manager not found or not authorized';
    END IF; 
    
    SELECT id, ward_name 
    INTO v_record_id, v_ward_name
    FROM patients_in_wards 
    WHERE patient_id = f_patient_id
    AND discharged_at IS NULL
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'patient % is not currently admitted in any ward', f_patient_id;
    END IF;

    UPDATE wards
    SET beds_available = beds_available + 1
    WHERE "name" = v_ward_name;

    UPDATE patients_in_wards
    SET discharged_at = f_discharge_time
    WHERE id = v_record_id;

END;
$$ LANGUAGE plpgsql;