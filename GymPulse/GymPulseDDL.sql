USE gympulsedatabase;

-- Drop tables if they exist
DROP TABLE IF EXISTS training_sessions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS trainers;

-- trainers table
CREATE TABLE trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number CHAR(10),
    location_id INT,
    INDEX (location_id)
) ENGINE=InnoDB;

-- clients table
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number CHAR(10)
) ENGINE=InnoDB;

-- locations table
CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    gym_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- schedules table
CREATE TABLE schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    trainer_id INT,
    client_id INT,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    location_id INT,
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    INDEX (trainer_id, client_id, location_id)
) ENGINE=InnoDB;

-- payments table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    trainer_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(10) NOT NULL, -- changed from ENUM for flexibility
    payment_method VARCHAR(10) NOT NULL, -- changed from ENUM for flexibility
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    INDEX (client_id, trainer_id)
) ENGINE=InnoDB;

-- training_sessions table
CREATE TABLE training_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT,
    workout_type VARCHAR(100) NOT NULL,
    duration_minutes INT NOT NULL,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id),
    INDEX (schedule_id)
) ENGINE=InnoDB;
