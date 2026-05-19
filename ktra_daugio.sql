CREATE DATABASE ktra_daugio;
USE ktra_daugio;


CREATE TABLE students(
    student_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10,2) DEFAULT 0
);


CREATE TABLE subjects(
    subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credits INT CHECK(credits > 0)
);



CREATE TABLE grades(
    student_id VARCHAR(5),
    subject_id VARCHAR(5),
    score DECIMAL(4,2) CHECK(score BETWEEN 0 AND 10),
    PRIMARY KEY(student_id, subject_id),
    FOREIGN KEY(student_id) REFERENCES students(student_id),
    FOREIGN KEY(subject_id) REFERENCES subjects(subject_id)
);



CREATE TABLE grade_log(
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(5),
    old_score DECIMAL(4,2),
    new_score DECIMAL(4,2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(student_id) REFERENCES students(student_id)
);



INSERT INTO students (student_id, full_name, total_debt) VALUES 
('SV01', 'Le Hoang Nam', 3500000.00),
('SV03', 'Tran Quoc Anh', 0.00),       
('SV04', 'Vu Phuong Thao', 1500000.00);



INSERT INTO subjects (subject_id, subject_name, credits) VALUES 
('SUB01', 'Database Systems', 3),
('SUB02', 'Java Programming', 4),
('SUB03', 'Web Development', 3);



INSERT INTO grades (student_id, subject_id, score) VALUES 
('SV01', 'SUB01', 3.50), 
('SV01', 'SUB02', 7.50),  
('SV04', 'SUB01', 5.00);


DELIMITER //

CREATE TRIGGER tg_check_score
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN

    IF NEW.score < 0 THEN
	SET NEW.score = 0;
    END IF;

    IF NEW.score > 10 THEN
	SET NEW.score = 10;
    END IF;

END //

DELIMITER ;

START TRANSACTION;
INSERT INTO students(student_id, full_name)
VALUES ('SV02', 'Ha Bich Ngoc');
UPDATE students
SET total_debt = 5000000 WHERE student_id = 'SV02';
COMMIT;




DELIMITER //

CREATE TRIGGER tg_log_grade_update 
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN

INSERT INTO grade_log(student_id,old_score, new_score,change_date)
VALUES( OLD.student_id, OLD.score, NEW.score, NOW() );

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_pay_tuition()
BEGIN
START TRANSACTION;

UPDATE students
SET total_debt = total_debt - 2000000
WHERE student_id = 'SV01';
    IF (
        SELECT total_debt FROM students
        WHERE student_id = 'SV01'
    ) < 0 THEN
        ROLLBACK;
	ELSE
        COMMIT;
	END IF;

END //

DELIMITER ;

CALL sp_pay_tuition(); 


DELIMITER //

CREATE TRIGGER tg_prevent_pass_update
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN

    IF OLD.score >= 4.0 THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Qua mon roi, khong duoc sua diem ';
    END IF;

END //

DELIMITER ;