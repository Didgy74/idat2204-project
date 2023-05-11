DROP DATABASE IF EXISTS project;
CREATE DATABASE project;
USE project;

-- Common definition for users.
CREATE TABLE users (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  username varchar(32) NOT NULL UNIQUE,
  real_name varchar(255) NOT NULL CHECK (LENGTH(real_name) != 0),
  email varchar(255) NOT NULL
);
INSERT INTO users VALUES(null, 'root', 'root', 'root@gmail.com');

-- Definiton for students. Specialization of user.
CREATE TABLE students (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
-- Helpful view to see students with more readable info.
CREATE VIEW students_info AS
SELECT students.user_id, users.real_name, users.username, users.email
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
SELECT user_id, users.real_name, users.username, lecturers.institute, users.email
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
  
  course_name varchar(255) NOT NULL CHECK(LENGTH(course_name) != 0),

  faculty varchar(255) NOT NULL CHECK(LENGTH(faculty) != 0),

  enrolled_students int DEFAULT 0
);
-- Helpful view to see courses with more readable info.
CREATE VIEW courses_info AS
SELECT 
	courses.id AS course_id, 
	courses.course_name, 
  lecturers_info.email AS email,
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
  week_number INT AS (WEEK(booking_date)),
  week_day VARCHAR(255) AS (DATE_FORMAT(booking_date, '%W')),

  booking_type VARCHAR(255) NOT NULL,

  description VARCHAR(255) NOT NULL
);

-- Helpful view to see bookings with more readable info.
CREATE VIEW bookings_info AS
SELECT room_id, booking_date, start_hour, end_hour, description, courses.course_name AS course_name
FROM bookings
LEFT JOIN courses ON bookings.course_id = courses.id
ORDER BY booking_date;


-- Add a lecturer and give him some courses.
INSERT INTO users VALUES (null, 'jsmith', 'John Smith', 'john.smith@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Business Administration');
INSERT INTO courses VALUES (null, @lecturer_id, 'Ladders', 'Faculty 4', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'Advanced Breath Holding', 'Faculty 2', 0);

INSERT INTO users VALUES (null, 'mbrown', 'Mary Brown', 'mary.brown@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Engineering');
INSERT INTO courses VALUES (null, @lecturer_id, 'Theoretical Phys Ed', 'Faculty 1', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'Physical Education Education', 'Faculty 1', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'Class 101', 'Faculty 3', 0);

INSERT INTO users VALUES (null, 'dlee', 'David Lee', 'david.lee@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Computer Science');
INSERT INTO courses VALUES (null, @lecturer_id, 'The History of Internet Cat Videos', 'Faculty 1', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'Feline Algebra', 'Faculty 2', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'C++ as a first language', 'Faculty 3', 0);
INSERT INTO courses VALUES (null, @lecturer_id, 'Graphics programming', 'Faculty 3', 0);
SET @gfx_course_id = LAST_INSERT_ID();

INSERT INTO users VALUES (null, 'sjohnson', 'Sarah Johnson', 'sarah.johnson@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Law');
INSERT INTO courses VALUES (null, @lecturer_id, 'Sneezing Fundamentals', 'Faculty 4', 0);

INSERT INTO users VALUES (null, 'mkim', 'Michael Kim', 'michael.kim@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Medicine');
INSERT INTO courses VALUES (null, @lecturer_id, 'Food Poisoning 102', 'Faculty 3', 0);

INSERT INTO users VALUES (null, 'jdoe', 'John Doe', 'john.doe@gmail.com');
SET @lecturer_id := LAST_INSERT_ID();
INSERT INTO lecturers VALUES (@lecturer_id, 'Sociology');

-- Add some courses without any lecturer.
INSERT INTO courses(course_name, faculty) VALUES 
	('Rocket Science for dummies', 'Faculty 1'),
    ('Advanced teleportation', 'Faculty 2'),
    ('Intro to Napping 101', 'Faculty 2'),
    ('The Art of Procrastination', 'Faculty 1'),
    ('The Fine Art of Water Balloon Warfare', 'Faculty 1');

