CREATE UNIQUE INDEX unique_patient_active_ward 
ON patients_in_wards (patient_id) 
WHERE discharged_at IS NULL;    

CREATE UNIQUE INDEX unique_nurse_active_ward_per_ward
ON nurses_in_wards (nurse_id, ward_name) 
WHERE discharged_at IS NULL;    

CREATE UNIQUE INDEX patient_doctor_unique_appointment
ON appointments (doctor_id, patient_id)
WHERE "status" = 'scheduled';

CREATE UNIQUE INDEX ON nurses_salary(nurse_id, "month", "year");

CREATE UNIQUE INDEX ON doctor_schedule (doctor_id,"day");
