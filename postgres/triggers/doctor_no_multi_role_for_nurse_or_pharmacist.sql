-- Function to enforce business model roles (doctors cannot be nurses/pharmacists and vice versa)
CREATE OR REPLACE FUNCTION validate_doctor_extra_roles()
RETURNS TRIGGER AS $$
DECLARE 
BEGIN
    IF NEW.role = 'doctor' THEN
        IF EXISTS (
            SELECT 1 
            FROM user_roles
            WHERE id = NEW.id
            AND "role" IN ('nurse'::all_roles, 'pharmacist'::all_roles)
        ) THEN
            RAISE EXCEPTION 'not our business model';
        END IF;
    END IF;

    IF NEW.role = 'pharmacist' OR NEW.role = 'nurse'
     THEN 
        IF EXISTS (
            SELECT 1
            FROM user_roles 
            WHERE id = NEW.id
            AND "role" = 'doctor'::all_roles
        ) THEN 
            RAISE EXCEPTION 'not our business model';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger attached to user_roles
CREATE OR REPLACE TRIGGER check_doctor_extra_roles
BEFORE INSERT ON user_roles
FOR EACH ROW
EXECUTE FUNCTION validate_doctor_extra_roles();