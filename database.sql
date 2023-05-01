DROP DATABASE IF EXISTS project;
CREATE DATABASE project;
USE project;

DROP PROCEDURE IF EXISTS delete_users;
DELIMITER //
CREATE PROCEDURE delete_users()
BEGIN
  DECLARE username CHAR(255);
  DECLARE done INT DEFAULT FALSE;

  DECLARE cur1 CURSOR FOR SELECT user FROM mysql.user WHERE host = "localhost";
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;

  my_loop: LOOP
    FETCH cur1 INTO username;
	IF done THEN
      LEAVE my_loop;
    END IF;
    
    IF username NOT IN ('mysql.sys', 'mysql.infoschema', 'mysql.session', 'root') THEN 
    	SET @sql = CONCAT('DROP USER IF EXISTS "', username, '"@"localhost";');
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
    END IF;
    
  END LOOP;

  CLOSE cur1;
  
  DROP ROLE IF EXISTS "student";
  DROP ROLE IF EXISTS "lecturer";
END //
DELIMITER ;
CALL delete_users();


CREATE ROLE "student";
CREATE ROLE "lecturer";

-- Common definition for users.
CREATE TABLE users (
  id int NOT NULL UNIQUE AUTO_INCREMENT,
  PRIMARY KEY (id),
  
  -- MySQL limits usernames to 32 size
  username varchar(32) NOT NULL UNIQUE,
  name varchar(255) NOT NULL CHECK (LENGTH(name) != 0)
);

GRANT SELECT ON users TO "lecturer";

DELIMITER //
CREATE FUNCTION username_exists(username VARCHAR(32)) 
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    SET @count := 0;
    SELECT COUNT(*) INTO @count
    FROM users
    WHERE users.username = username;
	
    IF @count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION userid_from_username(username VARCHAR(32)) 
RETURNS INT
READS SQL DATA
BEGIN
    SET @id := 0;
    SELECT id INTO @id
    FROM users
    WHERE users.username = username
	LIMIT 1;
	
    RETURN @id;
END //
DELIMITER ;




-- Procedure for adding a new user account
-- and also inserting it into the 'users' table.
DELIMITER //
CREATE PROCEDURE add_user(IN real_name varchar(255), IN username varchar(32), OUT user_id INT)
MODIFIES SQL DATA
BEGIN
	-- First some input validation
	IF real_name IS NULL OR username IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NULL is not allowed.';
	END IF;
	if real_name = "" OR username = "" THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empty name is not allowed.';	
	END IF;	
	IF username_exists(username) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username already exists.';
	END IF;


	-- Create the user account for this user ID.
	-- In a real scenario, we would also have to generate a password.
	SET @sql = CONCAT('CREATE USER "', username, '"@"localhost";');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	
	INSERT INTO users VALUES (0, CONCAT(username, "@localhost"), real_name);
	SET user_id = LAST_INSERT_ID();
END //
DELIMITER ;





