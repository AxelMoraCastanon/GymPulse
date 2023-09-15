USE gympulsedatabase;

-- Inserting sample data into `locations` table
INSERT INTO locations (gym_name, address) VALUES
('GymPulse Central', '123 Fitness St, City, Country'),
('GymPulse West', '456 Muscle Blvd, City, Country');

-- Inserting sample data into `trainers` table
INSERT INTO trainers (first_name, last_name, email, phone_number, location_id) VALUES
('John', 'Doe', 'john.doe@email.com', '1234567890', 1),
('Jane', 'Smith', 'jane.smith@email.com', '0987654321', 2);

-- Inserting sample data into `clients` table
INSERT INTO clients (first_name, last_name, email, phone_number) VALUES
('Alice', 'Johnson', 'alice.johnson@email.com', '1122334455'),
('Bob', 'Williams', 'bob.williams@email.com', '5566778899');

-- Inserting sample data into `schedules` table using AM/PM time and day/month/year date format
INSERT INTO schedules (trainer_id, client_id, session_date, start_time, end_time, location_id) VALUES
(1, 1, STR_TO_DATE('15/09/2023', '%d/%m/%Y'), STR_TO_DATE('09:00 AM', '%h:%i %p'), STR_TO_DATE('10:00 AM', '%h:%i %p'), 1),
(2, 2, STR_TO_DATE('16/09/2023', '%d/%m/%Y'), STR_TO_DATE('02:00 PM', '%h:%i %p'), STR_TO_DATE('03:00 PM', '%h:%i %p'), 2);

-- Inserting sample data into `payments` table
INSERT INTO payments (client_id, trainer_id, amount, payment_date, payment_status, payment_method) VALUES
(1, 1, 50.00, STR_TO_DATE('10/09/2023', '%d/%m/%Y'), 'Completed', 'Square'),
(2, 2, 60.00, STR_TO_DATE('11/09/2023', '%d/%m/%Y'), 'Pending', 'Other');

-- Inserting sample data into `training_sessions` table
INSERT INTO training_sessions (schedule_id, workout_type, duration_minutes) VALUES
(1, 'Cardio Workout', 60),
(2, 'Strength Training', 60);
