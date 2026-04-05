-- Function to calculate and enforce maximum shift lengths
CREATE OR REPLACE FUNCTION check_shift_hours() RETURNS TRIGGER AS $$ 
DECLARE 
    total_hours DECIMAL(4,2);
BEGIN
    total_hours := (EXTRACT (EPOCH FROM(NEW.shift_end - NEW.shift_start))) / 3600;

    IF total_hours > 8.5 THEN 
        RAISE EXCEPTION 'adhere to work life balance';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers attached to the respective schedule tables
CREATE OR REPLACE TRIGGER check_doctor_shift_hours
BEFORE INSERT OR UPDATE ON doctor_schedule
FOR EACH ROW EXECUTE FUNCTION check_shift_hours();

CREATE OR REPLACE TRIGGER check_nurse_shift_hours
BEFORE INSERT OR UPDATE ON nurses
FOR EACH ROW EXECUTE FUNCTION check_shift_hours();

CREATE OR REPLACE TRIGGER check_pharmacist_shift_hours
BEFORE INSERT OR UPDATE ON pharmacists
FOR EACH ROW EXECUTE FUNCTION check_shift_hours();