-- Definiton for students. Specialization of user.
CREATE TABLE students (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DELIMITER //
CREATE PROCEDURE add_student(IN real_name varchar(255), IN username varchar(32), OUT student_id INT)
MODIFIES SQL DATA
BEGIN
	CALL add_user(real_name, username, @user_id);
	
	SET @sql = CONCAT('GRANT "student" TO "', username, '"@"localhost";');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	
	SET @sql = CONCAT('SET DEFAULT ROLE "student" TO "', username, '"@"localhost";');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	
	INSERT INTO students VALUES (@user_id);
	SET student_id = @user_id;
END //
DELIMITER ;
-- Helpful view to see students with more readable info.
CREATE VIEW students_info AS
SELECT students.user_id, users.name, users.username
FROM students JOIN users ON students.user_id = users.id;







-- Definition for lecturers. Specialization of user.
CREATE TABLE lecturers (
  user_id int NOT NULL UNIQUE,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  
  institute varchar(255) NOT NULL CHECK(LENGTH(institute) != 0)
);

DELIMITER //
CREATE PROCEDURE add_lecturer(IN real_name varchar(255), IN username varchar(32), IN institute varchar(255), OUT lecturer_id INT)
MODIFIES SQL DATA
BEGIN
	CALL add_user(real_name, username, @user_id);
	
	-- Grant the lecturer role
	SET @sql = CONCAT('GRANT "lecturer" TO "', username, '"@"localhost";');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	FLUSH PRIVILEGES;
	
	-- Set the default role for the new user
	SET @sql = CONCAT('SET DEFAULT ROLE "lecturer" TO "', username, '"@"localhost";');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    INSERT INTO lecturers VALUES (@user_id, institute);
	SET lecturer_id = @user_id;
END //
DELIMITER ;
-- Helpful view to see lecturers with more readable info.
CREATE VIEW lecturers_info AS
SELECT lecturers.user_id, users.name, users.username, lecturers.institute
FROM lecturers JOIN users ON lecturers.user_id = users.id;


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
  lecturer_id int,
  FOREIGN KEY (lecturer_id) REFERENCES lecturers(user_id),
  
  name varchar(255) NOT NULL CHECK(LENGTH(name) != 0)
);
-- Helpful view to see courses with more readable info.
CREATE VIEW courses_info AS
SELECT 
	courses.id AS course_id, 
	courses.name AS course_name, 
	lecturers_info.user_id AS lecturer_id,
	lecturers_info.name AS lecturer_name
FROM courses
LEFT JOIN lecturers_info ON courses.lecturer_id = lecturers_info.user_id;

GRANT SELECT ON courses_info TO 'student';
GRANT SELECT ON courses_info TO 'lecturer';

DELIMITER //
CREATE PROCEDURE courses_for_lecturer(IN lecturer_id INT)
READS SQL DATA
BEGIN
	IF lecturer_id IS NULL THEN
		SELECT * FROM courses_info WHERE courses_info.lecturer_id IS NULL;
	ELSE
		SELECT * FROM courses_info WHERE courses_info.lecturer_id = lecturer_id;
	END IF;
END //
DELIMITER ;
GRANT EXECUTE ON PROCEDURE courses_for_lecturer TO 'student';
GRANT EXECUTE ON PROCEDURE courses_for_lecturer TO 'lecturer';

DELIMITER //
CREATE FUNCTION lecturer_has_course(lecturer_id int, course_id int)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
	RETURN course_id IN (
		SELECT courses.id 
		FROM courses 
		WHERE courses.lecturer_id = lecturer_id);
END //
DELIMITER ;





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
  end_hour INT NOT NULL CHECK(end_hour >= 0 AND end_hour < 24),
  CONSTRAINT CHECK(end_hour > start_hour),
  
  description varchar(255) NOT NULL
);
GRANT SELECT ON bookings TO 'lecturer';

-- Helpful view to see bookings with more readable info.
CREATE VIEW bookings_info AS
SELECT room_id, booking_date, start_hour, end_hour, description, courses.name AS course_name
FROM bookings
LEFT JOIN courses ON bookings.course_id = courses.id
ORDER BY booking_date;

GRANT SHOW VIEW ON bookings_info TO 'lecturer';


