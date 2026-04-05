CREATE OR REPLACE FUNCTION add_medicines(
    f_medicine_data jsonb
)
RETURNS VOID 
SECURITY DEFINER AS $$
DECLARE
    v_pharmacist_id UUID;
    v_row_record RECORD;
    v_medicine_id INT;
BEGIN
    
    v_pharmacist_id := auth.uid();

    IF NOT EXISTS (SELECT 1 FROM pharmacists
        WHERE id = v_pharmacist_id) THEN
            RAISE EXCEPTION 'invalid pharmacist';
    END IF;
    
    -- CREATE TEMPORARY TABLE temp_med (
    --     "name" TEXT,
    --     "dosage_strength" DECIMAL(6,2),
    --     "dosage_form" dosage_form,
    --     "dosage_units" dosage_units,
    --     "price_per_unit" DECIMAL(10,2)
    -- );

    -- INSERT INTO temp_med (
    --     "name", "dosage_strength", 
    --     "dosage_form", "dosage_units",
    --     "price_per_unit"
    -- )
    -- SELECT * FROM jsonb_to_recordset(f_medicine_data)
    -- AS x("name" TEXT,
    --     "dosage_strength" DECIMAL(6,2),
    --     "dosage_form" dosage_form,
    --     "dosage_units" dosage_units,
    --     "price_per_unit" DECIMAL(10,2));
    
    FOR v_row_record IN SELECT * FROM jsonb_to_recordset(f_medicine_data)
        AS x("name" TEXT,
            "dosage_strength" DECIMAL(6,2),
            "dosage_form" dosage_form,
            "dosage_units" dosage_units,
            "price_per_unit" DECIMAL(10,2),
            "qty" INT)

    LOOP
        INSERT INTO medication_name("name")
        VALUES (v_row_record.name)
        ON CONFLICT("name") 
        DO UPDATE SET "name" = EXCLUDED.name -- need this because without any action (insert or update postgres on conflict does not return anything)
        RETURNING id INTO 
        v_medicine_id;

        INSERT INTO medication_inventory(
            medication_id,
            "dosage_strength",
            "dosage_form",
            "dosage_units",
            "price_per_unit",
            "qty_available"
        )
        VALUES 
        (
            v_medicine_id,
            v_row_record.dosage_strength,
            v_row_record.dosage_form,
            v_row_record.dosage_units,
            v_row_record.price_per_unit,
            v_row_record.qty
        )
        ON CONFLICT (medication_id,dosage_strength,dosage_form,dosage_units)
        DO UPDATE SET qty_available = medication_inventory.qty_available + EXCLUDED.qty_available,
        price_per_unit = EXCLUDED.price_per_unit;
    END LOOP;

    INSERT INTO audit_logs (
        "action", person_id, table_name, pk
    )
    VALUES ('inserted medicines into the inventory REMEMBER PK here means the last added item', 
    v_pharmacist_id,
    'medication_name possible and medication_inventory',
    v_medicine_id);
END;
$$ LANGUAGE plpgsql;