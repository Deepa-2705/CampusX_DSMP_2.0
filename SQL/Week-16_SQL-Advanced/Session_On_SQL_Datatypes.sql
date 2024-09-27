USE dsmp;

-- SQL DATATYPES --

-- TINYINT --
CREATE TABLE dt_demo(
	# RANGE OF TINYINT IS -128 TO 127. BUT IF WE USE UNSIGNED THEN 127+127+1=255
    user_id TINYINT,
    course_id TINYINT UNSIGNED
);

INSERT INTO dt_demo VALUES (200,200); # 200 will not store to user_id as it is out of its range limit. But course_id can store it.

INSERT INTO dt_demo VALUES (20,200);

SELECT * FROM dt_demo;

-- DECIMAL --
ALTER TABLE dt_demo ADD COLUMN price DECIMAL(5,2);

UPDATE dt_demo SET price=234.56;
UPDATE dt_demo SET price=2344.56; # error
UPDATE dt_demo SET price=234.546;

SELECT * FROM dt_demo; # it will trim input to 2 decimal places automatically

-- FLOAT --
ALTER TABLE dt_demo ADD COLUMN weight FLOAT;
INSERT INTO dt_demo (weight) VALUES (234.4756);

-- DOUBLE --
ALTER TABLE dt_demo ADD COLUMN height DOUBLE;
INSERT INTO dt_demo (height) VALUES (2344.5326);

SELECT * FROM dt_demo;

-- ENUM --
ALTER TABLE dt_demo ADD COLUMN gender ENUM('male','female','others');
UPDATE dt_demo SET gender='female';
UPDATE dt_demo SET gender='delhi'; # incorrect
SELECT * FROM dt_demo;


-- SET --
ALTER TABLE dt_demo ADD COLUMN hobbies SET('sports','gaming','travelling');
INSERT INTO dt_demo (hobbies) VALUES ('sports'),('gaming'),('sports,gaming');
INSERT INTO dt_demo (hobbies) VALUES ('delhi'),('travelling'); # wrong

-- BLOB --
ALTER TABLE dt_demo ADD COLUMN dp MEDIUMBLOB;
INSERT INTO dt_demo (dp) VALUES (LOAD_FILE("D:/Profile Data/Downloads/photograph-removebg-preview.png"));

SELECT * FROM dt_demo;

-- GEOMETRY --
ALTER TABLE dt_demo ADD COLUMN latlong GEOMETRY;
INSERT INTO dt_demo (latlong) VALUES (POINT(67.4567,89.1234));
SELECT * FROM dt_demo;
SELECT ST_ASTEXT(latlong),ST_X(latlong),ST_Y(latlong) FROM dt_demo;

-- JSON --
ALTER TABLE dt_demo ADD COLUMN descrip JSON;
INSERT INTO dt_demo (descrip) VALUES ('{"os":"andriod","type":"smartphone"}');
SELECT * FROM dt_demo;
SELECT JSON_EXTRACT(descrip,'$.type') FROM dt_demo;
SELECT JSON_EXTRACT(descrip,'$.os') FROM dt_demo;