-- Returns true if this booking timeslot is already reserved
DELIMITER //
CREATE FUNCTION is_booking_timeslot_reserved(room_id INT, booking_date DATE, start_hour INT, end_hour INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    SET @count := 0;
    SELECT COUNT(*) INTO @count
    FROM bookings
    WHERE 
	room_id = bookings.room_id AND
	booking_date = bookings.booking_date AND
	((start_hour >= bookings.start_hour AND start_hour < bookings.end_hour) OR
	(end_hour > bookings.start_hour AND end_hour <= bookings.end_hour));
	
    IF @count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE add_booking_admin(
	user_id int, 
	room_id int, 
	course_id int, 
	booking_date date, 
	start_hour int, 
	end_hour int, 
	description varchar(255))
MODIFIES SQL DATA
BEGIN
	-- First check that it is not reserved.
	IF is_booking_timeslot_reserved(room_id, booking_date, start_hour, end_hour) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Timeslot is already reserved.';
	END IF;
	
	INSERT INTO bookings (user_id, room_id, course_id, booking_date, start_hour, end_hour, description)
	VALUES (
		user_id,
		room_id,
		course_id,
		booking_date,
		start_hour,
		end_hour,
		description
	);

END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE add_booking_lecturer(
	room_id int, 
	course_id int, 
	booking_date date, 
	start_hour int, 
	end_hour int, 
	description varchar(255))
MODIFIES SQL DATA
BEGIN
	-- First check that the course id is among the ones the lecturer is assigned to.
	SET @user_id := userid_from_username(user());
	
	IF (course_id IS NOT NULL) AND (NOT lecturer_has_course(@user_id, course_id)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Course not managed by this lecturer.';
	END IF;
	
	CALL add_booking_admin(
		@user_id,
		room_id,
		course_id,
		booking_date,
		start_hour,
		end_hour,
		description);

END //
DELIMITER ;
GRANT EXECUTE ON PROCEDURE add_booking_lecturer TO 'lecturer';








CALL add_lecturer('John Smith', 'jsmith', 'Business Administration', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Ladders');
INSERT INTO courses VALUES (null, @lecturer_id, 'Advanced Breath Holding');

CALL add_lecturer('Mary Brown', 'mbrown', 'Engineering', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Theoretical Phys Ed');
INSERT INTO courses VALUES (null, @lecturer_id, 'Physical Education Education');
INSERT INTO courses VALUES (null, @lecturer_id, 'Class 101');

CALL add_lecturer('David Lee', 'dlee', 'Computer Science', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'The History of Internet Cat Videos');
INSERT INTO courses VALUES (null, @lecturer_id, 'Feline Algebra');
INSERT INTO courses VALUES (null, @lecturer_id, 'C++ as a first language');
INSERT INTO courses VALUES (null, @lecturer_id, 'Graphics programming');
SET @gfx_course_id = LAST_INSERT_ID();

CALL add_lecturer('Sarah Johnson', 'sjohnson', 'Law', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Sneezing Fundamentals');

CALL add_lecturer('Michael Kim', 'mkim', 'Medicine', @lecturer_id);
INSERT INTO courses VALUES (null, @lecturer_id, 'Food Poisoning 102');

CALL add_lecturer('Jane Doe', 'jdoe', 'Sociology', @lecturer_id);


INSERT INTO courses VALUES (0, null,'Rocket Science for dummies');
INSERT INTO courses VALUES (0, null, 'Advanced teleportation');
INSERT INTO courses VALUES (0, null, 'Intro to Napping 101');
INSERT INTO courses VALUES (0, null, 'The Art of Procrastination');
INSERT INTO courses VALUES (0, null, 'The Fine Art of Water Balloon Warfare');


CALL add_student('Nils Petter', 'nils', @student_id);
CALL add_student('Ava Patel', 'apatel', @student_id);
CALL add_student('Liam Lee', 'llee', @student_id);
CALL add_student('Mia Kim', 'miakim', @student_id);
CALL add_student('Noah Johnson', 'njohnson', @student_id);
CALL add_student('Emma Chen', 'echen', @student_id);
CALL add_student('Aiden Davis', 'adavis', @student_id);
CALL add_student('Olivia Wong', 'owong', @student_id);
CALL add_student('Lucas Singh', 'lsingh', @student_id);
CALL add_student('Isabella Gupta', 'igupta', @student_id);
CALL add_student('Mason Nguyen', 'mnguyen', @student_id);
CALL add_student('Sophia Huang', 'shuang', @student_id);
CALL add_student('Logan Shah', 'lshah', @student_id);
CALL add_student('Harper Das', 'hdas', @student_id);
CALL add_student('Jackson Park', 'jpark', @student_id);


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

CALL add_booking_admin(
	1, 
	1,
	1,
	'2024-01-01',
	8,
	12,
	'First room');
CALL add_booking_admin(
	2, 
	2,
	2,
	'2024-01-01',
	8,
	12,
	'Other room');
CALL add_booking_admin(
	1, 
	2,
	null,
	'2024-01-01',
	12,
	14,
	'First room again');
CALL add_booking_admin(
	1, 
	1,
	null,
	'2024-01-02',
	8,
	14,
	'Next day, first room');