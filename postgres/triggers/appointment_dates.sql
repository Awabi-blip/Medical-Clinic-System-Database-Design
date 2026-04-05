-- Function to ensure appointments are scheduled in the future
CREATE OR REPLACE FUNCTION validate_appointment_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.scheduled_at < now() THEN
        RAISE EXCEPTION 'Buddy if you invented a time machine let me know too';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger attached to appointments
CREATE TRIGGER trigger_valid_appointment_dates
BEFORE INSERT ON appointments
FOR EACH ROW
EXECUTE FUNCTION validate_appointment_dates();
