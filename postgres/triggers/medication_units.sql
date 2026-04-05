-- Function to validate medication units against allowed forms
CREATE OR REPLACE FUNCTION check_medication_units()
RETURNS TRIGGER AS $$
BEGIN 
    IF NEW.dosage_units IN 
    (SELECT "dosage_units" 
        FROM "allowed_dosage_units"
        WHERE "dosage_form" = NEW.dosage_form
    ) 
    THEN 
        RETURN NEW;
    ELSE 
        RAISE EXCEPTION 'Invalid dosage_units "%" for dosage_form "%"', 
                        NEW.dosage_units, NEW.dosage_form;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger attached to medication_inventory
CREATE TRIGGER trigger_check_medication_units
BEFORE INSERT ON medication_inventory
FOR EACH ROW
EXECUTE FUNCTION check_medication_units();