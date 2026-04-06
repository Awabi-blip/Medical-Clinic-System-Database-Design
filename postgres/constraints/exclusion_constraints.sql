CREATE EXTENSION IF NOT EXISTS btree_gist;

ALTER TABLE doctor_schedule
ADD CONSTRAINT no_overlapping_shifts 
EXCLUDE USING gist (
    doctor_id WITH =, 
    day WITH =, 
    timerange(shift_start, shift_end) WITH &&
);

  
