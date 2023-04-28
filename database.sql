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
CREATE PROCEDURE add_lecturer(IN real_name varchar(255), IN institute varchar(255))
BEGIN
	INSERT INTO users VALUES(0, real_name);
    INSERT INTO lecturers VALUES (
		LAST_INSERT_ID(),
        institute
    );
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




CALL add_lecturer('Teacher Teacherson', 'IT');
CALL add_lecturer('Teach Teacherman', 'IT');
CALL add_lecturer('Lecturer Lecturerson', 'Math');


-- Insert some fields that don't have any lecturers
INSERT INTO courses VALUES (
  0,
  null, 
  'Math 101'
); 
INSERT INTO courses VALUES (
  0,
  null, 
  'Math 102'
); 
INSERT INTO courses VALUES (
  0,
  null, 
  'Databases'
); 
INSERT INTO courses VALUES (
  0,
  null, 
  "Cloud Technologies"
); 
INSERT INTO courses VALUE (
  0, 
  1, -- Or search a specific lecturer name
  'Rocket Science for dummies'
);
INSERT INTO courses VALUE (
  0, 
  1, -- Or search a specific lecturer name
  'Advanced teleportation'
);
INSERT INTO courses VALUE (
  0, 
  2, -- Or search a specific lecturer name
  'Comparative Religion'
);
INSERT INTO courses VALUE (
  0, 
  2, -- Or search a specific lecturer name
  'Accounting for Lawyers'
);



CALL add_student('Nils Petter', @student_id);
INSERT INTO StudentsCourses VALUES (@student_id, 1);
INSERT INTO StudentsCourses VALUES (@student_id, 2);
INSERT INTO StudentsCourses VALUES (@student_id, 3);

CALL add_student('Student A', @student_id);
INSERT INTO StudentsCourses VALUES (@student_id, 4);
INSERT INTO StudentsCourses VALUES (@student_id, 5);
INSERT INTO StudentsCourses VALUES (@student_id, 6);

CALL add_student('Student B', @student_id);
INSERT INTO StudentsCourses VALUES (@student_id, 1);
INSERT INTO StudentsCourses VALUES (@student_id, 3);
INSERT INTO StudentsCourses VALUES (@student_id, 5);
INSERT INTO StudentsCourses VALUES (@student_id, 7);

CALL add_student('Malin', @student_id);
INSERT INTO StudentsCourses VALUES (@student_id, 2);
INSERT INTO StudentsCourses VALUES (@student_id, 4);
INSERT INTO StudentsCourses VALUES (@student_id, 6);
INSERT INTO StudentsCourses VALUES (@student_id, 8);


-- Insert some rooms
INSERT INTO rooms VALUES (
  0, 
  2,
  'A'
);
INSERT INTO rooms VALUES (
  0, 
  4,
  'A'
);
INSERT INTO rooms VALUES (
  0, 
  4,
  'A'
);
INSERT INTO rooms VALUES (
  0, 
  2,
  'B'
);


-- Setup some course bookings
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  1,
  '2024-01-01',
  8,
  12,
  'Just some stuff'
);
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  2,
  '2024-01-01',
  12,
  14,
  'Today we are doing something'
);
INSERT INTO bookings VALUES (
  0,
  1,
  1,
  null,
  '2024-01-02',
  8,
  12,
  'Just some stuff'
);