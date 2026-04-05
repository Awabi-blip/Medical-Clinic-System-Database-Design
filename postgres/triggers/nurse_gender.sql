-- Function to restrict nurse assignments by gender
CREATE OR REPLACE FUNCTION check_nurse_gender_func()
RETURNS TRIGGER AS $$
DECLARE  
    t_nurse_id UUID;
    t_gender gender;
BEGIN
    SELECT gender INTO t_gender FROM profiles WHERE id = NEW.id;
    IF t_gender = 'Male' THEN
        RAISE EXCEPTION 'male nurse? never seen that';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger attached to nurses
CREATE TRIGGER enforce_nurse_gender
BEFORE INSERT OR UPDATE ON nurses
FOR EACH ROW
EXECUTE FUNCTION check_nurse_gender_func();