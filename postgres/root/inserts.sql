INSERT INTO "wards" ("name", "beds_total", "beds_available", "use_case", "description") 
VALUES
('sunflower', 15, 15,
-- Use Case:
'For people needing emeregency services, band aids in cupboards, pain killers, 60/120W massage batteries, a few blood bottles of each type.',
-- Description:
'Sunflowers represent hope, life and resilience, these people need that the most, praying for their safety as I write this schema~.'
),

('rose', 2, 2,
-- Use Case:
'For women visiting a gynecologist, equipped with Ultra Sound Machines, highly separated beds to keep privacy, some gentle care things in the cupboard.',
-- Description:
'Roses in the room, in watered pots, with rose fragrance and aroma, a rose filled therapuetic experience, truly a romantic environment to make patients safe and at home for something rather sensitive-🌹'
),

('tulip', 8, 8,
-- Use Case:
'For people visiting a General Doctor suffering from chronic weakness, ideal for drip setup because of spaced beds, vitamin supplements and biscuits in cupboard.',
-- Description:
'Light Blue and Dark Blue Tulips, enough to make people get lost in the melody of their patternizing beauty that they forget all why they came to the hospital for, not my motive ofc 💠'
),

('daisy', 8, 8, 
-- Use Case:
'For people visiting a General Physician, in need of rest or sleep, a basic checkup or a basic massage, some massage oils and 60W batteries for massagers in cupboard.',
-- Description:
'Nothing as basic and friendly as a daisy, helps people relax and sleep 🌼'
),

('jasmine', 8, 8, 
-- Use Case:
'For people visiting an Orthopedic, long, moveable stature beds, mini x-ray machines installed, 120W batteries for massagers in cupboard.',
-- Description:
'The nurturing and healing essence of Jasmine, rather maternal, needed in a painful environment to soothe~ soothe~ blow it away, like fooo ;) 🤍🌿'
),

('lavender', 10, 10, 
-- Use Case:
'For people visting an ENT, pluggers for venitlators available, use for emergency, each bed separated by glass to avoid disease spread.',
-- Description:
'Filled with lavender plants and smell, Therapuetic lavender plants to calm those active and itchy tonsils 🪻'
),

('blossom', 10, 10, 
-- Use Case:
'For people visting their child a Pediatrician, small beds with side fences for kids, light painkillers, vaccines in the cupboard.',
-- Description:
'Home to some cherry blossom plants and blossom flowers, truly makes a children curiosity peak, aswell as keeps their instincts calm and at ease 🌸.'
);

INSERT INTO "item_store_room"(item_type, amount_total, amount_available, return_status)
VALUES 
('ventilator', 14, 14, TRUE),
('drip_setup', 50, 50, TRUE),
('syringes', 3000, 3000, FALSE),
('massagers', 10, 10, TRUE),
('60W_batteries', 12, 12, TRUE),
('30W_batteries', 12, 12, TRUE),
('rose_water', 5, 5, FALSE), --ts good
('protein_wheat_biscuits', 100,100, FALSE),
('vitamin_supplements', 40, 40, FALSE)
;


INSERT INTO allowed_dosage_units (dosage_form, dosage_units) 
VALUES
    ('tablets', 'mg'),
    ('capsule', 'mg'),
    ('syrup', 'mg/ml'),
    ('syrup', 'mg/5ml'),
    ('injection', 'mg/ml'),
    ('injection', 'IU/ml'),
    ('ointment', '%'),
    ('ointment', 'mg/g'),
    ('inhalers', 'mcg'),
    ('eye_drops', 'mg/ml')
;

