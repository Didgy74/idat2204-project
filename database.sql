DROP DATABASE IF EXISTS project;
CREATE DATABASE project;
USE project;

CREATE TABLE users (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  name varchar(255) NOT NULL CHECK (LENGTH(name) != 0)
);



CREATE TABLE students (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DELIMITER //
CREATE PROCEDURE add_student(IN real_name varchar(255), OUT student_id INT)
BEGIN
	INSERT INTO users VALUES(0, real_name);
	INSERT INTO students VALUES(LAST_INSERT_ID());
	SET student_id = LAST_INSERT_ID();
END //
DELIMITER ;

CREATE VIEW students_info AS
SELECT students.user_id, users.name
FROM students JOIN users ON students.user_id = users.id;



CREATE TABLE lecturers (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  institute varchar(255) NOT NULL CHECK(LENGTH(institute) != 0)
);

DELIMITER //
CREATE PROCEDURE add_lecturer(IN real_name varchar(255), IN institute varchar(255), OUT lecturer_id INT)
BEGIN
	INSERT INTO users VALUES(0, real_name);
    INSERT INTO lecturers VALUES (
		LAST_INSERT_ID(),
        institute
    );
	SET lecturer_id = LAST_INSERT_ID();
END //
DELIMITER ;

CREATE VIEW lecturers_info AS
SELECT lecturers.user_id, users.name, lecturers.institute
FROM lecturers JOIN users ON lecturers.user_id = users.id;


CREATE TABLE rooms (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  size int NOT NULL CHECK (size != 0),
  
  building varchar(255) NOT NULL CHECK (LENGTH(building) != 0)
);

CREATE TABLE courses (
  id int UNIQUE NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  lecturer_id int,
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id),
  
  name varchar(255) NOT NULL CHECK(LENGTH(name) != 0)
);

CREATE VIEW courses_info AS
SELECT courses.name AS course_name, lecturers_info.name AS lecturer_name
FROM courses
LEFT JOIN lecturers_info ON courses.lecturer_id = lecturers_info.user_id;

CREATE TABLE StudentsCourses (
  student_id int NOT NULL,
  course_id int NOT NULL,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(user_id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE VIEW students_courses_names AS
SELECT courses.name AS course_name, students_info.name AS student_name
FROM studentscourses
JOIN students_info ON studentscourses.student_id = students_info.user_id
JOIN courses ON studentscourses.course_id = courses.id
ORDER BY courses.name ASC;


CREATE TABLE bookings (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  user_id int NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  room_id int NOT NULL,
  FOREIGN KEY (room_id) REFERENCES rooms(id),
  
  course_id int,
  FOREIGN KEY (course_id) REFERENCES courses(id),
  
  booking_date DATE NOT NULL,
  start_hour INT NOT NULL CHECK(start_hour >= 0 AND start_hour < 24),
  end_hour INT NOT NULL CHECK(end_hour > start_hour AND end_hour >= 0 AND end_hour < 24),
  
  description varchar(255) NOT NULL
);
CREATE VIEW bookings_info AS
SELECT room_id, booking_date, start_hour, end_hour, description, courses.name AS course_name
FROM bookings
LEFT JOIN courses ON bookings.course_id = courses.id;


CALL add_lecturer('John Smith', 'Business Administration', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Business Ethics');
INSERT INTO courses VALUES (null, @lecturer_id, 'Managerial Accounting');

CALL add_lecturer('Mary Brown', 'Engineering', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Supply Chain Management');
INSERT INTO courses VALUES (null, @lecturer_id, 'Mechanical Design and Analysis');
INSERT INTO courses VALUES (null, @lecturer_id, 'Engineering 101');

CALL add_lecturer('David Lee', 'Computer Science', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Introduction to Programming');
INSERT INTO courses VALUES (null, @lecturer_id, 'Feline algebra');
INSERT INTO courses VALUES (0, @lecturer_id, 'C++ as a first language');
INSERT INTO courses VALUES (0, @lecturer_id, 'Graphics programming');
SET @gfx_course_id = LAST_INSERT_ID();

CALL add_lecturer('Sarah Johnson', 'Law', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Constitutional Law');

CALL add_lecturer('Michael Kim', 'Medicine', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Anatomy and Physiology');

CALL add_lecturer('Jane Doe', 'Sociology', @lecturer_id);


INSERT INTO courses VALUES (0, null,'Rocket Science for dummies');
INSERT INTO courses VALUES (0, null, 'Advanced teleportation');
INSERT INTO courses VALUES (0, null, 'Comparative Religion');
INSERT INTO courses VALUES (0, null, 'Accounting for Lawyers');


CALL add_student('Ethan Rodriguez', @student_id);
CALL add_student('Ava Patel', @student_id);
CALL add_student('Liam Lee', @student_id);
CALL add_student('Mia Kim', @student_id);
CALL add_student('Noah Johnson', @student_id);
CALL add_student('Emma Chen', @student_id);
CALL add_student('Aiden Davis', @student_id);
CALL add_student('Olivia Wong', @student_id);
CALL add_student('Lucas Singh', @student_id);
CALL add_student('Isabella Gupta', @student_id);
CALL add_student('Mason Nguyen', @student_id);
CALL add_student('Sophia Huang', @student_id);
CALL add_student('Logan Shah', @student_id);
CALL add_student('Harper Das', @student_id);
CALL add_student('Jackson Park', @student_id);


DELIMITER //
CREATE FUNCTION get_userid_of_studentindex (idx INT)
RETURNS INT
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
  (get_userid_of_studentindex(1), 1),
  (get_userid_of_studentindex(1), 2),
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

-- Insert some rooms
INSERT INTO rooms VALUES (0, 2, 'A');
INSERT INTO rooms VALUES (0, 4, 'A');
INSERT INTO rooms VALUES (0, 4, 'A');
INSERT INTO rooms VALUES (0, 2, 'B');

-- Setup some course bookings
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  @gfx_course_id,
  '2024-01-01',
  8,
  12,
  'Simple raytracing'
);
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  null,
  '2024-01-01',
  12,
  14,
  'Today we are doing something'
);
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  @gfx_course_id,
  '2024-01-02',
  8,
  12,
  'Photorealistic rendering'
);