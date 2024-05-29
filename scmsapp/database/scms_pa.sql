-- Script to create/recrate all tables and sample data

-- Dropp all tables
SET FOREIGN_KEY_CHECKS = 0;
SET GROUP_CONCAT_MAX_LEN=32768;
SET @tables = NULL;
SELECT GROUP_CONCAT('`', table_name, '`') INTO @tables
  FROM information_schema.tables
  WHERE table_schema = (SELECT DATABASE());
SELECT IFNULL(@tables,'dummy') INTO @tables;
SET @tables = CONCAT('DROP TABLE IF EXISTS ', @tables);
PREPARE stmt FROM @tables;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET FOREIGN_KEY_CHECKS = 1;

-- Craete tables
CREATE TABLE user (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    salt VARCHAR(10) NOT NULL,
    role ENUM('member', 'instructor', 'manager') NOT NULL,
    is_active TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE INDEX username_UNIQUE (username ASC) VISIBLE
);
 
 
 CREATE TABLE member (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(20) NULL,
    first_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    address VARCHAR(255) NULL,
    dob DATE NULL,
    image VARCHAR(255),
    health_info TEXT,
	membership_type ENUM('Monthly', 'Annual', 'None') NULL,
	expired_date DATE NULL,
    is_subscription TINYINT NOT NULL DEFAULT 0,
	UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
    FOREIGN KEY(user_id) REFERENCES user (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
    
    
CREATE TABLE instructor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    profile TEXT,
    image VARCHAR(255),
    UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
    FOREIGN KEY(user_id) REFERENCES user (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE manager (
    id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE,
    FOREIGN KEY(user_id) REFERENCES user (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE class_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
	class_type ENUM('class', '1-on-1', 'group')  NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pool_name VARCHAR(50),
	lane_name VARCHAR(50),
    status TINYINT NOT NULL DEFAULT 1
); 


CREATE TABLE class (
    id INT PRIMARY KEY AUTO_INCREMENT,
	instructor_id INT NOT NULL,
    location_id INT NOT NULL,
    class_type INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
	open_slot INT NOT NULL,
    status TINYINT NOT NULL DEFAULT 1,
    FOREIGN KEY(location_id) REFERENCES location (id),
    FOREIGN KEY(instructor_id) REFERENCES instructor (id),
	FOREIGN KEY(class_type) REFERENCES class_type (id)
);



CREATE TABLE booking (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    class_id INT NOT NULL,
    create_time DATETIME NOT NULL,
    status TINYINT NOT NULL DEFAULT 1, 
    is_attended TINYINT NOT NULL,
    FOREIGN KEY(member_id) REFERENCES member (id),
    FOREIGN KEY(class_id) REFERENCES class (id)
);



CREATE TABLE product (
	id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,
	description VARCHAR(255),
    price DECIMAL NOT NULL
);  



CREATE TABLE payment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    booking_id INT,
	member_id INT NOT NULL,
	total DECIMAL NOT NULL,
	pay_time DATETIME NULL,
    is_paid TINYINT NOT NULL DEFAULT 0,
    FOREIGN KEY(product_id) REFERENCES product (id),
    FOREIGN KEY(booking_id) REFERENCES booking (id),
	FOREIGN KEY(member_id) REFERENCES member (id)
);



CREATE TABLE news (
    id INT PRIMARY KEY AUTO_INCREMENT,
	author INT NOT NULL,
    title VARCHAR(255),
    content TEXT,
    date DATETIME,
	FOREIGN KEY(author) REFERENCES manager(id)
);

-- Create sample data

-- Create 27 users, including 20 members, 5 instructors, and 2 managers
INSERT INTO `user` 
VALUES 
(1,'member1','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(2,'member2','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(3,'member3','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(4,'member4','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(5,'member5','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(6,'member6','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(7,'member7','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(8,'member8','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(9,'member9','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(10,'member10','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(11,'member11','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(12,'member12','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(13,'member13','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(14,'member14','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(15,'member15','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(16,'member16','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(17,'member17','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(18,'member18','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(19,'member19','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(20,'member20','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','member',1),
(21,'instructor1','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','instructor',1),
(22,'instructor2','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','instructor',1),
(23,'instructor3','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','instructor',1),
(24,'instructor4','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','instructor',1),
(25,'instructor5','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','instructor',1),
(26,'manager1','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','manager',1),
(27,'manager2','e2f7bd41e73e34ca5675cb5ec8083a9d19382d4d6e8ae190ff5f8692ff56d2f1','abcd','manager',1);

INSERT INTO member
VALUES
(1, 1, 'Mr', 'John', 'Doe', 'Sales Assistant', '0234567890', 'john.doe@example.com', '123 Main St, Cityville', '1980-05-15', 'john_doe.jpg', 'No known health issues', 'Annual', '2025-05-15', 1),
(2, 2, 'Ms', 'Alice', 'Smith', 'Assistant Admin', '0987654321', 'alice.smith@example.com', '456 Elm St, Townsville', '1990-08-20', 'alice_smith.jpg', 'Allergic to peanuts', 'Monthly', '2024-04-20', 1),
(3, 3, 'Dr', 'Robert', 'Johnson', 'Head of Research', '0122334455', 'robert.johnson@example.com', '789 Oak St, Villagetown', '1975-03-10', 'robert_johnson.jpg', 'Diabetic, requires insulin shots', 'Annual', '2025-03-10', 1),
(4, 4, 'Ms', 'Emily', 'Brown', 'Marketing Coordinator', '0449966330', 'emily.brown@example.com', '101 Pine St, Hamletville', '1988-11-25', 'emily_brown.jpg', 'No known health issues', 'Annual', '2026-11-25', 1),
(5, 5, 'Mr', 'Michael', 'Anderson', 'Sales Representative', '0888777666', 'michael.anderson@example.com', '789 Walnut St, Suburbia', '1983-09-12', 'michael_anderson.jpg', 'High blood pressure, on medication', 'Monthly', '2024-09-12', 1),
(6, 6, 'Ms', 'Sophia', 'Taylor', 'HR Manager', '0555444333', 'sophia.taylor@example.com', '246 Maple St, Villageton', '1977-07-08', 'sophia_taylor.jpg', 'No known health issues', 'Annual', '2026-07-08', 1),
(7, 7, 'Mr', 'William', 'Martinez', 'IT Specialist', '0666777888', 'william.martinez@example.com', '369 Oak St, Suburbia', '1986-02-28', 'william_martinez.jpg', 'No known health issues', 'Annual', '2025-02-28', 1),
(8, 8, 'Mrs', 'Elizabeth', 'Garcia', 'Financial Analyst', '0777888999', 'elizabeth.garcia@example.com', '753 Pine St, Cityville', '1992-04-18', 'elizabeth_garcia.jpg', 'No known health issues', 'Monthly', '2024-04-07', 1),
(9, 9, 'Mr', 'Daniel', 'Rodriguez', 'Project Manager', '0888999000', 'daniel.rodriguez@example.com', '963 Elm St, Hamletville', '1982-10-30', 'daniel_rodriguez.jpg', 'No known health issues', 'Annual', '2025-10-30', 1),
(10, 10, 'Ms', 'Olivia', 'Lopez', 'Graphic Designer', '0999000111', 'olivia.lopez@example.com', '147 Oak St, Townsville', '1989-06-05', 'olivia_lopez.jpg', 'No known health issues', 'Monthly', '2024-06-05', 1),
(11, 11, 'Mr', 'James', 'Hernandez', 'Customer Service Representative', '0555123456', 'james.hernandez@example.com', '258 Pine St, Villagetown', '1974-12-20', 'james_hernandez.jpg', 'No known health issues', 'Annual', '2025-12-20', 1),
(12, 12, 'Ms', 'Emma', 'Gonzalez', 'Event Coordinator', '0444555666', 'emma.gonzalez@example.com', '369 Maple St, Cityville', '1995-01-15', 'emma_gonzalez.jpg', 'No known health issues', 'None', '2024-01-15', 0),
(13, 13, 'Dr', 'Liam', 'Perez', 'Lead Scientist', '0333444555', 'liam.perez@example.com', '852 Elm St, Suburbia', '1981-08-25', 'liam_perez.jpg', 'Allergic to shellfish', 'Annual', '2026-08-25', 1),
(14, 14, 'Ms', 'Ava', 'Torres', 'Public Relations Manager', '0222333444', 'ava.torres@example.com', '963 Oak St, Hamletville', '1984-05-30', 'ava_torres.jpg', 'No known health issues', 'Monthly', '2024-05-30', 1),
(15, 15, 'Mr', 'Mason', 'Rivera', 'Sales Manager', '0666777888', 'mason.rivera@example.com', '147 Walnut St, Townsville', '1987-03-07', 'mason_rivera.jpg', 'No known health issues', 'Annual', '2025-03-07', 1),
(16, 16, 'Mrs', 'Harper', 'Scott', 'Operations Manager', '0555666777', 'harper.scott@example.com', '258 Pine St, Villagetown', '1976-11-10', 'harper_scott.jpg', 'No known health issues', 'Annual', '2025-11-10', 1),
(17, 17, 'Mr', 'Ethan', 'Nguyen', 'Software Engineer', '0444555666', 'ethan.nguyen@example.com', '369 Maple St, Cityville', '1980-02-14', 'ethan_nguyen.jpg', 'No known health issues', 'None', '2024-02-14', 0),
(18, 18, 'Ms', 'Isabella', 'Gomez', 'Marketing Manager', '0333666777', 'isabella.gomez@example.com', '852 Elm St, Suburbia', '1983-09-22', 'isabella_gomez.jpg', 'No known health issues', 'Annual', '2026-09-22', 1),
(19, 19, 'Mr', 'Alexander', 'Reyes', 'Product Manager', '0222333444', 'alexander.reyes@example.com', '963 Oak St, Hamletville', '1979-07-18', 'alexander_reyes.jpg', 'No known health issues', 'Monthly', '2024-07-18', 1),
(20, 20, 'Ms', 'Sofia', 'Morgan', 'HR Coordinator', '0666777888', 'sofia.morgan@example.com', '369 Elm St, Hamletville', '1984-08-12', 'sofia_morgan.jpg', 'No known health issues', 'Monthly', '2024-08-12', 1);

INSERT INTO `instructor` 
VALUES 
(1,21,'Mr','Alexander','Smith','Lead Swim Instructor','0234567890','alexander.smith@example.com','Experienced swim instructor specializing in stroke technique and advanced training methods.','alexander_smith.jpg'),
(2,22,'Mrs','Victoria','Johnson','Senior Swim Instructor','0987654321','victoria.johnson@example.com','Passionate swim coach with expertise in teaching all age groups from beginners to competitive swimmers.','victoria_johnson.jpg'),
(3,23,'Dr','Christopher','Williams','Swim Instructor','0122334455','christopher.williams@example.com','Dedicated swim instructor with a focus on water safety and building confidence in swimmers.','christopher_williams.jpg'),
(4,24,'Ms','Sophia','Brown','Assistant Swim Instructor','05550998877','sophia.brown@example.com','Creative swim instructor experienced in teaching swimming fundamentals and introducing new aquatic activities.','sophia_brown.jpg'),
(5,25,'Mr','Daniel','Garcia','Junior Swim Instructor','04444777444','daniel.garcia@example.com','Enthusiastic swim instructor with a passion for teaching children and beginners.','daniel_garcia.jpg');

INSERT INTO `manager` 
VALUES 
(1,26,'Mr','Michaell','Anderson','General Manager','0234567890','michael.anderson@example.com'),
(2,27,'Ms','Emily','Wilson','Assistant Manager','0987654321','emily.wilson@example.com');


-- Create 4 class types and 5 1-on-1 lesson types
INSERT INTO class_type (id, class_type, class_name, description)
VALUES
(1, 'class', 'Zumba', 'Aqua aerobics class with dance-based exercises.'),
(2, 'class', 'Aqua Fit', 'Aqua aerobics class focusing on overall fitness and strength training'),
(3, 'class', 'Low-Impact', 'Gentle aqua aerobics class designed for individuals seeking low-impact exercise options, suitable for all fitness levels.'),
(4, 'class', 'Mums and Babies', 'Specialized aqua aerobics class tailored for new mothers and their babies, incorporating gentle exercises for both mom and baby to enjoy together.'),
(5, '1-on-1', 'Junior', '1-on-1 swimming lessons tailored for junior swimmers.'),
(6, '1-on-1', 'Advanced', 'Advanced level 1-on-1 swimming lessons for experienced swimmers.'),
(7, '1-on-1', 'Beginner', 'Personalized one-on-one swimming lessons designed for beginners to learn basic swimming techniques and water safety skills.'),
(8, '1-on-1', 'Stroke Correction', 'Individualized one-on-one sessions focusing on correcting specific swimming strokes and techniques for improved efficiency and performance.'),
(9, '1-on-1', 'Triathlon Training', 'Tailored one-on-one training sessions specifically designed to prepare athletes for triathlon competitions, focusing on swimming techniques, endurance, and transition strategies.');



-- Create locations, 1 deep pool and 1 lane pool with 10 lanes
INSERT INTO location (id, pool_name, lane_name, status)
VALUES
(1, 'Deep Pool', NULL, 1),
(2, 'Lane Pool', 'Lane 1', 1),
(3, 'Lane Pool', 'Lane 2', 1),
(4, 'Lane Pool', 'Lane 3', 1),
(5, 'Lane Pool', 'Lane 4', 1),
(6, 'Lane Pool', 'Lane 5', 1),
(7, 'Lane Pool', 'Lane 6', 1),
(8, 'Lane Pool', 'Lane 7', 1),
(9, 'Lane Pool', 'Lane 8', 1),
(10, 'Lane Pool', 'Lane 9', 1),
(11, 'Lane Pool', 'Lane 10', 1);

-- Create products
INSERT INTO product (id, product_name, description, price)
VALUES
(1, 'Monthly Subscription', 'Access to all club facilities for one month.', 60.00),
(2, 'Annual Subscription', 'Access to all club facilities for one year.', 700.00),
(3, 'Class', 'Participation in a group class.', 0.00),
(4, '1-on-1 Lesson', 'One-on-one swimming lesson with an instructor.', 50.00);

-- Creat classes and lessons for all 9 types from 2024-02-01 to 2024-05-12:
INSERT INTO class (id, instructor_id, location_id, class_type, start_time, end_time, open_slot, status) VALUES
(1, 1, 1, 1, '2024-02-01 17:00:00', '2024-02-01 18:00:00', 15, 1),
(2, 1, 1, 1, '2024-02-06 17:00:00', '2024-02-06 18:00:00', 15, 1),
(3, 1, 1, 1, '2024-02-08 17:00:00', '2024-02-08 18:00:00', 15, 1),
(4, 1, 1, 1, '2024-02-13 17:00:00', '2024-02-13 18:00:00', 15, 1),
(5, 1, 1, 1, '2024-02-15 17:00:00', '2024-02-15 18:00:00', 15, 1),
(6, 1, 1, 1, '2024-02-20 17:00:00', '2024-02-20 18:00:00', 15, 1),
(7, 1, 1, 1, '2024-02-22 17:00:00', '2024-02-22 18:00:00', 15, 1),
(8, 1, 1, 1, '2024-02-27 17:00:00', '2024-02-27 18:00:00', 15, 1),
(9, 1, 1, 1, '2024-02-29 17:00:00', '2024-02-29 18:00:00', 15, 1),
(10, 1, 1, 1, '2024-03-05 17:00:00', '2024-03-05 18:00:00', 15, 1),
(11, 1, 1, 1, '2024-03-07 17:00:00', '2024-03-07 18:00:00', 15, 1),
(12, 1, 1, 1, '2024-03-12 17:00:00', '2024-03-12 18:00:00', 15, 1),
(13, 1, 1, 1, '2024-03-14 17:00:00', '2024-03-14 18:00:00', 15, 1),
(14, 1, 1, 1, '2024-03-19 17:00:00', '2024-03-19 18:00:00', 15, 1),
(15, 1, 1, 1, '2024-03-21 17:00:00', '2024-03-21 18:00:00', 15, 1),
(16, 1, 1, 1, '2024-03-26 17:00:00', '2024-03-26 18:00:00', 15, 1),
(17, 1, 1, 1, '2024-03-28 17:00:00', '2024-03-28 18:00:00', 15, 1),
(18, 1, 1, 1, '2024-04-02 17:00:00', '2024-04-02 18:00:00', 15, 1),
(19, 1, 1, 1, '2024-04-04 17:00:00', '2024-04-04 18:00:00', 15, 1),
(20, 1, 1, 1, '2024-04-09 17:00:00', '2024-04-09 18:00:00', 15, 1),
(21, 1, 1, 1, '2024-04-11 17:00:00', '2024-04-11 18:00:00', 15, 1),
(22, 1, 1, 1, '2024-04-16 17:00:00', '2024-04-16 18:00:00', 15, 1),
(23, 1, 1, 1, '2024-04-18 17:00:00', '2024-04-18 18:00:00', 15, 1),
(24, 1, 1, 1, '2024-04-23 17:00:00', '2024-04-23 18:00:00', 15, 1),
(25, 1, 1, 1, '2024-04-25 17:00:00', '2024-04-25 18:00:00', 15, 1),
(26, 1, 1, 1, '2024-04-30 17:00:00', '2024-04-30 18:00:00', 15, 1),
(27, 1, 1, 1, '2024-05-02 17:00:00', '2024-05-02 18:00:00', 15, 1),
(28, 1, 1, 1, '2024-05-07 17:00:00', '2024-05-07 18:00:00', 15, 1),
(29, 1, 1, 1, '2024-05-09 17:00:00', '2024-05-09 18:00:00', 15, 1),
(30, 2, 1, 2, '2024-02-03 15:00:00', '2024-02-03 16:00:00', 15, 1),
(31, 2, 1, 2, '2024-02-04 15:00:00', '2024-02-04 16:00:00', 15, 1),
(32, 2, 1, 2, '2024-02-10 15:00:00', '2024-02-10 16:00:00', 15, 1),
(33, 2, 1, 2, '2024-02-11 15:00:00', '2024-02-11 16:00:00', 15, 1),
(34, 2, 1, 2, '2024-02-17 15:00:00', '2024-02-17 16:00:00', 15, 1),
(35, 2, 1, 2, '2024-02-18 15:00:00', '2024-02-18 16:00:00', 15, 1),
(36, 2, 1, 2, '2024-02-24 15:00:00', '2024-02-24 16:00:00', 15, 1),
(37, 2, 1, 2, '2024-02-25 15:00:00', '2024-02-25 16:00:00', 15, 1),
(38, 2, 1, 2, '2024-03-02 15:00:00', '2024-03-02 16:00:00', 15, 1),
(39, 2, 1, 2, '2024-03-03 15:00:00', '2024-03-03 16:00:00', 15, 1),
(40, 2, 1, 2, '2024-03-09 15:00:00', '2024-03-09 16:00:00', 15, 1),
(41, 2, 1, 2, '2024-03-10 15:00:00', '2024-03-10 16:00:00', 15, 1),
(42, 2, 1, 2, '2024-03-16 15:00:00', '2024-03-16 16:00:00', 15, 1),
(43, 2, 1, 2, '2024-03-17 15:00:00', '2024-03-17 16:00:00', 15, 1),
(44, 2, 1, 2, '2024-03-23 15:00:00', '2024-03-23 16:00:00', 15, 1),
(45, 2, 1, 2, '2024-03-24 15:00:00', '2024-03-24 16:00:00', 15, 1),
(46, 2, 1, 2, '2024-03-30 15:00:00', '2024-03-30 16:00:00', 15, 1),
(47, 2, 1, 2, '2024-03-31 15:00:00', '2024-03-31 16:00:00', 15, 1),
(48, 2, 1, 2, '2024-04-06 15:00:00', '2024-04-06 16:00:00', 15, 1),
(49, 2, 1, 2, '2024-04-07 15:00:00', '2024-04-07 16:00:00', 15, 1),
(50, 2, 1, 2, '2024-04-13 15:00:00', '2024-04-13 16:00:00', 15, 1),
(51, 2, 1, 2, '2024-04-14 15:00:00', '2024-04-14 16:00:00', 15, 1),
(52, 2, 1, 2, '2024-04-20 15:00:00', '2024-04-20 16:00:00', 15, 1),
(53, 2, 1, 2, '2024-04-21 15:00:00', '2024-04-21 16:00:00', 15, 1),
(54, 2, 1, 2, '2024-04-27 15:00:00', '2024-04-27 16:00:00', 15, 1),
(55, 2, 1, 2, '2024-04-28 15:00:00', '2024-04-28 16:00:00', 15, 1),
(56, 2, 1, 2, '2024-05-04 15:00:00', '2024-05-04 16:00:00', 15, 1),
(57, 2, 1, 2, '2024-05-05 15:00:00', '2024-05-05 16:00:00', 15, 1),
(58, 2, 1, 2, '2024-05-11 15:00:00', '2024-05-11 16:00:00', 15, 1),
(59, 2, 1, 2, '2024-05-12 15:00:00', '2024-05-12 16:00:00', 15, 1),
(60, 3, 1, 3, '2024-02-03 19:00:00', '2024-02-03 20:00:00', 15, 1),
(61, 3, 1, 3, '2024-02-06 19:00:00', '2024-02-06 20:00:00', 15, 1),
(62, 3, 1, 3, '2024-02-10 19:00:00', '2024-02-10 20:00:00', 15, 1),
(63, 3, 1, 3, '2024-02-13 19:00:00', '2024-02-13 20:00:00', 15, 1),
(64, 3, 1, 3, '2024-02-17 19:00:00', '2024-02-17 20:00:00', 15, 1),
(65, 3, 1, 3, '2024-02-20 19:00:00', '2024-02-20 20:00:00', 15, 1),
(66, 3, 1, 3, '2024-02-24 19:00:00', '2024-02-24 20:00:00', 15, 1),
(67, 3, 1, 3, '2024-02-27 19:00:00', '2024-02-27 20:00:00', 15, 1),
(68, 3, 1, 3, '2024-03-02 19:00:00', '2024-03-02 20:00:00', 15, 1),
(69, 3, 1, 3, '2024-03-05 19:00:00', '2024-03-05 20:00:00', 15, 1),
(70, 3, 1, 3, '2024-03-09 19:00:00', '2024-03-09 20:00:00', 15, 1),
(71, 3, 1, 3, '2024-03-12 19:00:00', '2024-03-12 20:00:00', 15, 1),
(72, 3, 1, 3, '2024-03-16 19:00:00', '2024-03-16 20:00:00', 15, 1),
(73, 3, 1, 3, '2024-03-19 19:00:00', '2024-03-19 20:00:00', 15, 1),
(74, 3, 1, 3, '2024-03-23 19:00:00', '2024-03-23 20:00:00', 15, 1),
(75, 3, 1, 3, '2024-03-26 19:00:00', '2024-03-26 20:00:00', 15, 1),
(76, 3, 1, 3, '2024-03-30 19:00:00', '2024-03-30 20:00:00', 15, 1),
(77, 3, 1, 3, '2024-04-02 19:00:00', '2024-04-02 20:00:00', 15, 1),
(78, 3, 1, 3, '2024-04-06 19:00:00', '2024-04-06 20:00:00', 15, 1),
(79, 3, 1, 3, '2024-04-09 19:00:00', '2024-04-09 20:00:00', 15, 1),
(80, 3, 1, 3, '2024-04-13 19:00:00', '2024-04-13 20:00:00', 15, 1),
(81, 3, 1, 3, '2024-04-16 19:00:00', '2024-04-16 20:00:00', 15, 1),
(82, 3, 1, 3, '2024-04-20 19:00:00', '2024-04-20 20:00:00', 15, 1),
(83, 3, 1, 3, '2024-04-23 19:00:00', '2024-04-23 20:00:00', 15, 1),
(84, 3, 1, 3, '2024-04-27 19:00:00', '2024-04-27 20:00:00', 15, 1),
(85, 3, 1, 3, '2024-04-30 19:00:00', '2024-04-30 20:00:00', 15, 1),
(86, 3, 1, 3, '2024-05-04 19:00:00', '2024-05-04 20:00:00', 15, 1),
(87, 3, 1, 3, '2024-05-07 19:00:00', '2024-05-07 20:00:00', 15, 1),
(88, 3, 1, 3, '2024-05-11 19:00:00', '2024-05-11 20:00:00', 15, 1),
(89, 1, 1, 4, '2024-02-01 11:00:00', '2024-02-01 12:00:00', 15, 1),
(90, 1, 1, 4, '2024-02-08 11:00:00', '2024-02-08 12:00:00', 15, 1),
(91, 1, 1, 4, '2024-02-15 11:00:00', '2024-02-15 12:00:00', 15, 1),
(92, 1, 1, 4, '2024-02-22 11:00:00', '2024-02-22 12:00:00', 15, 1),
(93, 1, 1, 4, '2024-02-29 11:00:00', '2024-02-29 12:00:00', 15, 1),
(94, 1, 1, 4, '2024-03-07 11:00:00', '2024-03-07 12:00:00', 15, 1),
(95, 1, 1, 4, '2024-03-14 11:00:00', '2024-03-14 12:00:00', 15, 1),
(96, 1, 1, 4, '2024-03-21 11:00:00', '2024-03-21 12:00:00', 15, 1),
(97, 1, 1, 4, '2024-03-28 11:00:00', '2024-03-28 12:00:00', 15, 1),
(98, 1, 1, 4, '2024-04-04 11:00:00', '2024-04-04 12:00:00', 15, 1),
(99, 1, 1, 4, '2024-04-11 11:00:00', '2024-04-11 12:00:00', 15, 1),
(100, 1, 1, 4, '2024-04-18 11:00:00', '2024-04-18 12:00:00', 15, 1),
(101, 1, 1, 4, '2024-04-25 11:00:00', '2024-04-25 12:00:00', 15, 1),
(102, 1, 1, 4, '2024-05-02 11:00:00', '2024-05-02 12:00:00', 15, 1),
(103, 1, 1, 4, '2024-05-09 11:00:00', '2024-05-09 12:00:00', 15, 1),
(104, 4, 2, 5, '2024-02-03 9:00:00', '2024-02-03 9:30:00', 1, 1),
(105, 4, 2, 5, '2024-02-04 9:00:00', '2024-02-04 9:30:00', 1, 1),
(106, 4, 2, 5, '2024-02-10 9:00:00', '2024-02-10 9:30:00', 1, 1),
(107, 4, 2, 5, '2024-02-11 9:00:00', '2024-02-11 9:30:00', 1, 1),
(108, 4, 2, 5, '2024-02-17 9:00:00', '2024-02-17 9:30:00', 1, 1),
(109, 4, 2, 5, '2024-02-18 9:00:00', '2024-02-18 9:30:00', 1, 1),
(110, 4, 2, 5, '2024-02-24 9:00:00', '2024-02-24 9:30:00', 1, 1),
(111, 4, 2, 5, '2024-02-25 9:00:00', '2024-02-25 9:30:00', 1, 1),
(112, 4, 2, 5, '2024-03-02 9:00:00', '2024-03-02 9:30:00', 1, 1),
(113, 4, 2, 5, '2024-03-03 9:00:00', '2024-03-03 9:30:00', 1, 1),
(114, 4, 2, 5, '2024-03-09 9:00:00', '2024-03-09 9:30:00', 1, 1),
(115, 4, 2, 5, '2024-03-10 9:00:00', '2024-03-10 9:30:00', 1, 1),
(116, 4, 2, 5, '2024-03-16 9:00:00', '2024-03-16 9:30:00', 1, 1),
(117, 4, 2, 5, '2024-03-17 9:00:00', '2024-03-17 9:30:00', 1, 1),
(118, 4, 2, 5, '2024-03-23 9:00:00', '2024-03-23 9:30:00', 1, 1),
(119, 4, 2, 5, '2024-03-24 9:00:00', '2024-03-24 9:30:00', 1, 1),
(120, 4, 2, 5, '2024-03-30 9:00:00', '2024-03-30 9:30:00', 1, 1),
(121, 4, 2, 5, '2024-03-31 9:00:00', '2024-03-31 9:30:00', 1, 1),
(122, 4, 2, 5, '2024-04-06 9:00:00', '2024-04-06 9:30:00', 1, 1),
(123, 4, 2, 5, '2024-04-07 9:00:00', '2024-04-07 9:30:00', 1, 1),
(124, 4, 2, 5, '2024-04-13 9:00:00', '2024-04-13 9:30:00', 1, 1),
(125, 4, 2, 5, '2024-04-14 9:00:00', '2024-04-14 9:30:00', 1, 1),
(126, 4, 2, 5, '2024-04-20 9:00:00', '2024-04-20 9:30:00', 1, 1),
(127, 4, 2, 5, '2024-04-21 9:00:00', '2024-04-21 9:30:00', 1, 1),
(128, 4, 2, 5, '2024-04-27 9:00:00', '2024-04-27 9:30:00', 1, 1),
(129, 4, 2, 5, '2024-04-28 9:00:00', '2024-04-28 9:30:00', 1, 1),
(130, 4, 2, 5, '2024-05-04 9:00:00', '2024-05-04 9:30:00', 1, 1),
(131, 4, 2, 5, '2024-05-05 9:00:00', '2024-05-05 9:30:00', 1, 1),
(132, 4, 2, 5, '2024-05-11 9:00:00', '2024-05-11 9:30:00', 1, 1),
(133, 4, 2, 5, '2024-05-12 9:00:00', '2024-05-12 9:30:00', 1, 1),
(134, 5, 3, 6, '2024-02-02 17:00:00', '2024-02-02 17:30:00', 1, 1),
(135, 5, 3, 6, '2024-02-09 17:00:00', '2024-02-09 17:30:00', 1, 1),
(136, 5, 3, 6, '2024-02-16 17:00:00', '2024-02-16 17:30:00', 1, 1),
(137, 5, 3, 6, '2024-02-23 17:00:00', '2024-02-23 17:30:00', 1, 1),
(138, 5, 3, 6, '2024-03-01 17:00:00', '2024-03-01 17:30:00', 1, 1),
(139, 5, 3, 6, '2024-03-08 17:00:00', '2024-03-08 17:30:00', 1, 1),
(140, 5, 3, 6, '2024-03-15 17:00:00', '2024-03-15 17:30:00', 1, 1),
(141, 5, 3, 6, '2024-03-22 17:00:00', '2024-03-22 17:30:00', 1, 1),
(142, 5, 3, 6, '2024-03-29 17:00:00', '2024-03-29 17:30:00', 1, 1),
(143, 5, 3, 6, '2024-04-05 17:00:00', '2024-04-05 17:30:00', 1, 1),
(144, 5, 3, 6, '2024-04-12 17:00:00', '2024-04-12 17:30:00', 1, 1),
(145, 5, 3, 6, '2024-04-19 17:00:00', '2024-04-19 17:30:00', 1, 1),
(146, 5, 3, 6, '2024-04-26 17:00:00', '2024-04-26 17:30:00', 1, 1),
(147, 5, 3, 6, '2024-05-03 17:00:00', '2024-05-03 17:30:00', 1, 1),
(148, 5, 3, 6, '2024-05-10 17:00:00', '2024-05-10 17:30:00', 1, 1),
(149, 5, 3, 7, '2024-02-03 9:00:00', '2024-02-03 9:30:00', 1, 1),
(150, 5, 3, 7, '2024-02-06 9:00:00', '2024-02-06 9:30:00', 1, 1),
(151, 5, 3, 7, '2024-02-10 9:00:00', '2024-02-10 9:30:00', 1, 1),
(152, 5, 3, 7, '2024-02-13 9:00:00', '2024-02-13 9:30:00', 1, 1),
(153, 5, 3, 7, '2024-02-17 9:00:00', '2024-02-17 9:30:00', 1, 1),
(154, 5, 3, 7, '2024-02-20 9:00:00', '2024-02-20 9:30:00', 1, 1),
(155, 5, 3, 7, '2024-02-24 9:00:00', '2024-02-24 9:30:00', 1, 1),
(156, 5, 3, 7, '2024-02-27 9:00:00', '2024-02-27 9:30:00', 1, 1),
(157, 5, 3, 7, '2024-03-02 9:00:00', '2024-03-02 9:30:00', 1, 1),
(158, 5, 3, 7, '2024-03-05 9:00:00', '2024-03-05 9:30:00', 1, 1),
(159, 5, 3, 7, '2024-03-09 9:00:00', '2024-03-09 9:30:00', 1, 1),
(160, 5, 3, 7, '2024-03-12 9:00:00', '2024-03-12 9:30:00', 1, 1),
(161, 5, 3, 7, '2024-03-16 9:00:00', '2024-03-16 9:30:00', 1, 1),
(162, 5, 3, 7, '2024-03-19 9:00:00', '2024-03-19 9:30:00', 1, 1),
(163, 5, 3, 7, '2024-03-23 9:00:00', '2024-03-23 9:30:00', 1, 1),
(164, 5, 3, 7, '2024-03-26 9:00:00', '2024-03-26 9:30:00', 1, 1),
(165, 5, 3, 7, '2024-03-30 9:00:00', '2024-03-30 9:30:00', 1, 1),
(166, 5, 3, 7, '2024-04-02 9:00:00', '2024-04-02 9:30:00', 1, 1),
(167, 5, 3, 7, '2024-04-06 9:00:00', '2024-04-06 9:30:00', 1, 1),
(168, 5, 3, 7, '2024-04-09 9:00:00', '2024-04-09 9:30:00', 1, 1),
(169, 5, 3, 7, '2024-04-13 9:00:00', '2024-04-13 9:30:00', 1, 1),
(170, 5, 3, 7, '2024-04-16 9:00:00', '2024-04-16 9:30:00', 1, 1),
(171, 5, 3, 7, '2024-04-20 9:00:00', '2024-04-20 9:30:00', 1, 1),
(172, 5, 3, 7, '2024-04-23 9:00:00', '2024-04-23 9:30:00', 1, 1),
(173, 5, 3, 7, '2024-04-27 9:00:00', '2024-04-27 9:30:00', 1, 1),
(174, 5, 3, 7, '2024-04-30 9:00:00', '2024-04-30 9:30:00', 1, 1),
(175, 5, 3, 7, '2024-05-04 9:00:00', '2024-05-04 9:30:00', 1, 1),
(176, 5, 3, 7, '2024-05-07 9:00:00', '2024-05-07 9:30:00', 1, 1),
(177, 5, 3, 7, '2024-05-11 9:00:00', '2024-05-11 9:30:00', 1, 1),
(178, 2, 4, 8, '2024-02-04 13:00:00', '2024-02-04 13:30:00', 1, 1),
(179, 2, 4, 8, '2024-02-11 13:00:00', '2024-02-11 13:30:00', 1, 1),
(180, 2, 4, 8, '2024-02-18 13:00:00', '2024-02-18 13:30:00', 1, 1),
(181, 2, 4, 8, '2024-02-25 13:00:00', '2024-02-25 13:30:00', 1, 1),
(182, 2, 4, 8, '2024-03-03 13:00:00', '2024-03-03 13:30:00', 1, 1),
(183, 2, 4, 8, '2024-03-10 13:00:00', '2024-03-10 13:30:00', 1, 1),
(184, 2, 4, 8, '2024-03-17 13:00:00', '2024-03-17 13:30:00', 1, 1),
(185, 2, 4, 8, '2024-03-24 13:00:00', '2024-03-24 13:30:00', 1, 1),
(186, 2, 4, 8, '2024-03-31 13:00:00', '2024-03-31 13:30:00', 1, 1),
(187, 2, 4, 8, '2024-04-07 13:00:00', '2024-04-07 13:30:00', 1, 1),
(188, 2, 4, 8, '2024-04-14 13:00:00', '2024-04-14 13:30:00', 1, 1),
(189, 2, 4, 8, '2024-04-21 13:00:00', '2024-04-21 13:30:00', 1, 1),
(190, 2, 4, 8, '2024-04-28 13:00:00', '2024-04-28 13:30:00', 1, 1),
(191, 2, 4, 8, '2024-05-05 13:00:00', '2024-05-05 13:30:00', 1, 1),
(192, 2, 4, 8, '2024-05-12 13:00:00', '2024-05-12 13:30:00', 1, 1),
(193, 2, 4, 9, '2024-02-05 14:00:00', '2024-02-05 14:30:00', 1, 1),
(194, 2, 4, 9, '2024-02-12 14:00:00', '2024-02-12 14:30:00', 1, 1),
(195, 2, 4, 9, '2024-02-19 14:00:00', '2024-02-19 14:30:00', 1, 1),
(196, 2, 4, 9, '2024-02-26 14:00:00', '2024-02-26 14:30:00', 1, 1),
(197, 2, 4, 9, '2024-03-04 14:00:00', '2024-03-04 14:30:00', 1, 1),
(198, 2, 4, 9, '2024-03-11 14:00:00', '2024-03-11 14:30:00', 1, 1),
(199, 2, 4, 9, '2024-03-18 14:00:00', '2024-03-18 14:30:00', 1, 1),
(200, 2, 4, 9, '2024-03-25 14:00:00', '2024-03-25 14:30:00', 1, 1),
(201, 2, 4, 9, '2024-04-01 14:00:00', '2024-04-01 14:30:00', 1, 1),
(202, 2, 4, 9, '2024-04-08 14:00:00', '2024-04-08 14:30:00', 1, 1),
(203, 2, 4, 9, '2024-04-15 14:00:00', '2024-04-15 14:30:00', 1, 1),
(204, 2, 4, 9, '2024-04-22 14:00:00', '2024-04-22 14:30:00', 1, 1),
(205, 2, 4, 9, '2024-04-29 14:00:00', '2024-04-29 14:30:00', 1, 1),
(206, 2, 4, 9, '2024-05-06 14:00:00', '2024-05-06 14:30:00', 1, 1);


-- Create Subscription payments for members
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid)
VALUES
(1, 2, NULL, 1, 700.00, '2024-03-20 10:00:00', 1),
(2, 1, NULL, 2, 60.00, '2024-03-19 11:00:00', 1),
(3, 2, NULL, 3, 700.00, '2024-03-18 12:00:00', 1),
(4, 2, NULL, 4, 700.00, '2024-03-17 13:00:00', 1),
(5, 1, NULL, 5, 60.00, '2024-03-16 14:00:00', 1),
(6, 2, NULL, 6, 700.00, '2024-03-15 15:00:00', 1),
(7, 2, NULL, 7, 700.00, '2024-03-14 16:00:00', 1),
(8, 1, NULL, 8, 60.00, '2024-03-13 17:00:00', 1),
(9, 2, NULL, 9, 700.00, '2024-03-12 18:00:00', 1),
(10, 1, NULL, 10, 60.00, '2024-03-11 19:00:00', 1),
(11, 2, NULL, 11, 700.00, '2024-03-10 20:00:00', 1),
(12, 1, NULL, 12, 60.00, '2024-03-09 21:00:00', 1),
(13, 2, NULL, 13, 700.00, '2024-03-08 22:00:00', 1),
(14, 1, NULL, 14, 60.00, '2024-03-07 23:00:00', 1),
(15, 2, NULL, 15, 700.00, '2024-03-06 00:00:00', 1),
(16, 2, NULL, 16, 700.00, '2024-03-05 01:00:00', 1),
(17, 1, NULL, 17, 60.00, '2024-03-04 02:00:00', 1),
(18, 2, NULL, 18, 700.00, '2024-03-03 03:00:00', 1),
(19, 1, NULL, 19, 60.00, '2024-03-02 04:00:00', 1),
(20, 1, NULL, 20, 60.00, '2024-03-01 05:00:00', 1);

INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(1, 1, 1, '2024-01-27 18:00:00', 1, 0),
(2, 2, 1, '2024-01-27 18:00:00', 1, 0),
(3, 3, 1, '2024-01-27 18:00:00', 1, 1),
(4, 4, 1, '2024-01-27 18:00:00', 1, 0),
(5, 5, 1, '2024-01-27 18:00:00', 1, 0),
(6, 6, 1, '2024-01-27 18:00:00', 1, 1),
(7, 7, 1, '2024-01-27 18:00:00', 1, 0),
(8, 8, 1, '2024-01-27 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 1;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(9, 1, 2, '2024-02-01 18:00:00', 1, 1),
(10, 2, 2, '2024-02-01 18:00:00', 1, 0),
(11, 3, 2, '2024-02-01 18:00:00', 1, 1),
(12, 4, 2, '2024-02-01 18:00:00', 1, 0),
(13, 5, 2, '2024-02-01 18:00:00', 1, 1),
(14, 6, 2, '2024-02-01 18:00:00', 1, 0),
(15, 7, 2, '2024-02-01 18:00:00', 1, 1),
(16, 8, 2, '2024-02-01 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 2;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(17, 1, 3, '2024-02-03 18:00:00', 1, 1),
(18, 2, 3, '2024-02-03 18:00:00', 1, 0),
(19, 3, 3, '2024-02-03 18:00:00', 1, 0),
(20, 4, 3, '2024-02-03 18:00:00', 1, 1),
(21, 5, 3, '2024-02-03 18:00:00', 1, 1),
(22, 6, 3, '2024-02-03 18:00:00', 1, 0),
(23, 7, 3, '2024-02-03 18:00:00', 1, 0),
(24, 8, 3, '2024-02-03 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 3;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(25, 1, 4, '2024-02-08 18:00:00', 1, 1),
(26, 2, 4, '2024-02-08 18:00:00', 1, 1),
(27, 3, 4, '2024-02-08 18:00:00', 1, 1),
(28, 4, 4, '2024-02-08 18:00:00', 1, 1),
(29, 5, 4, '2024-02-08 18:00:00', 1, 1),
(30, 6, 4, '2024-02-08 18:00:00', 1, 1),
(31, 7, 4, '2024-02-08 18:00:00', 1, 0),
(32, 8, 4, '2024-02-08 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 4;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(33, 1, 5, '2024-02-10 18:00:00', 1, 0),
(34, 2, 5, '2024-02-10 18:00:00', 1, 0),
(35, 3, 5, '2024-02-10 18:00:00', 1, 0),
(36, 4, 5, '2024-02-10 18:00:00', 1, 1),
(37, 5, 5, '2024-02-10 18:00:00', 1, 1),
(38, 6, 5, '2024-02-10 18:00:00', 1, 1),
(39, 7, 5, '2024-02-10 18:00:00', 1, 1),
(40, 8, 5, '2024-02-10 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 5;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(41, 1, 6, '2024-02-15 18:00:00', 1, 0),
(42, 2, 6, '2024-02-15 18:00:00', 1, 0),
(43, 3, 6, '2024-02-15 18:00:00', 1, 0),
(44, 4, 6, '2024-02-15 18:00:00', 1, 1),
(45, 5, 6, '2024-02-15 18:00:00', 1, 1),
(46, 6, 6, '2024-02-15 18:00:00', 1, 0),
(47, 7, 6, '2024-02-15 18:00:00', 1, 1),
(48, 8, 6, '2024-02-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 6;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(49, 1, 7, '2024-02-17 18:00:00', 1, 1),
(50, 2, 7, '2024-02-17 18:00:00', 1, 0),
(51, 3, 7, '2024-02-17 18:00:00', 1, 0),
(52, 4, 7, '2024-02-17 18:00:00', 1, 1),
(53, 5, 7, '2024-02-17 18:00:00', 1, 0),
(54, 6, 7, '2024-02-17 18:00:00', 1, 1),
(55, 7, 7, '2024-02-17 18:00:00', 1, 1),
(56, 8, 7, '2024-02-17 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 7;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(57, 1, 8, '2024-02-22 18:00:00', 1, 1),
(58, 2, 8, '2024-02-22 18:00:00', 1, 0),
(59, 3, 8, '2024-02-22 18:00:00', 1, 0),
(60, 4, 8, '2024-02-22 18:00:00', 1, 0),
(61, 5, 8, '2024-02-22 18:00:00', 1, 0),
(62, 6, 8, '2024-02-22 18:00:00', 1, 0),
(63, 7, 8, '2024-02-22 18:00:00', 1, 0),
(64, 8, 8, '2024-02-22 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 8;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(65, 1, 9, '2024-02-24 18:00:00', 1, 0),
(66, 2, 9, '2024-02-24 18:00:00', 1, 0),
(67, 3, 9, '2024-02-24 18:00:00', 1, 0),
(68, 4, 9, '2024-02-24 18:00:00', 1, 1),
(69, 5, 9, '2024-02-24 18:00:00', 1, 0),
(70, 6, 9, '2024-02-24 18:00:00', 1, 1),
(71, 7, 9, '2024-02-24 18:00:00', 1, 1),
(72, 8, 9, '2024-02-24 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 9;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(73, 1, 10, '2024-02-29 18:00:00', 1, 0),
(74, 2, 10, '2024-02-29 18:00:00', 1, 0),
(75, 3, 10, '2024-02-29 18:00:00', 1, 0),
(76, 4, 10, '2024-02-29 18:00:00', 1, 1),
(77, 5, 10, '2024-02-29 18:00:00', 1, 0),
(78, 6, 10, '2024-02-29 18:00:00', 1, 0),
(79, 7, 10, '2024-02-29 18:00:00', 1, 0),
(80, 8, 10, '2024-02-29 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 10;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(81, 1, 11, '2024-03-02 18:00:00', 1, 0),
(82, 2, 11, '2024-03-02 18:00:00', 1, 1),
(83, 3, 11, '2024-03-02 18:00:00', 1, 0),
(84, 4, 11, '2024-03-02 18:00:00', 1, 1),
(85, 5, 11, '2024-03-02 18:00:00', 1, 0),
(86, 6, 11, '2024-03-02 18:00:00', 1, 1),
(87, 7, 11, '2024-03-02 18:00:00', 1, 0),
(88, 8, 11, '2024-03-02 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 11;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(89, 1, 12, '2024-03-07 18:00:00', 1, 1),
(90, 2, 12, '2024-03-07 18:00:00', 1, 0),
(91, 3, 12, '2024-03-07 18:00:00', 1, 1),
(92, 4, 12, '2024-03-07 18:00:00', 1, 1),
(93, 5, 12, '2024-03-07 18:00:00', 1, 0),
(94, 6, 12, '2024-03-07 18:00:00', 1, 1),
(95, 7, 12, '2024-03-07 18:00:00', 1, 0),
(96, 8, 12, '2024-03-07 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 12;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(97, 1, 13, '2024-03-09 18:00:00', 1, 0),
(98, 2, 13, '2024-03-09 18:00:00', 1, 1),
(99, 3, 13, '2024-03-09 18:00:00', 1, 1),
(100, 4, 13, '2024-03-09 18:00:00', 1, 0),
(101, 5, 13, '2024-03-09 18:00:00', 1, 0),
(102, 6, 13, '2024-03-09 18:00:00', 1, 0),
(103, 7, 13, '2024-03-09 18:00:00', 1, 1),
(104, 8, 13, '2024-03-09 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 13;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(105, 1, 14, '2024-03-14 18:00:00', 1, 0),
(106, 2, 14, '2024-03-14 18:00:00', 1, 1),
(107, 3, 14, '2024-03-14 18:00:00', 1, 0),
(108, 4, 14, '2024-03-14 18:00:00', 1, 0),
(109, 5, 14, '2024-03-14 18:00:00', 1, 0),
(110, 6, 14, '2024-03-14 18:00:00', 1, 0),
(111, 7, 14, '2024-03-14 18:00:00', 1, 1),
(112, 8, 14, '2024-03-14 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 14;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(113, 1, 15, '2024-03-16 18:00:00', 1, 0),
(114, 2, 15, '2024-03-16 18:00:00', 1, 1),
(115, 3, 15, '2024-03-16 18:00:00', 1, 0),
(116, 4, 15, '2024-03-16 18:00:00', 1, 1),
(117, 5, 15, '2024-03-16 18:00:00', 1, 0),
(118, 6, 15, '2024-03-16 18:00:00', 1, 0),
(119, 7, 15, '2024-03-16 18:00:00', 1, 0),
(120, 8, 15, '2024-03-16 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 15;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(121, 1, 16, '2024-03-21 18:00:00', 1, 0),
(122, 2, 16, '2024-03-21 18:00:00', 1, 1),
(123, 3, 16, '2024-03-21 18:00:00', 1, 1),
(124, 4, 16, '2024-03-21 18:00:00', 1, 0),
(125, 5, 16, '2024-03-21 18:00:00', 1, 1),
(126, 6, 16, '2024-03-21 18:00:00', 1, 1),
(127, 7, 16, '2024-03-21 18:00:00', 1, 0),
(128, 8, 16, '2024-03-21 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 16;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(129, 1, 17, '2024-03-23 18:00:00', 1, 1),
(130, 2, 17, '2024-03-23 18:00:00', 1, 1),
(131, 3, 17, '2024-03-23 18:00:00', 1, 1),
(132, 4, 17, '2024-03-23 18:00:00', 1, 0),
(133, 5, 17, '2024-03-23 18:00:00', 1, 1),
(134, 6, 17, '2024-03-23 18:00:00', 1, 0),
(135, 7, 17, '2024-03-23 18:00:00', 1, 0),
(136, 8, 17, '2024-03-23 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 17;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(137, 1, 18, '2024-03-28 18:00:00', 1, 1),
(138, 2, 18, '2024-03-28 18:00:00', 1, 0),
(139, 3, 18, '2024-03-28 18:00:00', 1, 1),
(140, 4, 18, '2024-03-28 18:00:00', 1, 1),
(141, 5, 18, '2024-03-28 18:00:00', 1, 0),
(142, 6, 18, '2024-03-28 18:00:00', 1, 0),
(143, 7, 18, '2024-03-28 18:00:00', 1, 0),
(144, 8, 18, '2024-03-28 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 18;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(145, 1, 19, '2024-03-30 18:00:00', 1, 0),
(146, 2, 19, '2024-03-30 18:00:00', 1, 1),
(147, 3, 19, '2024-03-30 18:00:00', 1, 0),
(148, 4, 19, '2024-03-30 18:00:00', 1, 0),
(149, 5, 19, '2024-03-30 18:00:00', 1, 1),
(150, 6, 19, '2024-03-30 18:00:00', 1, 0),
(151, 7, 19, '2024-03-30 18:00:00', 1, 1),
(152, 8, 19, '2024-03-30 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 19;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(153, 1, 20, '2024-04-04 18:00:00', 1, 1),
(154, 2, 20, '2024-04-04 18:00:00', 1, 1),
(155, 3, 20, '2024-04-04 18:00:00', 1, 0),
(156, 4, 20, '2024-04-04 18:00:00', 1, 1),
(157, 5, 20, '2024-04-04 18:00:00', 1, 0),
(158, 6, 20, '2024-04-04 18:00:00', 1, 1),
(159, 7, 20, '2024-04-04 18:00:00', 1, 0),
(160, 8, 20, '2024-04-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 20;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(161, 1, 21, '2024-04-06 18:00:00', 1, 0),
(162, 2, 21, '2024-04-06 18:00:00', 1, 1),
(163, 3, 21, '2024-04-06 18:00:00', 1, 1),
(164, 4, 21, '2024-04-06 18:00:00', 1, 1),
(165, 5, 21, '2024-04-06 18:00:00', 1, 1),
(166, 6, 21, '2024-04-06 18:00:00', 1, 0),
(167, 7, 21, '2024-04-06 18:00:00', 1, 0),
(168, 8, 21, '2024-04-06 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 21;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(169, 1, 22, '2024-04-11 18:00:00', 1, 0),
(170, 2, 22, '2024-04-11 18:00:00', 1, 0),
(171, 3, 22, '2024-04-11 18:00:00', 1, 1),
(172, 4, 22, '2024-04-11 18:00:00', 1, 1),
(173, 5, 22, '2024-04-11 18:00:00', 1, 1),
(174, 6, 22, '2024-04-11 18:00:00', 1, 0),
(175, 7, 22, '2024-04-11 18:00:00', 1, 1),
(176, 8, 22, '2024-04-11 18:00:00', 1, 1);
UPDATE class SET open_slot = 7 WHERE id = 22;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(177, 1, 23, '2024-04-13 18:00:00', 1, 0),
(178, 2, 23, '2024-04-13 18:00:00', 1, 0),
(179, 3, 23, '2024-04-13 18:00:00', 1, 1),
(180, 4, 23, '2024-04-13 18:00:00', 1, 0),
(181, 5, 23, '2024-04-13 18:00:00', 1, 0),
(182, 6, 23, '2024-04-13 18:00:00', 1, 1),
(183, 7, 23, '2024-04-13 18:00:00', 1, 0),
(184, 8, 23, '2024-04-13 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 23;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(185, 1, 24, '2024-04-18 18:00:00', 1, 0),
(186, 2, 24, '2024-04-18 18:00:00', 1, 0),
(187, 3, 24, '2024-04-18 18:00:00', 1, 0),
(188, 4, 24, '2024-04-18 18:00:00', 1, 0),
(189, 5, 24, '2024-04-18 18:00:00', 1, 0),
(190, 6, 24, '2024-04-18 18:00:00', 1, 0),
(191, 7, 24, '2024-04-18 18:00:00', 1, 0),
(192, 8, 24, '2024-04-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 24;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(193, 1, 25, '2024-04-20 18:00:00', 1, 0),
(194, 2, 25, '2024-04-20 18:00:00', 1, 0),
(195, 3, 25, '2024-04-20 18:00:00', 1, 0),
(196, 4, 25, '2024-04-20 18:00:00', 1, 0),
(197, 5, 25, '2024-04-20 18:00:00', 1, 0),
(198, 6, 25, '2024-04-20 18:00:00', 1, 0),
(199, 7, 25, '2024-04-20 18:00:00', 1, 0),
(200, 8, 25, '2024-04-20 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 25;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(201, 1, 26, '2024-04-25 18:00:00', 1, 0),
(202, 2, 26, '2024-04-25 18:00:00', 1, 0),
(203, 3, 26, '2024-04-25 18:00:00', 1, 0),
(204, 4, 26, '2024-04-25 18:00:00', 1, 0),
(205, 5, 26, '2024-04-25 18:00:00', 1, 0),
(206, 6, 26, '2024-04-25 18:00:00', 1, 0),
(207, 7, 26, '2024-04-25 18:00:00', 1, 0),
(208, 8, 26, '2024-04-25 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 26;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(209, 1, 27, '2024-04-27 18:00:00', 1, 0),
(210, 2, 27, '2024-04-27 18:00:00', 1, 0),
(211, 3, 27, '2024-04-27 18:00:00', 1, 0),
(212, 4, 27, '2024-04-27 18:00:00', 1, 0),
(213, 5, 27, '2024-04-27 18:00:00', 1, 0),
(214, 6, 27, '2024-04-27 18:00:00', 1, 0),
(215, 7, 27, '2024-04-27 18:00:00', 1, 0),
(216, 8, 27, '2024-04-27 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 27;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(217, 1, 28, '2024-05-02 18:00:00', 1, 0),
(218, 2, 28, '2024-05-02 18:00:00', 1, 0),
(219, 3, 28, '2024-05-02 18:00:00', 1, 0),
(220, 4, 28, '2024-05-02 18:00:00', 1, 0),
(221, 5, 28, '2024-05-02 18:00:00', 1, 0),
(222, 6, 28, '2024-05-02 18:00:00', 1, 0),
(223, 7, 28, '2024-05-02 18:00:00', 1, 0),
(224, 8, 28, '2024-05-02 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 28;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(225, 1, 29, '2024-05-04 18:00:00', 1, 0),
(226, 2, 29, '2024-05-04 18:00:00', 1, 0),
(227, 3, 29, '2024-05-04 18:00:00', 1, 0),
(228, 4, 29, '2024-05-04 18:00:00', 1, 0),
(229, 5, 29, '2024-05-04 18:00:00', 1, 0),
(230, 6, 29, '2024-05-04 18:00:00', 1, 0),
(231, 7, 29, '2024-05-04 18:00:00', 1, 0),
(232, 8, 29, '2024-05-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 7 WHERE id = 29;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(233, 5, 30, '2024-01-29 18:00:00', 1, 0),
(234, 6, 30, '2024-01-29 18:00:00', 1, 0),
(235, 7, 30, '2024-01-29 18:00:00', 1, 1),
(236, 8, 30, '2024-01-29 18:00:00', 1, 0),
(237, 9, 30, '2024-01-29 18:00:00', 1, 0),
(238, 10, 30, '2024-01-29 18:00:00', 1, 0),
(239, 11, 30, '2024-01-29 18:00:00', 1, 1),
(240, 12, 30, '2024-01-29 18:00:00', 1, 1),
(241, 13, 30, '2024-01-29 18:00:00', 1, 1),
(242, 14, 30, '2024-01-29 18:00:00', 1, 0),
(243, 15, 30, '2024-01-29 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 30;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(244, 5, 31, '2024-01-30 18:00:00', 1, 0),
(245, 6, 31, '2024-01-30 18:00:00', 1, 0),
(246, 7, 31, '2024-01-30 18:00:00', 1, 1),
(247, 8, 31, '2024-01-30 18:00:00', 1, 0),
(248, 9, 31, '2024-01-30 18:00:00', 1, 0),
(249, 10, 31, '2024-01-30 18:00:00', 1, 0),
(250, 11, 31, '2024-01-30 18:00:00', 1, 1),
(251, 12, 31, '2024-01-30 18:00:00', 1, 1),
(252, 13, 31, '2024-01-30 18:00:00', 1, 0),
(253, 14, 31, '2024-01-30 18:00:00', 1, 1),
(254, 15, 31, '2024-01-30 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 31;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(255, 5, 32, '2024-02-05 18:00:00', 1, 0),
(256, 6, 32, '2024-02-05 18:00:00', 1, 0),
(257, 7, 32, '2024-02-05 18:00:00', 1, 1),
(258, 8, 32, '2024-02-05 18:00:00', 1, 0),
(259, 9, 32, '2024-02-05 18:00:00', 1, 0),
(260, 10, 32, '2024-02-05 18:00:00', 1, 1),
(261, 11, 32, '2024-02-05 18:00:00', 1, 0),
(262, 12, 32, '2024-02-05 18:00:00', 1, 1),
(263, 13, 32, '2024-02-05 18:00:00', 1, 0),
(264, 14, 32, '2024-02-05 18:00:00', 1, 0),
(265, 15, 32, '2024-02-05 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 32;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(266, 5, 33, '2024-02-06 18:00:00', 1, 1),
(267, 6, 33, '2024-02-06 18:00:00', 1, 0),
(268, 7, 33, '2024-02-06 18:00:00', 1, 1),
(269, 8, 33, '2024-02-06 18:00:00', 1, 1),
(270, 9, 33, '2024-02-06 18:00:00', 1, 1),
(271, 10, 33, '2024-02-06 18:00:00', 1, 0),
(272, 11, 33, '2024-02-06 18:00:00', 1, 1),
(273, 12, 33, '2024-02-06 18:00:00', 1, 0),
(274, 13, 33, '2024-02-06 18:00:00', 1, 1),
(275, 14, 33, '2024-02-06 18:00:00', 1, 1),
(276, 15, 33, '2024-02-06 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 33;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(277, 5, 34, '2024-02-12 18:00:00', 1, 0),
(278, 6, 34, '2024-02-12 18:00:00', 1, 0),
(279, 7, 34, '2024-02-12 18:00:00', 1, 1),
(280, 8, 34, '2024-02-12 18:00:00', 1, 1),
(281, 9, 34, '2024-02-12 18:00:00', 1, 1),
(282, 10, 34, '2024-02-12 18:00:00', 1, 0),
(283, 11, 34, '2024-02-12 18:00:00', 1, 0),
(284, 12, 34, '2024-02-12 18:00:00', 1, 0),
(285, 13, 34, '2024-02-12 18:00:00', 1, 1),
(286, 14, 34, '2024-02-12 18:00:00', 1, 1),
(287, 15, 34, '2024-02-12 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 34;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(288, 5, 35, '2024-02-13 18:00:00', 1, 1),
(289, 6, 35, '2024-02-13 18:00:00', 1, 0),
(290, 7, 35, '2024-02-13 18:00:00', 1, 0),
(291, 8, 35, '2024-02-13 18:00:00', 1, 0),
(292, 9, 35, '2024-02-13 18:00:00', 1, 1),
(293, 10, 35, '2024-02-13 18:00:00', 1, 0),
(294, 11, 35, '2024-02-13 18:00:00', 1, 0),
(295, 12, 35, '2024-02-13 18:00:00', 1, 0),
(296, 13, 35, '2024-02-13 18:00:00', 1, 0),
(297, 14, 35, '2024-02-13 18:00:00', 1, 0),
(298, 15, 35, '2024-02-13 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 35;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(299, 5, 36, '2024-02-19 18:00:00', 1, 0),
(300, 6, 36, '2024-02-19 18:00:00', 1, 0),
(301, 7, 36, '2024-02-19 18:00:00', 1, 0),
(302, 8, 36, '2024-02-19 18:00:00', 1, 1),
(303, 9, 36, '2024-02-19 18:00:00', 1, 0),
(304, 10, 36, '2024-02-19 18:00:00', 1, 0),
(305, 11, 36, '2024-02-19 18:00:00', 1, 0),
(306, 12, 36, '2024-02-19 18:00:00', 1, 1),
(307, 13, 36, '2024-02-19 18:00:00', 1, 1),
(308, 14, 36, '2024-02-19 18:00:00', 1, 0),
(309, 15, 36, '2024-02-19 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 36;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(310, 5, 37, '2024-02-20 18:00:00', 1, 1),
(311, 6, 37, '2024-02-20 18:00:00', 1, 0),
(312, 7, 37, '2024-02-20 18:00:00', 1, 0),
(313, 8, 37, '2024-02-20 18:00:00', 1, 0),
(314, 9, 37, '2024-02-20 18:00:00', 1, 0),
(315, 10, 37, '2024-02-20 18:00:00', 1, 1),
(316, 11, 37, '2024-02-20 18:00:00', 1, 1),
(317, 12, 37, '2024-02-20 18:00:00', 1, 1),
(318, 13, 37, '2024-02-20 18:00:00', 1, 1),
(319, 14, 37, '2024-02-20 18:00:00', 1, 1),
(320, 15, 37, '2024-02-20 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 37;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(321, 5, 38, '2024-02-26 18:00:00', 1, 1),
(322, 6, 38, '2024-02-26 18:00:00', 1, 0),
(323, 7, 38, '2024-02-26 18:00:00', 1, 1),
(324, 8, 38, '2024-02-26 18:00:00', 1, 1),
(325, 9, 38, '2024-02-26 18:00:00', 1, 1),
(326, 10, 38, '2024-02-26 18:00:00', 1, 0),
(327, 11, 38, '2024-02-26 18:00:00', 1, 1),
(328, 12, 38, '2024-02-26 18:00:00', 1, 1),
(329, 13, 38, '2024-02-26 18:00:00', 1, 1),
(330, 14, 38, '2024-02-26 18:00:00', 1, 1),
(331, 15, 38, '2024-02-26 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 38;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(332, 5, 39, '2024-02-27 18:00:00', 1, 0),
(333, 6, 39, '2024-02-27 18:00:00', 1, 0),
(334, 7, 39, '2024-02-27 18:00:00', 1, 0),
(335, 8, 39, '2024-02-27 18:00:00', 1, 0),
(336, 9, 39, '2024-02-27 18:00:00', 1, 0),
(337, 10, 39, '2024-02-27 18:00:00', 1, 1),
(338, 11, 39, '2024-02-27 18:00:00', 1, 0),
(339, 12, 39, '2024-02-27 18:00:00', 1, 1),
(340, 13, 39, '2024-02-27 18:00:00', 1, 0),
(341, 14, 39, '2024-02-27 18:00:00', 1, 1),
(342, 15, 39, '2024-02-27 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 39;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(343, 5, 40, '2024-03-04 18:00:00', 1, 1),
(344, 6, 40, '2024-03-04 18:00:00', 1, 1),
(345, 7, 40, '2024-03-04 18:00:00', 1, 1),
(346, 8, 40, '2024-03-04 18:00:00', 1, 1),
(347, 9, 40, '2024-03-04 18:00:00', 1, 1),
(348, 10, 40, '2024-03-04 18:00:00', 1, 0),
(349, 11, 40, '2024-03-04 18:00:00', 1, 1),
(350, 12, 40, '2024-03-04 18:00:00', 1, 1),
(351, 13, 40, '2024-03-04 18:00:00', 1, 0),
(352, 14, 40, '2024-03-04 18:00:00', 1, 0),
(353, 15, 40, '2024-03-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 40;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(354, 5, 41, '2024-03-05 18:00:00', 1, 1),
(355, 6, 41, '2024-03-05 18:00:00', 1, 0),
(356, 7, 41, '2024-03-05 18:00:00', 1, 0),
(357, 8, 41, '2024-03-05 18:00:00', 1, 0),
(358, 9, 41, '2024-03-05 18:00:00', 1, 1),
(359, 10, 41, '2024-03-05 18:00:00', 1, 0),
(360, 11, 41, '2024-03-05 18:00:00', 1, 1),
(361, 12, 41, '2024-03-05 18:00:00', 1, 0),
(362, 13, 41, '2024-03-05 18:00:00', 1, 0),
(363, 14, 41, '2024-03-05 18:00:00', 1, 0),
(364, 15, 41, '2024-03-05 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 41;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(365, 5, 42, '2024-03-11 18:00:00', 1, 1),
(366, 6, 42, '2024-03-11 18:00:00', 1, 0),
(367, 7, 42, '2024-03-11 18:00:00', 1, 1),
(368, 8, 42, '2024-03-11 18:00:00', 1, 0),
(369, 9, 42, '2024-03-11 18:00:00', 1, 1),
(370, 10, 42, '2024-03-11 18:00:00', 1, 0),
(371, 11, 42, '2024-03-11 18:00:00', 1, 1),
(372, 12, 42, '2024-03-11 18:00:00', 1, 1),
(373, 13, 42, '2024-03-11 18:00:00', 1, 1),
(374, 14, 42, '2024-03-11 18:00:00', 1, 0),
(375, 15, 42, '2024-03-11 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 42;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(376, 5, 43, '2024-03-12 18:00:00', 1, 0),
(377, 6, 43, '2024-03-12 18:00:00', 1, 0),
(378, 7, 43, '2024-03-12 18:00:00', 1, 0),
(379, 8, 43, '2024-03-12 18:00:00', 1, 0),
(380, 9, 43, '2024-03-12 18:00:00', 1, 0),
(381, 10, 43, '2024-03-12 18:00:00', 1, 1),
(382, 11, 43, '2024-03-12 18:00:00', 1, 0),
(383, 12, 43, '2024-03-12 18:00:00', 1, 1),
(384, 13, 43, '2024-03-12 18:00:00', 1, 0),
(385, 14, 43, '2024-03-12 18:00:00', 1, 1),
(386, 15, 43, '2024-03-12 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 43;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(387, 5, 44, '2024-03-18 18:00:00', 1, 0),
(388, 6, 44, '2024-03-18 18:00:00', 1, 1),
(389, 7, 44, '2024-03-18 18:00:00', 1, 0),
(390, 8, 44, '2024-03-18 18:00:00', 1, 0),
(391, 9, 44, '2024-03-18 18:00:00', 1, 0),
(392, 10, 44, '2024-03-18 18:00:00', 1, 1),
(393, 11, 44, '2024-03-18 18:00:00', 1, 0),
(394, 12, 44, '2024-03-18 18:00:00', 1, 1),
(395, 13, 44, '2024-03-18 18:00:00', 1, 0),
(396, 14, 44, '2024-03-18 18:00:00', 1, 1),
(397, 15, 44, '2024-03-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 44;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(398, 5, 45, '2024-03-19 18:00:00', 1, 0),
(399, 6, 45, '2024-03-19 18:00:00', 1, 0),
(400, 7, 45, '2024-03-19 18:00:00', 1, 0),
(401, 8, 45, '2024-03-19 18:00:00', 1, 1),
(402, 9, 45, '2024-03-19 18:00:00', 1, 0),
(403, 10, 45, '2024-03-19 18:00:00', 1, 0),
(404, 11, 45, '2024-03-19 18:00:00', 1, 0),
(405, 12, 45, '2024-03-19 18:00:00', 1, 1),
(406, 13, 45, '2024-03-19 18:00:00', 1, 0),
(407, 14, 45, '2024-03-19 18:00:00', 1, 1),
(408, 15, 45, '2024-03-19 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 45;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(409, 5, 46, '2024-03-25 18:00:00', 1, 0),
(410, 6, 46, '2024-03-25 18:00:00', 1, 1),
(411, 7, 46, '2024-03-25 18:00:00', 1, 1),
(412, 8, 46, '2024-03-25 18:00:00', 1, 0),
(413, 9, 46, '2024-03-25 18:00:00', 1, 0),
(414, 10, 46, '2024-03-25 18:00:00', 1, 1),
(415, 11, 46, '2024-03-25 18:00:00', 1, 0),
(416, 12, 46, '2024-03-25 18:00:00', 1, 0),
(417, 13, 46, '2024-03-25 18:00:00', 1, 0),
(418, 14, 46, '2024-03-25 18:00:00', 1, 1),
(419, 15, 46, '2024-03-25 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 46;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(420, 5, 47, '2024-03-26 18:00:00', 1, 0),
(421, 6, 47, '2024-03-26 18:00:00', 1, 1),
(422, 7, 47, '2024-03-26 18:00:00', 1, 1),
(423, 8, 47, '2024-03-26 18:00:00', 1, 1),
(424, 9, 47, '2024-03-26 18:00:00', 1, 1),
(425, 10, 47, '2024-03-26 18:00:00', 1, 0),
(426, 11, 47, '2024-03-26 18:00:00', 1, 0),
(427, 12, 47, '2024-03-26 18:00:00', 1, 0),
(428, 13, 47, '2024-03-26 18:00:00', 1, 0),
(429, 14, 47, '2024-03-26 18:00:00', 1, 1),
(430, 15, 47, '2024-03-26 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 47;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(431, 5, 48, '2024-04-01 18:00:00', 1, 1),
(432, 6, 48, '2024-04-01 18:00:00', 1, 0),
(433, 7, 48, '2024-04-01 18:00:00', 1, 0),
(434, 8, 48, '2024-04-01 18:00:00', 1, 1),
(435, 9, 48, '2024-04-01 18:00:00', 1, 1),
(436, 10, 48, '2024-04-01 18:00:00', 1, 0),
(437, 11, 48, '2024-04-01 18:00:00', 1, 1),
(438, 12, 48, '2024-04-01 18:00:00', 1, 0),
(439, 13, 48, '2024-04-01 18:00:00', 1, 1),
(440, 14, 48, '2024-04-01 18:00:00', 1, 0),
(441, 15, 48, '2024-04-01 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 48;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(442, 5, 49, '2024-04-02 18:00:00', 1, 1),
(443, 6, 49, '2024-04-02 18:00:00', 1, 0),
(444, 7, 49, '2024-04-02 18:00:00', 1, 1),
(445, 8, 49, '2024-04-02 18:00:00', 1, 1),
(446, 9, 49, '2024-04-02 18:00:00', 1, 0),
(447, 10, 49, '2024-04-02 18:00:00', 1, 0),
(448, 11, 49, '2024-04-02 18:00:00', 1, 0),
(449, 12, 49, '2024-04-02 18:00:00', 1, 1),
(450, 13, 49, '2024-04-02 18:00:00', 1, 1),
(451, 14, 49, '2024-04-02 18:00:00', 1, 1),
(452, 15, 49, '2024-04-02 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 49;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(453, 5, 50, '2024-04-08 18:00:00', 1, 0),
(454, 6, 50, '2024-04-08 18:00:00', 1, 1),
(455, 7, 50, '2024-04-08 18:00:00', 1, 1),
(456, 8, 50, '2024-04-08 18:00:00', 1, 1),
(457, 9, 50, '2024-04-08 18:00:00', 1, 1),
(458, 10, 50, '2024-04-08 18:00:00', 1, 0),
(459, 11, 50, '2024-04-08 18:00:00', 1, 1),
(460, 12, 50, '2024-04-08 18:00:00', 1, 1),
(461, 13, 50, '2024-04-08 18:00:00', 1, 1),
(462, 14, 50, '2024-04-08 18:00:00', 1, 0),
(463, 15, 50, '2024-04-08 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 50;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(464, 5, 51, '2024-04-09 18:00:00', 1, 0),
(465, 6, 51, '2024-04-09 18:00:00', 1, 0),
(466, 7, 51, '2024-04-09 18:00:00', 1, 1),
(467, 8, 51, '2024-04-09 18:00:00', 1, 1),
(468, 9, 51, '2024-04-09 18:00:00', 1, 1),
(469, 10, 51, '2024-04-09 18:00:00', 1, 0),
(470, 11, 51, '2024-04-09 18:00:00', 1, 1),
(471, 12, 51, '2024-04-09 18:00:00', 1, 0),
(472, 13, 51, '2024-04-09 18:00:00', 1, 1),
(473, 14, 51, '2024-04-09 18:00:00', 1, 1),
(474, 15, 51, '2024-04-09 18:00:00', 1, 1);
UPDATE class SET open_slot = 4 WHERE id = 51;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(475, 5, 52, '2024-04-15 18:00:00', 1, 0),
(476, 6, 52, '2024-04-15 18:00:00', 1, 0),
(477, 7, 52, '2024-04-15 18:00:00', 1, 0),
(478, 8, 52, '2024-04-15 18:00:00', 1, 0),
(479, 9, 52, '2024-04-15 18:00:00', 1, 0),
(480, 10, 52, '2024-04-15 18:00:00', 1, 0),
(481, 11, 52, '2024-04-15 18:00:00', 1, 0),
(482, 12, 52, '2024-04-15 18:00:00', 1, 0),
(483, 13, 52, '2024-04-15 18:00:00', 1, 0),
(484, 14, 52, '2024-04-15 18:00:00', 1, 0),
(485, 15, 52, '2024-04-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 52;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(486, 5, 53, '2024-04-16 18:00:00', 1, 0),
(487, 6, 53, '2024-04-16 18:00:00', 1, 0),
(488, 7, 53, '2024-04-16 18:00:00', 1, 0),
(489, 8, 53, '2024-04-16 18:00:00', 1, 0),
(490, 9, 53, '2024-04-16 18:00:00', 1, 0),
(491, 10, 53, '2024-04-16 18:00:00', 1, 0),
(492, 11, 53, '2024-04-16 18:00:00', 1, 0),
(493, 12, 53, '2024-04-16 18:00:00', 1, 0),
(494, 13, 53, '2024-04-16 18:00:00', 1, 0),
(495, 14, 53, '2024-04-16 18:00:00', 1, 0),
(496, 15, 53, '2024-04-16 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 53;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(497, 5, 54, '2024-04-22 18:00:00', 1, 0),
(498, 6, 54, '2024-04-22 18:00:00', 1, 0),
(499, 7, 54, '2024-04-22 18:00:00', 1, 0),
(500, 8, 54, '2024-04-22 18:00:00', 1, 0),
(501, 9, 54, '2024-04-22 18:00:00', 1, 0),
(502, 10, 54, '2024-04-22 18:00:00', 1, 0),
(503, 11, 54, '2024-04-22 18:00:00', 1, 0),
(504, 12, 54, '2024-04-22 18:00:00', 1, 0),
(505, 13, 54, '2024-04-22 18:00:00', 1, 0),
(506, 14, 54, '2024-04-22 18:00:00', 1, 0),
(507, 15, 54, '2024-04-22 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 54;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(508, 5, 55, '2024-04-23 18:00:00', 1, 0),
(509, 6, 55, '2024-04-23 18:00:00', 1, 0),
(510, 7, 55, '2024-04-23 18:00:00', 1, 0),
(511, 8, 55, '2024-04-23 18:00:00', 1, 0),
(512, 9, 55, '2024-04-23 18:00:00', 1, 0),
(513, 10, 55, '2024-04-23 18:00:00', 1, 0),
(514, 11, 55, '2024-04-23 18:00:00', 1, 0),
(515, 12, 55, '2024-04-23 18:00:00', 1, 0),
(516, 13, 55, '2024-04-23 18:00:00', 1, 0),
(517, 14, 55, '2024-04-23 18:00:00', 1, 0),
(518, 15, 55, '2024-04-23 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 55;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(519, 5, 56, '2024-04-29 18:00:00', 1, 0),
(520, 6, 56, '2024-04-29 18:00:00', 1, 0),
(521, 7, 56, '2024-04-29 18:00:00', 1, 0),
(522, 8, 56, '2024-04-29 18:00:00', 1, 0),
(523, 9, 56, '2024-04-29 18:00:00', 1, 0),
(524, 10, 56, '2024-04-29 18:00:00', 1, 0),
(525, 11, 56, '2024-04-29 18:00:00', 1, 0),
(526, 12, 56, '2024-04-29 18:00:00', 1, 0),
(527, 13, 56, '2024-04-29 18:00:00', 1, 0),
(528, 14, 56, '2024-04-29 18:00:00', 1, 0),
(529, 15, 56, '2024-04-29 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 56;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(530, 5, 57, '2024-04-30 18:00:00', 1, 0),
(531, 6, 57, '2024-04-30 18:00:00', 1, 0),
(532, 7, 57, '2024-04-30 18:00:00', 1, 0),
(533, 8, 57, '2024-04-30 18:00:00', 1, 0),
(534, 9, 57, '2024-04-30 18:00:00', 1, 0),
(535, 10, 57, '2024-04-30 18:00:00', 1, 0),
(536, 11, 57, '2024-04-30 18:00:00', 1, 0),
(537, 12, 57, '2024-04-30 18:00:00', 1, 0),
(538, 13, 57, '2024-04-30 18:00:00', 1, 0),
(539, 14, 57, '2024-04-30 18:00:00', 1, 0),
(540, 15, 57, '2024-04-30 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 57;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(541, 5, 58, '2024-05-06 18:00:00', 1, 0),
(542, 6, 58, '2024-05-06 18:00:00', 1, 0),
(543, 7, 58, '2024-05-06 18:00:00', 1, 0),
(544, 8, 58, '2024-05-06 18:00:00', 1, 0),
(545, 9, 58, '2024-05-06 18:00:00', 1, 0),
(546, 10, 58, '2024-05-06 18:00:00', 1, 0),
(547, 11, 58, '2024-05-06 18:00:00', 1, 0),
(548, 12, 58, '2024-05-06 18:00:00', 1, 0),
(549, 13, 58, '2024-05-06 18:00:00', 1, 0),
(550, 14, 58, '2024-05-06 18:00:00', 1, 0),
(551, 15, 58, '2024-05-06 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 58;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(552, 5, 59, '2024-05-07 18:00:00', 1, 0),
(553, 6, 59, '2024-05-07 18:00:00', 1, 0),
(554, 7, 59, '2024-05-07 18:00:00', 1, 0),
(555, 8, 59, '2024-05-07 18:00:00', 1, 0),
(556, 9, 59, '2024-05-07 18:00:00', 1, 0),
(557, 10, 59, '2024-05-07 18:00:00', 1, 0),
(558, 11, 59, '2024-05-07 18:00:00', 1, 0),
(559, 12, 59, '2024-05-07 18:00:00', 1, 0),
(560, 13, 59, '2024-05-07 18:00:00', 1, 0),
(561, 14, 59, '2024-05-07 18:00:00', 1, 0),
(562, 15, 59, '2024-05-07 18:00:00', 1, 0);
UPDATE class SET open_slot = 4 WHERE id = 59;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(563, 16, 60, '2024-01-29 18:00:00', 1, 0),
(564, 17, 60, '2024-01-29 18:00:00', 1, 1),
(565, 18, 60, '2024-01-29 18:00:00', 1, 1),
(566, 19, 60, '2024-01-29 18:00:00', 1, 0),
(567, 20, 60, '2024-01-29 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 60;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(568, 16, 61, '2024-02-01 18:00:00', 1, 0),
(569, 17, 61, '2024-02-01 18:00:00', 1, 0),
(570, 18, 61, '2024-02-01 18:00:00', 1, 0),
(571, 19, 61, '2024-02-01 18:00:00', 1, 0),
(572, 20, 61, '2024-02-01 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 61;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(573, 16, 62, '2024-02-05 18:00:00', 1, 1),
(574, 17, 62, '2024-02-05 18:00:00', 1, 0),
(575, 18, 62, '2024-02-05 18:00:00', 1, 1),
(576, 19, 62, '2024-02-05 18:00:00', 1, 1),
(577, 20, 62, '2024-02-05 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 62;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(578, 16, 63, '2024-02-08 18:00:00', 1, 0),
(579, 17, 63, '2024-02-08 18:00:00', 1, 0),
(580, 18, 63, '2024-02-08 18:00:00', 1, 0),
(581, 19, 63, '2024-02-08 18:00:00', 1, 0),
(582, 20, 63, '2024-02-08 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 63;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(583, 16, 64, '2024-02-12 18:00:00', 1, 1),
(584, 17, 64, '2024-02-12 18:00:00', 1, 1),
(585, 18, 64, '2024-02-12 18:00:00', 1, 0),
(586, 19, 64, '2024-02-12 18:00:00', 1, 1),
(587, 20, 64, '2024-02-12 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 64;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(588, 16, 65, '2024-02-15 18:00:00', 1, 1),
(589, 17, 65, '2024-02-15 18:00:00', 1, 0),
(590, 18, 65, '2024-02-15 18:00:00', 1, 1),
(591, 19, 65, '2024-02-15 18:00:00', 1, 1),
(592, 20, 65, '2024-02-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 65;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(593, 16, 66, '2024-02-19 18:00:00', 1, 1),
(594, 17, 66, '2024-02-19 18:00:00', 1, 0),
(595, 18, 66, '2024-02-19 18:00:00', 1, 0),
(596, 19, 66, '2024-02-19 18:00:00', 1, 1),
(597, 20, 66, '2024-02-19 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 66;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(598, 16, 67, '2024-02-22 18:00:00', 1, 0),
(599, 17, 67, '2024-02-22 18:00:00', 1, 1),
(600, 18, 67, '2024-02-22 18:00:00', 1, 1),
(601, 19, 67, '2024-02-22 18:00:00', 1, 0),
(602, 20, 67, '2024-02-22 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 67;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(603, 16, 68, '2024-02-26 18:00:00', 1, 0),
(604, 17, 68, '2024-02-26 18:00:00', 1, 0),
(605, 18, 68, '2024-02-26 18:00:00', 1, 0),
(606, 19, 68, '2024-02-26 18:00:00', 1, 0),
(607, 20, 68, '2024-02-26 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 68;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(608, 16, 69, '2024-02-29 18:00:00', 1, 0),
(609, 17, 69, '2024-02-29 18:00:00', 1, 1),
(610, 18, 69, '2024-02-29 18:00:00', 1, 1),
(611, 19, 69, '2024-02-29 18:00:00', 1, 1),
(612, 20, 69, '2024-02-29 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 69;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(613, 16, 70, '2024-03-04 18:00:00', 1, 0),
(614, 17, 70, '2024-03-04 18:00:00', 1, 0),
(615, 18, 70, '2024-03-04 18:00:00', 1, 1),
(616, 19, 70, '2024-03-04 18:00:00', 1, 1),
(617, 20, 70, '2024-03-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 70;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(618, 16, 71, '2024-03-07 18:00:00', 1, 0),
(619, 17, 71, '2024-03-07 18:00:00', 1, 1),
(620, 18, 71, '2024-03-07 18:00:00', 1, 0),
(621, 19, 71, '2024-03-07 18:00:00', 1, 0),
(622, 20, 71, '2024-03-07 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 71;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(623, 16, 72, '2024-03-11 18:00:00', 1, 0),
(624, 17, 72, '2024-03-11 18:00:00', 1, 1),
(625, 18, 72, '2024-03-11 18:00:00', 1, 1),
(626, 19, 72, '2024-03-11 18:00:00', 1, 1),
(627, 20, 72, '2024-03-11 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 72;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(628, 16, 73, '2024-03-14 18:00:00', 1, 0),
(629, 17, 73, '2024-03-14 18:00:00', 1, 1),
(630, 18, 73, '2024-03-14 18:00:00', 1, 0),
(631, 19, 73, '2024-03-14 18:00:00', 1, 0),
(632, 20, 73, '2024-03-14 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 73;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(633, 16, 74, '2024-03-18 18:00:00', 1, 1),
(634, 17, 74, '2024-03-18 18:00:00', 1, 1),
(635, 18, 74, '2024-03-18 18:00:00', 1, 0),
(636, 19, 74, '2024-03-18 18:00:00', 1, 1),
(637, 20, 74, '2024-03-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 74;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(638, 16, 75, '2024-03-21 18:00:00', 1, 0),
(639, 17, 75, '2024-03-21 18:00:00', 1, 0),
(640, 18, 75, '2024-03-21 18:00:00', 1, 1),
(641, 19, 75, '2024-03-21 18:00:00', 1, 1),
(642, 20, 75, '2024-03-21 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 75;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(643, 16, 76, '2024-03-25 18:00:00', 1, 0),
(644, 17, 76, '2024-03-25 18:00:00', 1, 0),
(645, 18, 76, '2024-03-25 18:00:00', 1, 0),
(646, 19, 76, '2024-03-25 18:00:00', 1, 1),
(647, 20, 76, '2024-03-25 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 76;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(648, 16, 77, '2024-03-28 18:00:00', 1, 0),
(649, 17, 77, '2024-03-28 18:00:00', 1, 1),
(650, 18, 77, '2024-03-28 18:00:00', 1, 1),
(651, 19, 77, '2024-03-28 18:00:00', 1, 0),
(652, 20, 77, '2024-03-28 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 77;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(653, 16, 78, '2024-04-01 18:00:00', 1, 0),
(654, 17, 78, '2024-04-01 18:00:00', 1, 1),
(655, 18, 78, '2024-04-01 18:00:00', 1, 0),
(656, 19, 78, '2024-04-01 18:00:00', 1, 0),
(657, 20, 78, '2024-04-01 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 78;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(658, 16, 79, '2024-04-04 18:00:00', 1, 1),
(659, 17, 79, '2024-04-04 18:00:00', 1, 1),
(660, 18, 79, '2024-04-04 18:00:00', 1, 1),
(661, 19, 79, '2024-04-04 18:00:00', 1, 0),
(662, 20, 79, '2024-04-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 79;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(663, 16, 80, '2024-04-08 18:00:00', 1, 0),
(664, 17, 80, '2024-04-08 18:00:00', 1, 0),
(665, 18, 80, '2024-04-08 18:00:00', 1, 1),
(666, 19, 80, '2024-04-08 18:00:00', 1, 1),
(667, 20, 80, '2024-04-08 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 80;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(668, 16, 81, '2024-04-11 18:00:00', 1, 1),
(669, 17, 81, '2024-04-11 18:00:00', 1, 1),
(670, 18, 81, '2024-04-11 18:00:00', 1, 0),
(671, 19, 81, '2024-04-11 18:00:00', 1, 0),
(672, 20, 81, '2024-04-11 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 81;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(673, 16, 82, '2024-04-15 18:00:00', 1, 0),
(674, 17, 82, '2024-04-15 18:00:00', 1, 0),
(675, 18, 82, '2024-04-15 18:00:00', 1, 0),
(676, 19, 82, '2024-04-15 18:00:00', 1, 0),
(677, 20, 82, '2024-04-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 82;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(678, 16, 83, '2024-04-18 18:00:00', 1, 0),
(679, 17, 83, '2024-04-18 18:00:00', 1, 0),
(680, 18, 83, '2024-04-18 18:00:00', 1, 0),
(681, 19, 83, '2024-04-18 18:00:00', 1, 0),
(682, 20, 83, '2024-04-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 83;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(683, 16, 84, '2024-04-22 18:00:00', 1, 0),
(684, 17, 84, '2024-04-22 18:00:00', 1, 0),
(685, 18, 84, '2024-04-22 18:00:00', 1, 0),
(686, 19, 84, '2024-04-22 18:00:00', 1, 0),
(687, 20, 84, '2024-04-22 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 84;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(688, 16, 85, '2024-04-25 18:00:00', 1, 0),
(689, 17, 85, '2024-04-25 18:00:00', 1, 0),
(690, 18, 85, '2024-04-25 18:00:00', 1, 0),
(691, 19, 85, '2024-04-25 18:00:00', 1, 0),
(692, 20, 85, '2024-04-25 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 85;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(693, 16, 86, '2024-04-29 18:00:00', 1, 0),
(694, 17, 86, '2024-04-29 18:00:00', 1, 0),
(695, 18, 86, '2024-04-29 18:00:00', 1, 0),
(696, 19, 86, '2024-04-29 18:00:00', 1, 0),
(697, 20, 86, '2024-04-29 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 86;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(698, 16, 87, '2024-05-02 18:00:00', 1, 0),
(699, 17, 87, '2024-05-02 18:00:00', 1, 0),
(700, 18, 87, '2024-05-02 18:00:00', 1, 0),
(701, 19, 87, '2024-05-02 18:00:00', 1, 0),
(702, 20, 87, '2024-05-02 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 87;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(703, 16, 88, '2024-05-06 18:00:00', 1, 0),
(704, 17, 88, '2024-05-06 18:00:00', 1, 0),
(705, 18, 88, '2024-05-06 18:00:00', 1, 0),
(706, 19, 88, '2024-05-06 18:00:00', 1, 0),
(707, 20, 88, '2024-05-06 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 88;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(708, 12, 89, '2024-01-27 18:00:00', 1, 1),
(709, 13, 89, '2024-01-27 18:00:00', 1, 0),
(710, 14, 89, '2024-01-27 18:00:00', 1, 0),
(711, 15, 89, '2024-01-27 18:00:00', 1, 1),
(712, 16, 89, '2024-01-27 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 89;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(713, 12, 90, '2024-02-03 18:00:00', 1, 1),
(714, 13, 90, '2024-02-03 18:00:00', 1, 1),
(715, 14, 90, '2024-02-03 18:00:00', 1, 0),
(716, 15, 90, '2024-02-03 18:00:00', 1, 1),
(717, 16, 90, '2024-02-03 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 90;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(718, 12, 91, '2024-02-10 18:00:00', 1, 1),
(719, 13, 91, '2024-02-10 18:00:00', 1, 1),
(720, 14, 91, '2024-02-10 18:00:00', 1, 0),
(721, 15, 91, '2024-02-10 18:00:00', 1, 0),
(722, 16, 91, '2024-02-10 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 91;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(723, 12, 92, '2024-02-17 18:00:00', 1, 0),
(724, 13, 92, '2024-02-17 18:00:00', 1, 1),
(725, 14, 92, '2024-02-17 18:00:00', 1, 0),
(726, 15, 92, '2024-02-17 18:00:00', 1, 1),
(727, 16, 92, '2024-02-17 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 92;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(728, 12, 93, '2024-02-24 18:00:00', 1, 1),
(729, 13, 93, '2024-02-24 18:00:00', 1, 1),
(730, 14, 93, '2024-02-24 18:00:00', 1, 0),
(731, 15, 93, '2024-02-24 18:00:00', 1, 0),
(732, 16, 93, '2024-02-24 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 93;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(733, 12, 94, '2024-03-02 18:00:00', 1, 1),
(734, 13, 94, '2024-03-02 18:00:00', 1, 1),
(735, 14, 94, '2024-03-02 18:00:00', 1, 0),
(736, 15, 94, '2024-03-02 18:00:00', 1, 1),
(737, 16, 94, '2024-03-02 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 94;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(738, 12, 95, '2024-03-09 18:00:00', 1, 0),
(739, 13, 95, '2024-03-09 18:00:00', 1, 1),
(740, 14, 95, '2024-03-09 18:00:00', 1, 0),
(741, 15, 95, '2024-03-09 18:00:00', 1, 1),
(742, 16, 95, '2024-03-09 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 95;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(743, 12, 96, '2024-03-16 18:00:00', 1, 0),
(744, 13, 96, '2024-03-16 18:00:00', 1, 0),
(745, 14, 96, '2024-03-16 18:00:00', 1, 1),
(746, 15, 96, '2024-03-16 18:00:00', 1, 0),
(747, 16, 96, '2024-03-16 18:00:00', 1, 1);
UPDATE class SET open_slot = 10 WHERE id = 96;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(748, 12, 97, '2024-03-23 18:00:00', 1, 0),
(749, 13, 97, '2024-03-23 18:00:00', 1, 1),
(750, 14, 97, '2024-03-23 18:00:00', 1, 0),
(751, 15, 97, '2024-03-23 18:00:00', 1, 0),
(752, 16, 97, '2024-03-23 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 97;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(753, 12, 98, '2024-03-30 18:00:00', 1, 0),
(754, 13, 98, '2024-03-30 18:00:00', 1, 0),
(755, 14, 98, '2024-03-30 18:00:00', 1, 1),
(756, 15, 98, '2024-03-30 18:00:00', 1, 0),
(757, 16, 98, '2024-03-30 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 98;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(758, 12, 99, '2024-04-06 18:00:00', 1, 0),
(759, 13, 99, '2024-04-06 18:00:00', 1, 1),
(760, 14, 99, '2024-04-06 18:00:00', 1, 0),
(761, 15, 99, '2024-04-06 18:00:00', 1, 0),
(762, 16, 99, '2024-04-06 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 99;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(763, 12, 100, '2024-04-13 18:00:00', 1, 0),
(764, 13, 100, '2024-04-13 18:00:00', 1, 0),
(765, 14, 100, '2024-04-13 18:00:00', 1, 0),
(766, 15, 100, '2024-04-13 18:00:00', 1, 0),
(767, 16, 100, '2024-04-13 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 100;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(768, 12, 101, '2024-04-20 18:00:00', 1, 0),
(769, 13, 101, '2024-04-20 18:00:00', 1, 0),
(770, 14, 101, '2024-04-20 18:00:00', 1, 0),
(771, 15, 101, '2024-04-20 18:00:00', 1, 0),
(772, 16, 101, '2024-04-20 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 101;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(773, 12, 102, '2024-04-27 18:00:00', 1, 0),
(774, 13, 102, '2024-04-27 18:00:00', 1, 0),
(775, 14, 102, '2024-04-27 18:00:00', 1, 0),
(776, 15, 102, '2024-04-27 18:00:00', 1, 0),
(777, 16, 102, '2024-04-27 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 102;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES
(778, 12, 103, '2024-05-04 18:00:00', 1, 0),
(779, 13, 103, '2024-05-04 18:00:00', 1, 0),
(780, 14, 103, '2024-05-04 18:00:00', 1, 0),
(781, 15, 103, '2024-05-04 18:00:00', 1, 0),
(782, 16, 103, '2024-05-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 10 WHERE id = 103;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (783, 2, 104, '2024-01-29 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (21, 4, 783, 2, 50.00, '2024-01-29 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (784, 2, 105, '2024-01-30 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (22, 4, 784, 2, 50.00, '2024-01-30 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (785, 2, 106, '2024-02-05 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (23, 4, 785, 2, 50.00, '2024-02-05 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (786, 2, 107, '2024-02-06 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (24, 4, 786, 2, 50.00, '2024-02-06 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (787, 2, 108, '2024-02-12 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (25, 4, 787, 2, 50.00, '2024-02-12 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (788, 2, 109, '2024-02-13 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (26, 4, 788, 2, 50.00, '2024-02-13 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (789, 2, 110, '2024-02-19 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (27, 4, 789, 2, 50.00, '2024-02-19 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (790, 2, 111, '2024-02-20 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (28, 4, 790, 2, 50.00, '2024-02-20 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (791, 3, 112, '2024-02-26 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (29, 4, 791, 3, 50.00, '2024-02-26 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (792, 3, 113, '2024-02-27 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (30, 4, 792, 3, 50.00, '2024-02-27 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (793, 3, 114, '2024-03-04 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (31, 4, 793, 3, 50.00, '2024-03-04 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (794, 3, 115, '2024-03-05 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (32, 4, 794, 3, 50.00, '2024-03-05 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (795, 3, 116, '2024-03-11 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (33, 4, 795, 3, 50.00, '2024-03-11 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (796, 3, 117, '2024-03-12 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (34, 4, 796, 3, 50.00, '2024-03-12 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (797, 3, 118, '2024-03-18 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (35, 4, 797, 3, 50.00, '2024-03-18 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (798, 3, 119, '2024-03-19 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (36, 4, 798, 3, 50.00, '2024-03-19 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (799, 3, 120, '2024-03-25 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (37, 4, 799, 3, 50.00, '2024-03-25 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (800, 3, 121, '2024-03-26 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (38, 4, 800, 3, 50.00, '2024-03-26 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (801, 4, 122, '2024-04-01 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (39, 4, 801, 4, 50.00, '2024-04-01 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (802, 4, 123, '2024-04-02 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (40, 4, 802, 4, 50.00, '2024-04-02 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (803, 4, 124, '2024-04-08 18:00:00', 1, 1);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (41, 4, 803, 4, 50.00, '2024-04-08 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (804, 4, 125, '2024-04-09 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (42, 4, 804, 4, 50.00, '2024-04-09 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (805, 4, 126, '2024-04-15 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (43, 4, 805, 4, 50.00, '2024-04-15 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (806, 4, 127, '2024-04-16 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (44, 4, 806, 4, 50.00, '2024-04-16 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (807, 4, 128, '2024-04-22 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (45, 4, 807, 4, 50.00, '2024-04-22 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (808, 4, 129, '2024-04-23 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (46, 4, 808, 4, 50.00, '2024-04-23 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (809, 5, 130, '2024-04-29 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (47, 4, 809, 5, 50.00, '2024-04-29 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (810, 5, 131, '2024-04-30 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (48, 4, 810, 5, 50.00, '2024-04-30 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (811, 5, 132, '2024-05-06 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (49, 4, 811, 5, 50.00, '2024-05-06 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (812, 5, 133, '2024-05-07 18:00:00', 1, 0);
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (50, 4, 812, 5, 50.00, '2024-05-07 18:00:00', 1);
UPDATE class SET open_slot = 0 WHERE class_type = 5;
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (813, 11, 138, '2024-02-25 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 138;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (51, 4, 813, 11, 50.00, '2024-02-25 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (814, 11, 139, '2024-03-03 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 139;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (52, 4, 814, 11, 50.00, '2024-03-03 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (815, 12, 143, '2024-03-31 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 143;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (53, 4, 815, 12, 50.00, '2024-03-31 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (816, 12, 145, '2024-04-14 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 145;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (54, 4, 816, 12, 50.00, '2024-04-14 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (817, 12, 146, '2024-04-21 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 146;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (55, 4, 817, 12, 50.00, '2024-04-21 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (818, 15, 149, '2024-01-29 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 149;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (56, 4, 818, 15, 50.00, '2024-01-29 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (819, 15, 150, '2024-02-01 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 150;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (57, 4, 819, 15, 50.00, '2024-02-01 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (820, 15, 154, '2024-02-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 154;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (58, 4, 820, 15, 50.00, '2024-02-15 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (821, 16, 159, '2024-03-04 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 159;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (59, 4, 821, 16, 50.00, '2024-03-04 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (822, 16, 160, '2024-03-07 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 160;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (60, 4, 822, 16, 50.00, '2024-03-07 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (823, 16, 161, '2024-03-11 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 161;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (61, 4, 823, 16, 50.00, '2024-03-11 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (824, 16, 162, '2024-03-14 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 162;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (62, 4, 824, 16, 50.00, '2024-03-14 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (825, 16, 163, '2024-03-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 163;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (63, 4, 825, 16, 50.00, '2024-03-18 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (826, 17, 166, '2024-03-28 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 166;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (64, 4, 826, 17, 50.00, '2024-03-28 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (827, 17, 167, '2024-04-01 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 167;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (65, 4, 827, 17, 50.00, '2024-04-01 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (828, 17, 169, '2024-04-08 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 169;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (66, 4, 828, 17, 50.00, '2024-04-08 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (829, 17, 171, '2024-04-15 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 171;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (67, 4, 829, 17, 50.00, '2024-04-15 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (830, 17, 172, '2024-04-18 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 172;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (68, 4, 830, 17, 50.00, '2024-04-18 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (831, 17, 173, '2024-04-22 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 173;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (69, 4, 831, 17, 50.00, '2024-04-22 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (832, 18, 175, '2024-04-29 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 175;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (70, 4, 832, 18, 50.00, '2024-04-29 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (833, 11, 181, '2024-02-20 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 181;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (71, 4, 833, 11, 50.00, '2024-02-20 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (834, 11, 182, '2024-02-27 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 182;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (72, 4, 834, 11, 50.00, '2024-02-27 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (835, 11, 184, '2024-03-12 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 184;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (73, 4, 835, 11, 50.00, '2024-03-12 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (836, 11, 185, '2024-03-19 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 185;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (74, 4, 836, 11, 50.00, '2024-03-19 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (837, 11, 186, '2024-03-26 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 186;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (75, 4, 837, 11, 50.00, '2024-03-26 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (838, 11, 188, '2024-04-09 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 188;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (76, 4, 838, 11, 50.00, '2024-04-09 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (839, 11, 189, '2024-04-16 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 189;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (77, 4, 839, 11, 50.00, '2024-04-16 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (840, 12, 194, '2024-02-07 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 194;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (78, 4, 840, 12, 50.00, '2024-02-07 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (841, 12, 195, '2024-02-14 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 195;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (79, 4, 841, 12, 50.00, '2024-02-14 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (842, 12, 196, '2024-02-21 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 196;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (80, 4, 842, 12, 50.00, '2024-02-21 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (843, 12, 197, '2024-02-28 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 197;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (81, 4, 843, 12, 50.00, '2024-02-28 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (844, 12, 199, '2024-03-13 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 199;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (82, 4, 844, 12, 50.00, '2024-03-13 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (845, 12, 202, '2024-04-03 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 202;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (83, 4, 845, 12, 50.00, '2024-04-03 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (846, 12, 203, '2024-04-10 18:00:00', 1, 1);
UPDATE class SET open_slot = 0 WHERE id = 203;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (84, 4, 846, 12, 50.00, '2024-04-10 18:00:00', 1);
INSERT INTO booking (id, member_id, class_id, create_time, status, is_attended) VALUES (847, 12, 205, '2024-04-24 18:00:00', 1, 0);
UPDATE class SET open_slot = 0 WHERE id = 205;
INSERT INTO payment (id, product_id, booking_id, member_id, total, pay_time, is_paid) VALUES (85, 4, 847, 12, 50.00, '2024-04-24 18:00:00', 1);


INSERT INTO `news` 
VALUES
(1, 1, 'Swimming Club Community Day'
, "Swimming Club Community Day, Swim's brand-new pool, library and service centre complex officially opens from 3pm on Friday 19 April.Join us as we celebrate the opening of Swimming Club Swim Centre with our fun-filled community day. Jump, rush and bash your way through the inflatable obstacle course in the pool, or chill out in the library and check out the huge array of books on offer. We're fortunate enough to have The Hits broadcasting live onsite throughout the day offering on-air opportunities to our tamariki, giveaways and more.
There's even more fun to be had including virtual reality sessions, bookmark making with our in-house laser cutter, scavenger hunts, board games, arts and crafts and so much more. We'll also be activating in Kyle Park with sports and kai. Don't fancy a dip in the pool? We'll be running free tours around the pool space every 15 minutes.
When: Saturday 20 April
Where: Swimming Club Swim Centre, 25 Smarts Road, Swim
Time: 10am - 4pm
Price: The community day is free, but if you're swimming, standard pool entry fees apply.
Please note that we expect the community day to be busy. Capacity is limited within each space of the centre which means sometimes we'll be running a one-in, one-out system.
There will be plenty to do on the day within Swimming Club Swim Centre and Kyle Park so we encourage you to go and explore it all.We can't wait to see you there!"
, '2024-04-01 8:00:00'),
(2, 2, "Swim Centre opening Friday 19 April!"
, "Swimming Club Centre, in Kyle Park, will be officially opened by Mayor Phil Mauger at a formal ceremony starting at 1pm.
The formalities will be followed by a full day of community activities and celebrations on Saturday 20 April.
“We’re looking forward to opening the doors and welcoming the community,” says Council Head of Recreation, Sports and Events Nigel Cox.
“After years of planning and hard work, it’s fantastic to see the project enter the homestretch.”
The construction phase of the project is due to wrap up next month, when the site will be handed over to the Council for the fit-out.
“We’ll be completing the operational fit out, training and inducting team members, and testing equipment to make sure everything is shipshape before Swimming Club opens its doors to the community,” says Mr Cox.
Head of Libraries and Information Carolyn Robertson says the team at Swim Library is gearing up for their big move from Goulding Avenue.
“Preparations are in full swing to pack up the Swim Library collection and shift everything to its new home at Swimming Club. There are around 19,000 items to move, so between the shift and getting familiar with the new site, it will be a busy and exciting time for our staff,” says Ms Robertson.
The Goulding Avenue library will close on Thursday 28 March for the shift. The customer services desk at Goulding Avenue will remain open until 5pm Friday 19 April, before also shifting across to Swimming Club. The customer services team will continue to offer their full range of services like council payments and dog registrations.
Swim Councillor Mark Peters says the Swimming Club opening will be “a landmark day for Swim”.
“I'm really looking forward to seeing the Swim and southwest Christchurch communities having ready access to this fabulous indoor aquatic centre, customer services hub, and a great, modern library,” says Cr Peters.
Swim Rotary and the Greater Swim Residents’ Association are working alongside the Council to fundraise $1.4 million for a hydrotherapy pool at the facility. The groups have raised over $1.1 million to date.
“The Swimming Club hydrotherapy pool is only the second public one in Christchurch and is much awaited by many who currently have to go to Rolleston or all the way across town to Taiora QEII,” says Cr Peters.
The Swimming Club Swim Centre pool complex also includes a lane pool, learn-to-swim pool, family spa pool, and toddlers’ wet play area.
The centre also includes the Auahatanga Creative Space, which includes resources like a laser cutter, 3D printer, audio/visual recording equipment, and sewing machines. The library will also have 12 public computers.
The 4000m2 site also includes a café, bookable meeting rooms and outdoor courtyard."
, '2024-02-18 9:15:00'), 
(3, 2, 'Hydrotherapy pool fundraiser going strong'
, "Since launching their campaign in 2022, the groups have raised $1.1million in generous grants from:
Swim Rotary $100,000
Lotteries $300,000
Rata Foundation $300,000
New Zealand Community Trust $400,000
The groups also report that they have sold 67 bubbles through their 'Buy a Bubble' campaign, raising $38,000 (and counting!)."
, '2023-11-18 10:30:00'),
(4, 1, 'Summer pools opening Show Weekend', "From Saturday 18 November, the Norman Kirk Memorial pool in Lyttelton, the Templeton summer pool, the Waltham summer pool, and Jellie Park summer pool in Burnside will all be open. Te Hāpua Halswell summer pool opens a day later on Sunday 19 November.
Paddling pools in Scarborough, New Brighton and the Botanic Gardens opened on Saturday 21 October, with paddling pools in Spencer Park, Edgar Macintosh Park, Avebury Park, Woodham Park, and Abberley Park opening on Friday 17 November.
Christchurch City Council Head of Recreation, Sport and Events Nigel Cox says the city’s network of outdoor summer pools are popular with a lot of people in the community.
“We had over 350,000 visits to our outdoor pools last summer season - that’s almost the equivalent of one swim for every Christchurch resident - and we’re expecting even more this year with all our facilities ready to open on Show Weekend,” says Mr Cox.
The Council has a range of events and activities scheduled during the summer pool season, which runs from Saturday 18 November 2023 until Monday 1 April 2024.
“Pool parties and the Manu Competitions are back. Keep an eye on the Rec and Sport Facebook page or website for all the latest information about how to get involved.
“Visiting the local pool is great way to spend a summer’s day with friends and whanau,” says Mr Cox.
There are a range of facilities available across the Council’s five outdoor pools, including hydro slides, lane pools, toddlers’ pools, BBQ hire and picnic areas.
“Be sure to check the opening hours and sign up for the membership systems in place for the Templeton and Norman Kirk pools,” says Mr Cox.
Templeton Summer Pool operates on a membership basis – with an $80 season pass – and members can bring guests as long as they leave payment in the honesty box.
The same system applies in Lyttelton. Lifeguards will be on duty at the Norman Kirk Memorial Pool between 11.30am and 7pm, from 18 November 2023 until 28 January next year.
Check out the summer pools page on the Council website for full pricing information, opening hours, safety information and the latest on community events for each pool."
, '2023-12-05 11:45:00'),
(5, 2, 'Lifeguard awarded Lifeguard of the Year'
, "Fifteen years later and after stints in every pool and Aquatics position at Christchurch Recreation and Sport, Ms Baen-Price has been awarded Lifeguard of the Year at the 2023 National Aquatics Awards.
Prior to this work, Ms Baen-Price completed her level four certificate and level five Outdoor Education Diploma at what’s now known as the Ara Institute of Canterbury. Following this, she undertook a Bachelor of Teaching and Learning (Primary) at the University of Canterbury.
“I took away many skills through each of these qualifications, including managing a team, dealing with customers and training staff – which I now use in my position as Team Leader Aquatics at Matitiki Swim Centre,” says Ms Baen-Price.
Since her lifeguarding career began, Ms Baen-Price has worked her way through each Council pool facility, including the old QEII and Centennial pools, and believes Christchurch residents have an amazing network of pools across the city.
She says while lifeguarding might look tame or quiet, this is how they like it to look. “It means nothing is broken, everyone is being safe, and all the hard work of training, educating and preventing rescues has already been done.
“I’ve stayed as a lifeguard through the years as I enjoy the customers, and I’m passionate about water safety and keeping people in our communities active.
“It’s a huge motivator working as part of a team that really aligns with my goals. We all want to see more people in, being active and having fun. My team are awesome people that make coming to work fun.”
Duties behind the scenes for the lifeguard team include water quality, lifeguard training and plantroom maintenance.
Ms Baen-Price says it’s great to be able to represent the Council at a national level through the National Aquatics Awards. “Just being nominated is an honour! Lifeguarding is a great job, with a great work-life balance.”
Ms Baen-Price passes on her congratulations to other finalists, including Christchurch City Council Graham Condon Recreation and Sport Centre’s Martin D’Orso - who received one of the two Merit Awards presented at the ceremony.
Christchurch City Council also received the Aquatic Innovation Award in collaboration with Youth and Cultural Development and Sport Canterbury, for the FRESH Pool Parties. This initiative aims to engage youth and whānau from a high deprivation region of Christchurch in active recreation."
, '2023-09-21 13:00:00'),
(6, 1, 'Swimming lessons for adults'
, "Not all adults learn to swim as a child and some may have base skills that haven't been used for a long time. Swimming is a great skill and activity for people of all ages, it is never to late to learn or to get back into it.
Recreation and Sport Centres offer adult classes that suit all levels - ranging from basic swimming introduction skills to endurance technique development.
Adult beginner
This class is perfect for adults new to swimming. Our patient and experienced teachers will help you overcome any obstacles you may have, to help you to become a competent swimmer.
Adult breathers
A mid-level class designed for improvement of swimming skills including stroke and breathing. We will teach you the technical components of swimming helping you to become more confident and strong in the water.
Adult stroke correction
A technical level class designed to work on a variety of stroke techniques so you can swim more efficiently. Being efficient allows you to increase your swim distance comfortably.
Extension squad
A high level class building on skills learnt previously, the extension squad offers swimmers the chance to increase distance and stamina.
Whatever your level of ability, working on your skills will give you a whole new level of confidence." 
, '2023-08-07 14:00:00'),
(7, 1, 'Starting young with water confidence'
, "Introduce your child to water in the familiar surroundings of their own home or local pool.
Supervision of your child is critical at all times when water is involved.
Bath time
With a sponge or cup gently trickle water over your child’s head and body. Help get them ready for the pouring water by using a cue phrase. One example is “child’s name, 1, 2, 3, go”. This helps a child to become more familiar with water.
Singing songs
Songs can be adapted to fit any water movement. 'The wheels on the bus' arms going around, the wipers swish back and forward, the horn goes beep beep as we splash the water. Use a song your child knows and your imagination!
Outside fun
Paddling pools and buckets provide lots of fun.  Pouring, splashing, blowing bubbles and floating activities are popular. Use the garden hose to create rain and let the children run in and out. Create a fun and safe experience with water.
The local pool
Christchurch City Council has five facilities that have multi use pools. They are designed for children to experience water in a fun and safe way.
A great way to start is to attend a Bubbletimes or Sleepytimes class. These are on a casual basis and will help build your preschooler's water confidence."
, '2023-07-09 16:45:00'),
(8, 2, 'Swim sports for passionate young swimmers'
, "Remember safety is the most important thing. Check the conditions, weather forecast, tides and always swim with others.
Open water swimming
You don’t have to be in open water to train for open water, make the most of the indoor pool to train for open water swimming.  When swimming long distances it helps to have a good freestyle so make sure you get your technique right. Practice starting your swim from treading water as there are no walls to hold on to or kick off from. 
Swimsmart Silver Extension Squads
These are 60 minute sessions where participants work on increasing stamina over a longer distance while working on improving technique. This is a non-competitive group that encourages you to push yourself to improve personal best times. Speak to our friendly customer experience team at any of our five centres to find out more.
Swim clubs
Clubs give you the opportunity to compete at local, national and international level.  The team environment within clubs provides great support - encouraging swimmers to do their best while still having fun.
Water polo
A great team sport, and one that requires players to swim the majority of the time, even if just treading water. Strong swimming skills and good stamina will be valuable for water polo players. A lot of Intermediate and Secondary schools have teams, so get in there and give it a go!
Multi-visit card
Regular swimming will keep you fit and continue to improve your technique. Multi-visit cards and support with your swimming programme is available at Graham Condon, Jellie Park, Pioneer, Taiora QEII or Te Pou Toetoe Linwood Pool. Speak to our friendly customer experience team at your local centre today."
, '2023-04-10 17:00:00'),
(9, 2, 'Why group fitness increases motivation'
, "We all love to laugh, joke and have fun. In a world where email, texting and social media is increasingly the normal way to interact, working out with a group offers that human connection that is sometimes missing in day-to-day life.
We can do just about everything today virtually without ever talking to a person - with group fitness you have to get involved.
Participating in group fitness helps to motivate and push you further than exercising alone - here's why:
For many people getting and staying motivated to exercise can be difficult. Many people who attend a group fitness class show up exhausted from the stresses of everyday life but once they join the group, they become re-energized. Group fitness instructors provide direction and motivation to push harder so you'll see results faster.
Many people who attend regular classes initially come for the exercise and along the way become friends with other regular participants. It truly is one of the best ways to meet people and develop a common bond while getting into shape.
Working out in a group has been proven to help you maintain your motivation through support and inspiration. On your own, it is easier to not push yourself and achieving results can take longer.
Christchurch Recreation and Sport Centres offer over 150 group fitness classes each week.
Try a class today and you will find fun, friends and improved health and fitness."
, '2023-03-11 9:00:00');

-- Update member table is_subscription=0 when membership expired 
DROP PROCEDURE IF EXISTS `UpdateSubscriptionStatus`;
DELIMITER //
CREATE PROCEDURE `UpdateSubscriptionStatus`()
BEGIN
    UPDATE member
    SET is_subscription = 0
    WHERE expired_date < CURDATE();
END//
DELIMITER ;

-- Create event to update membership status at 00:00 every day
DROP EVENT IF EXISTS UpdateSubscriptionEvent;
CREATE EVENT UpdateSubscriptionEvent
    ON SCHEDULE EVERY 1 DAY
    STARTS TIMESTAMP(CURRENT_DATE)
    DO
        CALL UpdateSubscriptionStatus();

-- Call the procedure to update membership status as of now
CALL UpdateSubscriptionStatus();
