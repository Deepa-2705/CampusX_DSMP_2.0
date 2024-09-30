Use dsmp;
CREATE TABLE uber_rides(
    ride_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER,
    start_time DATETIME,
    end_time DATETIME
);


INSERT INTO uber_rides VALUES(1,1,'2024-03-09 08:00:00','2024-03-09 09:00:00');
INSERT INTO uber_rides VALUES(2,3,'2024-03-09 22:00:00','2024-03-10 12:30:00');
INSERT INTO uber_rides VALUES(3,3,'2024-03-10 15:00:00','2024-03-10 15:30:00');
INSERT INTO uber_rides VALUES(6,31,'2024-03-11 19:00:00','2024-03-11 20:30:00');
INSERT INTO uber_rides VALUES(22,33,'2024-03-11 22:00:00','2024-03-11 22:30:00');

SELECT * FROM uber_rides;

-- DATETIME FUNCTIONS --

SELECT CURRENT_DATE();
SELECT CURRENT_TIME();
SELECT NOW(); # It will tell both current date and time 

-- EXTRACTION FUNCTIONS --
# 1. DATE() and TIME()
# 2. YEAR()
# 3. DAY() or DAYOFMONTH()
# 4. DAYOFWEEK()
# 5. DAYOFYEAR()
# 6. MONTH() and MONTHNAME()
# 7. QUARTER()
# 8. WEEK() or WEEKOFYEAR()
# 9. HOUR()> MINUTE() > SECOND()
# 10. LAST DAY()

SELECT *,
DATE(start_time),
TIME(start_time),
YEAR(start_time),
MONTH(start_time),
MONTHNAME(start_time),
DAY(start_time),
DAYOFWEEK(start_time),
DAYNAME(start_time),
QUARTER(start_time),
HOUR(start_time),
minute(start_time),
SECOND(start_time),
DAYOFYEAR(start_time),
WEEKOFYEAR(start_time),
LAST_DAY(start_time)
FROM uber_rides;


 -- DATE FORMATTING --
 
 # 1) DATE FORMAT
 # 2) TIME FORMAT
 
 SELECT * ,DATE_FORMAT(start_time,'%d %b, %y') FROM uber_rides; # date, 3 char of month, 2 digit of year
 
 SELECT * ,DATE_FORMAT(start_time,'%r') FROM uber_rides;
 SELECT * ,DATE_FORMAT(start_time,'%l:%i %p') FROM uber_rides; # 12-hour formatted :  hour, minute , am/pm
 
 -- NOTE : https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html#function_date-format
 
 -- TYPE CONVERSION 
--          ~ implicit type conversion   ~ Explicit type conversion

SELECT '26-09-2024'>'24-09-2024';
SELECT '26-09-2024'>'9 september 2024'; # it is doing string comparision (based on 2,9 not on date)
# in above query implicit type conversion fails. So we have to do explicit type conversion

SELECT MONTHNAME('9 september 2024'); # sql will not considered it as date
SELECT MONTHNAME(STR_TO_DATE('9 mar 2024','%e %b %Y'));
SELECT DAYNAME(STR_TO_DATE('19 mar 2024','%e %b %Y'));

SELECT MONTHNAME(STR_TO_DATE('9-mar hello 2024','%e-%b hello %Y'));

-- DATETIME ARITHMETIC --
# 1) DATEDIFF()
# 2) TIMEDIFF()
# 3) DATE_ADD() AND DATE_SUB()
# 4) ADDTIME() AND SUBTIME()

SELECT DATEDIFF(CURRENT_DATE(),'2022-11-07');

SELECT DATEDIFF(end_time,start_time) FROM uber_rides;
SELECT TIMEDIFF(end_time,start_time) FROM uber_rides;

# Interval
# What will be date after 10 years from current date
SELECT NOW(),DATE_ADD(NOW(),INTERVAL 10 YEAR);
SELECT NOW(),DATE_ADD(NOW(),INTERVAL 10 MONTH);
SELECT NOW(),DATE_ADD(NOW(),INTERVAL 10 DAY);
SELECT NOW(),DATE_ADD(NOW(),INTERVAL 10 MINUTE);
SELECT NOW(),DATE_ADD(NOW(),INTERVAL 10 WEEK);

SELECT NOW(),DATE_SUB(NOW(),INTERVAL 10 QUARTER);
SELECT NOW(),DATE_SUB(NOW(),INTERVAL 10 YEAR);

# DATETIME VS TIMESTAMP
CREATE TABLE posts(
   post_id INTEGER PRIMARY KEY AUTO_INCREMENT,
   user_id INTEGER,
   content text,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
   updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP);
   
INSERT INTO posts(user_id,content) VALUES (1,'hello world');
SELECT * FROM posts;

UPDATE posts SET content=('no hello world') WHERE post_id=1;
   
   