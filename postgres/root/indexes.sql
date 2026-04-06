CREATE INDEX i0 
ON profiles(id) INCLUDE (first_name, last_name);

CREATE INDEX i1
ON appointments(doctor_id, "status") INCLUDE (
    "date", "time", duration_hours
);

CREATE INDEX i2
ON appointments (patient_id, "status")
INCLUDE ("date", "time", duration_hours);

CREATE INDEX i4 
ON appointments_billing(appointment_id)
WHERE paid = FALSE;

CREATE INDEX i42
ON prescriptions(appointment_id);

CREATE INDEX i5
ON patients(id) INCLUDE 
(gender, allergies, neurotype, chronic_diseases);

CREATE INDEX i6 
ON management_staff(id) 
INCLUDE ("role");

CREATE INDEX i7 
ON patients_in_wards(patient_id, ward_name) 
INCLUDE (assigned_at)
WHERE discharged_at IS NULL;

CREATE INDEX i71 
ON patients_in_wards(patient_id, ward_name) 
INCLUDE (assigned_at, discharged_at)
WHERE discharged_at IS NOT NULL;

CREATE INDEX i8 
ON nurses_in_wards(nurse_id, ward_name)
WHERE discharged_at IS NULL;

CREATE INDEX i81
ON patients_in_wards(nurse_id, ward_name) 
INCLUDE (assigned_at, discharged_at)
WHERE discharged_at IS NOT NULL;

-- None needed on item management
CREATE INDEX i9 
ON nurses(id) INCLUDE 
(shift_start, shift_end);

CREATE INDEX i10
ON nurse_time_deductions(nurse_id)
INCLUDE (hours_deducted, date_of_absence);

-- CREATE INDEX i11 
-- ON medication_name ("name")
-- INCLUDE (id);

--the query does not benefit from this index. 
--In fact, adding this index will actually hurt the database's write performance.
--For ON CONFLICT ("name") to function, 
--PostgreSQL requires a unique index (called an arbiter index) to detect the collision.
--Because ON CONFLICT and UPDATE, postgres literally moves to the heap to find the data,
--Since it physically has the tuple in the heap, it does not require, an include index to 
--fasten the return of the id, so adding this index overall is redundant, and it slows down
-- inserts

CREATE INDEX i12 
ON medication_inventory (medication_id, dosage_strength)
INCLUDE ("dosage_form", 
"dosage_units"
price_per_unit);
