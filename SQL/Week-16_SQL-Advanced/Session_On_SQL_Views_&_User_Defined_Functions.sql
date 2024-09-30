USE dsmp;
SELECT * FROM flights;

# SIMPLE VIEWS
# create a view of flight dataset that has has only Indigo dataset
CREATE VIEW indigo AS SELECT * FROM flights WHERE Airline='Indigo';

SELECT * FROM indigo; 

-- NOTE : THIS VIEW IS NOT STORED IN MEMORY (VIRTUAL TABLE). WHENEVER WE RUN ANY QUERY USING VIEW THEN THE ABOVE VIEW CREATION QUERY WILL RUN FIRST.

# Sql treats view and physical tables equally
SHOW TABLES; #  we can see view here too

# COMPLEX VIEWS
# creating a complex view by joining multiple tables
USE zomato;
CREATE VIEW joined_order_data AS SELECT order_id,name,r_name,restaurant_rating,date,amount,delivery_time,delivery_rating 
FROM orders t1 JOIN users t2 ON t1.user_id=t2.user_id JOIN restaurants t3 ON t1.r_id=t3.r_id;

SELECT * FROM joined_order_data;

# total profit of restaurants month wise
SELECT r_name,MONTHNAME(date),SUM(amount) FROM joined_order_data GROUP BY r_name,MONTH(date);

-- ADVANTAGE OF VIEW IS THAT WE HAVE A NEW VIRTUAL TABLE THAT IS WORKING AS NORMAL TABLE AND WE DONT HAVE TO CREATE JOINS EVERYTIME.
-- WE CAN JOIN PHYSICAL TABLE WITH THIS VIRTUAL TABLE TOO

-- ADVANTAGE OF VIEWS OVER CTs :
-- EVEN IF SHUT DOWN THE LAPTOP STILL WE CAN ACCESS ALL VIEWS BUT SCOPE OF CTs WILL BE REMOVED.

-- 4 SIMILAR CONCEPT
-- 1) SUBQUERY     2) CTs      3) VIEWS    4) TEMPORARY TABLES

# READ ONLY VIEWS
# UPDATABLE VIEWS (IF WE MAKE CHANGES IN VIEWS THEN ORIGINAL TABLE WILL ALSO SHOWS MODIFICATION)
# AND (CHANGES MADE IN ORIGINAL TABLE WILL ALSO REFLECT IN VIEWS)

USE dsmp;
UPDATE flights SET Source='Bangaluru' WHERE Source='Banglore';
SELECT * FROM flights;
SELECT * FROM indigo;

UPDATE indigo SET Destination='Delhi' WHERE Destination='New Delhi';
SELECT * FROM indigo;
SELECT * FROM flights; # we can see New Delhi gets changed to Delhi where Airline='Indigo'

-- RULES FOR UPDATABLE VIEWS
-- NOTE : dev.mysql.com/doc/refman/8.0/en/view-updability.html

USE zomato;
DELETE FROM joined_order_data WHERE order_id=1001; # we cannot delete this view because it is made using joins

-- NOTE: VIEWS PROVIDES CONVENIENCE BUT IT'S NOT MAKING QUERY FASTER. IN SHORT NORMAL TABLE AND VIEWS BOTH TAKES SAME AMOUNT OF TIME TO EXECUTE.
-- VIEWS HELPS IN SECURITY TOO. SUPPOSE ORIGINAL TABLE HAS CREDIT CARD AND PASSWORD WE WILL DONOT WANT TO SHARE WITH USERS OF OUR WEBSITE.
-- THEN WE CAN CREATE ANOTHER VIEW HAVING REQUIRED COLUMNS ONLY. THEN BLOCK THE MAIN TABLE USING DCL COMMANDS.

-- MATERIALISED VIEW :
-- BY USING THIS VIEW OUR QUERY EXECUTES FASTER.
-- MATERIALIZED VIEWS GETS STORED IN THE MEMORY PHYSICALLY (QUERY OUTPUT). 
-- IF OUR TABLE CONTAINS CRORES OF ROWS THAN WE CAN MAKE MATERIALIZED VIEWS AND STORE THE REQUIRED RESULT IN MEMORY FOR QUICK USE IN FUTURE.
-- THESE VIEWS NEEDS TO UPDATE MANUALLY IN CASE OF ORIGINAL TABLE MODIFICATION.



-- USER DEFINE FUNCTION
-- Hello World --

USE `zomato`;
DROP function IF EXISTS `hello_world`;

DELIMITER $$
USE `zomato`$$
CREATE FUNCTION hello_world ()
RETURNS VARCHAR(255)
BEGIN
RETURN "Hello World";
END$$
DELIMITER ;

SELECT hello_world() AS message;
SELECT hello_world() FROM users;

# inbuilt functions
SELECT UPPER(name) FROM users;

# create a function that will return the age of the users from the date column
DELIMITER $$
CREATE FUNCTION calculate_age (dob DATE)
RETURNS INTEGER
BEGIN
    DECLARE age INTEGER; # variable
    SET age=ROUND(DATEDIFF(DATE(NOW()),dob)/365);
    
RETURN age;
END$$
DELIMITER ;

SELECT calculate_age('2000-10-05');
SELECT *,calculate_age(dob) FROM users;

UPDATE users SET name=LOWER(name);

# create a function that will show names of every users in a proper way (like nitish -> Mr Nitish)
# ankita -> Mrs(if married)/Ms(is unmarried) Ankita
DELIMITER $$
CREATE FUNCTION proper_name (name VARCHAR(255),gender VARCHAR(255),married VARCHAR(255))
RETURNS VARCHAR(255)
BEGIN
     DECLARE title VARCHAR(255);
     SET name=CONCAT(UPPER(LEFT(name,1)),LOWER(SUBSTRING(name,2)));
     IF gender='M' THEN 
		SET title=CONCAT('Mr',' ',name);
	 ELSE 
         IF married='Y' THEN 
		     SET title=CONCAT('Mrs',' ',name);
		 ELSE
		     SET title=CONCAT('Ms',' ',name);
		 END IF;
	 END IF;
RETURN title;
END$$
DELIMITER ;

SELECT proper_name('Nitish','M','Y');
SELECT *, proper_name(name,gender,married) FROM users;

USE dsmp;
# write a function to format the date of date_of_journey column 
DELIMITER $$
CREATE FUNCTION format_date(doj VARCHAR(255))
RETURNS VARCHAR(255)
BEGIN
RETURN DATE_FORMAT(doj,'%D %b %y');
END$$
DELIMITER ;

SELECT *,format_date(date_of_journey) FROM flights;

-- DETERMINISTIC / NON DETERMINISTIC
-- DETERMINISTIC -> IT WILL GIVE SAME OUTPUT FOR SAME INPUT EVEN IN FUTURE
-- NON DETERMINISTIC -> IT WILL GIVE DIFFERENT OUTPUT FOR SAME INPUT IN FUTURE BECAUSE OF ADDITION OR SUBTRACTION OF DATA FROM THE TABLE

# calculate the no of flights between 2 cities
DELIMITER $$
CREATE FUNCTION flight_between(city1 VARCHAR(255),city2 VARCHAR(255))
RETURNS INTEGER
BEGIN
RETURN (
      SELECT COUNT(*) FROM flights WHERE Source='city1' AND Destination='city2'
);
END$$
DELIMITER ;

SELECT flight_between('Banglore','New Delhi') AS num_flights;