-- 15 students.
INSERT INTO users VALUES (null, 'nils', 'Nils Petter', 'nils.petter@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'apatel', 'Ava Patel', 'ava.patel@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'llee', 'Liam Lee', 'liam.lee@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'mkim2', 'Mia Kim', 'mia.kim@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'njohnson', 'Noah Johnson', 'noah.johnson@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'echen', 'Emma Chen', 'emma.chen@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'adavis', 'Aiden Davis', 'aiden.davis@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'owong', 'Olivia Wong', 'olivia.wong@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'lsingh', 'Lucas Singh', 'lucas.singh@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'igupta', 'Isabella Gupta', 'isabella.gupta@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'mnguyen', 'Mason Nguyen', 'mason.nguyen@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'shuang', 'Sophia Huang', 'sophia.huang@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'lshah', 'Logan Shah', 'logan.shah@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'hdas', 'Harper Das', 'harper.das@gmail.com');
SET @student_id = LAST_INSERT_ID();
INSERT INTO students VALUES (@student_id);
INSERT INTO users VALUES (null, 'jpark', 'Jackson Park', 'jackson.park@gmail.com');
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

-- Insert rooms
INSERT INTO rooms(size, building) VALUES
	(25, 'Alpha'),
	(30, 'Beta'),
	(20, 'Alpha'),
	(45, 'Alpha');

INSERT INTO bookings(user_id, room_id, course_id, booking_date, start_hour, end_hour, description, booking_type) VALUES
	(1, 1, 1, '2023-05-01', 8, 13, 'Maths Tutorial', ''),
	(2, 2, 3, '2023-05-01', 10, 12, 'Physics Lab', 'course'),
	(3, 1, 5, '2023-05-01', 14, 16, 'Economics class', 'course'),
	(4, 1, 7, '2023-05-01', 16, 18, 'Introduction to Programming', 'course'),
	(5, 2, null, '2023-05-02', 8, 10, 'History lecture', 'course'),
	(6, 3, 11, '2023-05-02', 10, 12, 'Marketing seminar', 'course'),
	(7, 1, 13, '2023-05-02', 14, 16, 'Spanish Course', 'course'),
	(8, 2, 15, '2023-05-02', 16, 18, 'Sociology Tutorial', 'student'),
	(9, 3, null, '2023-05-03', 8, 10, 'English Literature Class', 'student'),
	(10, 1, 4, '2023-05-03', 10, 12, 'Biology lab', 'student'),
	(11, 2, 6, '2023-05-03', 14, 16, 'Computer Networks', 'student'),
	(12, 3, 8, '2023-05-03', 16, 18, 'Philosophy Seminar', 'student'),
	(2, 1, 10, '2023-05-04', 8, 10, 'Statistics class', 'course'),
	(4, 2, null, '2023-05-04', 10, 12, 'Chemistry Tutorial', 'course'),
	(6, 3, 14, '2023-05-04', 14, 16, 'Public Speaking Course', 'course'),
	(8, 1, 16, '2023-05-04', 16, 18, 'Journalism Workshop', 'student'),
	(10, 2, null, '2023-05-05', 8, 10, 'Geology lecture', 'student'),
	(12, 3, 5, '2023-05-05', 10, 12, 'History of Art class', 'student'),
	(1, 1, 7, '2023-05-05', 14, 16, 'French course', 'course'),
	(3, 2, 9, '2023-05-05', 16, 18, 'Business Analytics', 'course'),
	(5, 3, null, '2023-05-06', 8, 10, 'Marketing Strategies', 'course'),
	(7, 1, 13, '2023-05-06', 10, 12, 'German course', 'course'),
	(9, 2, 15, '2023-05-06', 14, 16, 'Anthropology Tutorial', 'student'),
	(11, 3, 2, '2023-05-06', 16, 18, 'English Language Course', 'student'),
	(4, 1, 4, '2023-05-07', 8, 10, 'Botany lab', 'course');


UPDATE courses c
SET c.enrolled_students = (
  SELECT COUNT(*)
  FROM studentscourses sc
  WHERE sc.course_id = c.id
);