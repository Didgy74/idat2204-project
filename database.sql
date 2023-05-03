DROP DATABASE IF EXISTS project;
CREATE DATABASE project;
USE project;

-- Common definition for users.
CREATE TABLE users (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  username varchar(32) NOT NULL UNIQUE,
  real_name varchar(255) NOT NULL CHECK (LENGTH(real_name) != 0)
);
INSERT INTO users VALUES(null, 'root', 'root');

-- Definiton for students. Specialization of user.
CREATE TABLE students (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
-- Helpful view to see students with more readable info.
CREATE VIEW students_info AS
SELECT students.user_id, users.real_name, users.username
FROM students JOIN users ON students.user_id = users.id;

-- Definition for lecturers. Specialization of user.
CREATE TABLE lecturers (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  institute varchar(255) NOT NULL CHECK(LENGTH(institute) != 0)
);
-- Helpful view to see lecturers with more readable info.
CREATE VIEW lecturers_info AS
SELECT user_id, users.real_name, users.username, lecturers.institute
FROM lecturers 
JOIN users ON lecturers.user_id = users.id;


-- Definition of rooms that can be booked
CREATE TABLE rooms (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  size int NOT NULL CHECK (size != 0),
  
  building varchar(255) NOT NULL CHECK (LENGTH(building) != 0)
);

-- Definition of courses.
CREATE TABLE courses (
  id int UNIQUE NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  -- Has to be nullable because the assignment requires us to have courses
  -- that do not have a lecturer assigned yet.
  lecturer_id int DEFAULT NULL,
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id),
  
  course_name varchar(255) NOT NULL CHECK(LENGTH(course_name) != 0)
);
-- Helpful view to see courses with more readable info.
CREATE VIEW courses_info AS
SELECT 
	courses.id AS course_id, 
	courses.course_name, 
	lecturers_info.real_name AS lecturer_name
FROM courses
LEFT JOIN lecturers_info ON courses.lecturer_id = lecturers_info.user_id;

-- Holds the many-to-many relation between students enrolled in courses.
CREATE TABLE StudentsCourses (
  student_id int NOT NULL,
  course_id int NOT NULL,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(user_id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);
-- Helpful view to see student-courses with more readable info.
CREATE VIEW students_courses_names AS
SELECT courses.course_name AS course_name, students_info.real_name AS student_name
FROM studentscourses
JOIN students_info ON studentscourses.student_id = students_info.user_id
JOIN courses ON studentscourses.course_id = courses.id
ORDER BY courses.course_name ASC;

CREATE TABLE bookings (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  user_id int NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  room_id int NOT NULL,
  FOREIGN KEY (room_id) REFERENCES rooms(id),
  
  course_id int DEFAULT NULL,
  FOREIGN KEY (course_id) REFERENCES courses(id),
  
  booking_date DATE NOT NULL,
  start_hour INT NOT NULL CHECK(start_hour >= 0 AND start_hour < 24),
  end_hour INT NOT NULL CHECK(end_hour >= 0 AND end_hour < 24),
  CONSTRAINT CHECK(end_hour > start_hour),
  
  description varchar(255) NOT NULL
);
-- Helpful view to see bookings with more readable info.
CREATE VIEW bookings_info AS
SELECT room_id, booking_date, start_hour, end_hour, description, courses.course_name AS course_name
FROM bookings
LEFT JOIN courses ON bookings.course_id = courses.id
ORDER BY booking_date;


-- Add a lecturer and give him some courses.
INSERT INTO users VALUES (null, 'jsmith', 'John Smith');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Business Administration');
INSERT INTO courses VALUES (null, @lecturer_id, 'Ladders');
INSERT INTO courses VALUES (null, @lecturer_id, 'Advanced Breath Holding');

INSERT INTO users VALUES (null, 'mbrown', 'Mary Brown');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Engineering');
INSERT INTO courses VALUES (null, @lecturer_id, 'Theoretical Phys Ed');
INSERT INTO courses VALUES (null, @lecturer_id, 'Physical Education Education');
INSERT INTO courses VALUES (null, @lecturer_id, 'Class 101');

INSERT INTO users VALUES (null, 'dlee', 'David Lee');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Computer Science');
INSERT INTO courses VALUES (null, @lecturer_id, 'The History of Internet Cat Videos');
INSERT INTO courses VALUES (null, @lecturer_id, 'Feline Algebra');
INSERT INTO courses VALUES (null, @lecturer_id, 'C++ as a first language');
INSERT INTO courses VALUES (null, @lecturer_id, 'Graphics programming');
SET @gfx_course_id = LAST_INSERT_ID();

INSERT INTO users VALUES (null, 'sjohnson', 'Sarah Johnson');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Law');
INSERT INTO courses VALUES (null, @lecturer_id, 'Sneezing Fundamentals');

INSERT INTO users VALUES (null, 'mkim', 'Michael Kim');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Medicine');
INSERT INTO courses VALUES (null, @lecturer_id, 'Food Poisoning 102');

INSERT INTO users VALUES (null, 'jdoe', 'John Doe');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Sociology');

-- Add some courses without any lecturer.
INSERT INTO courses(course_name) VALUES 
	('Rocket Science for dummies'),
    ('Advanced teleportation'),
    ('Intro to Napping 101'),
    ('The Art of Procrastination'),
    ('The Fine Art of Water Balloon Warfare');

-- 15 students.
INSERT INTO users VALUES (null, 'nils', 'Nils Petter');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'apatel', 'Ava Patel');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'llee', 'Liam Lee');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'mkim2', 'Mia Kim');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'njohnson', 'Noah Johnson');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'echen', 'Emma Chen');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'adavis', 'Aiden Davis');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'owong', 'Olivia Wong');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'lsingh', 'Lucas Singh');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'igupta', 'Isabella Gupta');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'mnguyen', 'Mason Nguyen');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'shuang', 'Sophia Huang');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'lshah', 'Logan Shah');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'hdas', 'Harper Das');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'jpark', 'Jackson Park');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);

