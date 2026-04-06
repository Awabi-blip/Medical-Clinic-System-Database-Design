CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE doctor_schedule
ADD CONSTRAINT no_overlapping_shifts 
EXCLUDE USING gist (
    doctor_id WITH =, 
    day WITH =, 
    timerange(shift_start, shift_end) WITH &&
);

ALTER TABLE appointments 
ADD CONSTRAINT no_overlapping_appointments_doctors
EXCLUDE USING gist
(
    doctor_id WITH =,
    scheduled_at =,
    tstzrange(scheduled_at, scheduled_at + (duration_hours * 'Interval 1 hour'))
);

ALTER TABLE appointments
ADD CONSTRAINT no_overlapping_appointments_patients
EXCLUDE USING gist
(
    patient_id WITH =,
    scheduled_at =,
    tstzrange(scheduled_at, scheduled_at + (duration_hours * 'Interval 1 hour'))
);
