CREATE VIEW view_all_nurses_in_current_wards 
WITH (security_invoker = true)
AS
SELECT 
    CONCAT(profiles.first_name, ' ', profiles.last_name) AS "nurse_name",
    nurses.shift_start AS shift_start, 
    nurses.shift_end AS shift_end,
    wards.name AS "ward_name",
    wards.use_case AS "ward_use_case"
FROM
    nurses
JOIN
    nurses_in_wards
ON 
    nurses.id = nurses_in_wards.nurse_id
JOIN
    wards
ON
    nurses_in_wards.ward_name = wards.name
JOIN 
    profiles
ON nurses.id = profiles.id
WHERE nurses_in_wards.discharged_at IS NULL; 


CREATE VIEW view_all_nurses_in_wards_history 
WITH (security_invoker = true)
AS
SELECT 
    CONCAT(profiles.first_name, ' ', profiles.last_name) AS "nurse_name",
    nurses.shift_start AS shift_start, 
    nurses.shift_end AS shift_end,
    wards.name AS "ward_name",
    wards.use_case AS "ward_use_case"
FROM
    nurses
JOIN
    nurses_in_wards
ON 
    nurses.id = nurses_in_wards.nurse_id
JOIN
    wards
ON
    nurses_in_wards.ward_name = wards.name
JOIN 
    profiles
ON nurses.id = profiles.id
WHERE nurses_in_wards.discharged_at IS NOT NULL; 


CREATE OR REPLACE FUNCTION add_nurses_to_wards(
    f_nurse_id UUID, 
    f_ward_name ward_name, 
    f_assigned_at TIMESTAMP DEFAULT NULL
) RETURNS VOID 
SECURITY DEFINER
AS $$ 
DECLARE 
    v_manager_id UUID;
    v_nurse_ward_count SMALLINT;
    v_record_id INT;
BEGIN

    v_manager_id := auth.uid();

    IF NOT EXISTS
    (SELECT 1 FROM management_staff 
    WHERE id = v_manager_id) THEN
        RAISE EXCEPTION 'permission not granted';
    END IF;

    IF f_assigned_at IS NULL THEN
        f_assigned_at := now();
    END IF;
    
    SELECT COUNT(1) INTO v_nurse_ward_count
    FROM nurses_in_wards
    WHERE nurse_id = f_nurse_id
    AND discharged_at IS NULL;

    IF v_nurse_ward_count >= 3 THEN
        RAISE EXCEPTION 'let her have it easy';
    END IF;

    INSERT INTO nurses_in_wards (
        nurse_id, ward_name, assigned_at
    )
    VALUES(
        f_nurse_id, f_ward_name, f_assigned_at
    )
    RETURNING id INTO v_record_id;

    INSERT INTO audit_logs (
        "action", person_id, table_name, pk
    ) VALUES (
        'added nurse to ward', v_manager_id, 'nurses_in_wards', v_record_id
    );


END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_nurses_from_wards(
    f_nurse_id UUID,
    f_ward_name ward_name,
    f_discharged_at TIMESTAMP DEFAULT NULL
)
RETURNS VOID
SECURITY DEFINER

AS $$
DECLARE
    v_manager_id UUID;
BEGIN   

    v_manager_id := auth.uid();

    IF NOT EXISTS
    (SELECT 1 FROM management_staff 
    WHERE id = v_manager_id) THEN
        RAISE EXCEPTION 'permission not granted';
    END IF;
    
    IF f_discharged_at IS NULL THEN
        f_discharged_at := now();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM nurses_in_wards WHERE
    nurse_id = f_nurse_id 
    AND ward_name = f_ward_name
    AND discharged_at IS NULL
    ) THEN 
        RAISE EXCEPTION '% is not currently_assigned to %', f_nurse_id, f_ward_name;
    END IF;
    

    UPDATE nurses_in_wards
    SET discharged_at = f_discharged_at
    WHERE nurse_id = f_nurse_id
    AND ward_name = f_ward_name
    AND discharged_at IS NULL;

END;
$$ LANGUAGE plpgsql;