-- Insert 20 course enrollments.
DELIMITER //
CREATE FUNCTION get_userid_of_studentindex (idx INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE result INT;
	SELECT students.user_id INTO result
    FROM students
    LIMIT 1
	OFFSET idx;
    RETURN result;
END //
DELIMITER ;
INSERT INTO StudentsCourses VALUES
  (get_userid_of_studentindex(0), 1),
  (get_userid_of_studentindex(0), 2),
  (get_userid_of_studentindex(1), 5),
  (get_userid_of_studentindex(1), 9),
  (get_userid_of_studentindex(2), 1),
  (get_userid_of_studentindex(2), 4),
  (get_userid_of_studentindex(2), 7),
  (get_userid_of_studentindex(3), 3),
  (get_userid_of_studentindex(3), 5),
  (get_userid_of_studentindex(3), 10),
  (get_userid_of_studentindex(4), 2),
  (get_userid_of_studentindex(4), 6),
  (get_userid_of_studentindex(4), 11),
  (get_userid_of_studentindex(4), 13),
  (get_userid_of_studentindex(5), 4),
  (get_userid_of_studentindex(5), 8),
  (get_userid_of_studentindex(6), 3),
  (get_userid_of_studentindex(6), 5),
  (get_userid_of_studentindex(7), 2),
  (get_userid_of_studentindex(7), 6),
  (get_userid_of_studentindex(7), 14),
  (get_userid_of_studentindex(8), 1),
  (get_userid_of_studentindex(8), 7),
  (get_userid_of_studentindex(8), 11),
  (get_userid_of_studentindex(9), 2),
  (get_userid_of_studentindex(9), 9),
  (get_userid_of_studentindex(10), 1),
  (get_userid_of_studentindex(10), 5),
  (get_userid_of_studentindex(11), 3),
  (get_userid_of_studentindex(11), 7),
  (get_userid_of_studentindex(11), 12),
  (get_userid_of_studentindex(12), 1),
  (get_userid_of_studentindex(12), 6),
  (get_userid_of_studentindex(13), 2),
  (get_userid_of_studentindex(13), 3),
  (get_userid_of_studentindex(13), 5),
  (get_userid_of_studentindex(14), 1),
  (get_userid_of_studentindex(14), 8),
  (get_userid_of_studentindex(14), 10),
  (get_userid_of_studentindex(14), 14);
DROP FUNCTION get_userid_of_studentindex;

-- Insert 10 rooms
INSERT INTO rooms(size, building) VALUES
	(25, 'Alpha'),
	(30, 'Beta'),
	(20, 'Alpha');

INSERT INTO bookings(user_id, room_id, course_id, booking_date, start_hour, end_hour, description) VALUES
	(1, 1, 1, '2023-05-01', 8, 13, 'Maths Tutorial'),
	(2, 2, 3, '2023-05-01', 10, 12, 'Physics Lab'),
	(3, 1, 5, '2023-05-01', 14, 16, 'Economics class'),
	(4, 1, 7, '2023-05-01', 16, 18, 'Introduction to Programming'),
	(5, 2, 9, '2023-05-02', 8, 10, 'History lecture'),
	(6, 3, 11, '2023-05-02', 10, 12, 'Marketing seminar'),
	(7, 1, 13, '2023-05-02', 14, 16, 'Spanish Course'),
	(8, 2, 15, '2023-05-02', 16, 18, 'Sociology Tutorial'),
	(9, 3, 2, '2023-05-03', 8, 10, 'English Literature Class'),
	(10, 1, 4, '2023-05-03', 10, 12, 'Biology lab'),
	(11, 2, 6, '2023-05-03', 14, 16, 'Computer Networks'),
	(12, 3, 8, '2023-05-03', 16, 18, 'Philosophy Seminar'),
	(2, 1, 10, '2023-05-04', 8, 10, 'Statistics class'),
	(4, 2, 12, '2023-05-04', 10, 12, 'Chemistry Tutorial'),
	(6, 3, 14, '2023-05-04', 14, 16, 'Public Speaking Course'),
	(8, 1, 16, '2023-05-04', 16, 18, 'Journalism Workshop'),
	(10, 2, 3, '2023-05-05', 8, 10, 'Geology lecture'),
	(12, 3, 5, '2023-05-05', 10, 12, 'History of Art class'),
	(1, 1, 7, '2023-05-05', 14, 16, 'French course'),
	(3, 2, 9, '2023-05-05', 16, 18, 'Business Analytics'),
	(5, 3, 11, '2023-05-06', 8, 10, 'Marketing Strategies'),
	(7, 1, 13, '2023-05-06', 10, 12, 'German course'),
	(9, 2, 15, '2023-05-06', 14, 16, 'Anthropology Tutorial'),
	(11, 3, 2, '2023-05-06', 16, 18, 'English Language Course'),
	(4, 1, 4, '2023-05-07', 8, 10, 'Botany lab');