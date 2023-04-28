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
CREATE VIEW students_info AS
SELECT students.user_id, users.name
FROM students JOIN users ON students.user_id = users.id;

CREATE TABLE lecturers (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  institute varchar(255) NOT NULL CHECK(LENGTH(institute) != 0)
);
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

CREATE TABLE students_courses (
  student_id int NOT NULL,
  course_id int NOT NULL,
  PRIMARY KEY (student_id, course_id),
  FOREIGN KEY (student_id) REFERENCES students(user_id),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

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


-- Insert a teacher user
INSERT INTO users VALUES (
  0,
  "Teacher Teacherson"
);
INSERT INTO lecturers VALUES (
  LAST_INSERT_ID(),
  'IT'
);

INSERT INTO users VALUES (
  0, 
  'Teach Teacherman'
);
INSERT INTO lecturers VALUES (
  LAST_INSERT_ID(),
  'IT'
);

INSERT INTO users VALUES (
  0, 
  'Lecturer Lecturerson'
);
INSERT INTO lecturers VALUES (
  LAST_INSERT_ID(),
  'Math'
);

-- Insert some students
INSERT INTO users VALUES (
  0, 
  'Nils Petter'
);
INSERT INTO students VALUES (
  LAST_INSERT_ID()
);

INSERT INTO users VALUES (
  0, 
  'Student A'
);
INSERT INTO students VALUES (
  LAST_INSERT_ID()
);

INSERT INTO users VALUES (
  0, 
  'Student B'
);
INSERT INTO students VALUES (
  LAST_INSERT_ID()
);

INSERT INTO users VALUES (
  0, 
  'Malin'
);
INSERT INTO students VALUES (
  LAST_INSERT_ID()
);


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