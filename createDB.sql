CREATE DATABASE cinema;
USE cinema; 

CREATE TABLE films (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(45) NOT NULL UNIQUE,
	length_min INT NOT NULL
);

CREATE TABLE customers (
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(45),
	last_name VARCHAR(45) NOT NULL,
	email VARCHAR(45) NOT NULL UNIQUE
);

CREATE TABLE rooms (
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(45) NOT NULL,
	no_seats INT NOT NULL
);

CREATE TABLE screenings (
	id INT PRIMARY KEY AUTO_INCREMENT,
	film_id INT NOT NULL,
	room_id INT NOT NULL, 
	start_time DATETIME NOT NULL,
	FOREIGN KEY (film_id) REFERENCES films(id),
	FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE seats (
	id INT PRIMARY KEY AUTO_INCREMENT, 
	row CHAR(1) NOT NULL,
	number INT NOT NULL,
	room_id INT NOT NULL, 
	FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE bookings (
	id INT PRIMARY KEY AUTO_INCREMENT,
	screening_id INT NOT NULL, 
	customer_id INT NOT NULL,
	FOREIGN KEY (screening_id) REFERENCES screenings(id),
	FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE reserved_seat (
	id INT PRIMARY KEY AUTO_INCREMENT,
	booking_id INT NOT NULL,
	seat_id INT NOT NULL,
	FOREIGN KEY (booking_id) REFERENCES bookings(id),
	FOREIGN KEY (seat_id) REFERENCES seats(id)
);

INSERT INTO films (name, length_min)
VALUES ('Blade Runner 2049',153),
('Dunkirk',106),
('Geostorm',121),
('Thor: Ragnarok',107),
('Jigsaw',116),
('The Death of Stalin',98),
('The Lego Ninjago Movie',101),
('Murder on the Orient Express',135),
('Paddington 2',88),
('Breathe',117),
('Blade Runner',127),
('Victoria and Abdul',112);

