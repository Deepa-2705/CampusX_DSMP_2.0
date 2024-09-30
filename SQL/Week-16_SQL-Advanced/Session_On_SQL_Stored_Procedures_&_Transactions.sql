USE dsmp;

-- STORED PROCEDURE --
# 1) create hello world stored procedure

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `hello_world`()
-- BEGIN
--      SELECT "Hello_World";
-- END;

CALL hello_world();

# 2) we have to create a stored procedure to create a new user (user will add only if his email is unique. Display success and error message)

USE zomato;

CALL add_user('Ankit','ankit@gmail.com'); # this emal_id already exists in database so it will not add it in table
SELECT * FROM users;

CALL add_user('Ankit','ankit1234@gmail.com'); # insertion will happen here
SELECT * FROM users;

# stored procedure needs 3 input parameters

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user`(IN input_name VARCHAR(255),IN input_email Varchar(255),OUT message VARCHAR(255))
-- BEGIN
--      -- check if input_email exists in users table
--      DECLARE user_count INTEGER;
--      # if no emails repeats than user_count will have 0
--      SELECT COUNT(*) INTO user_count FROM users WHERE email=input_email;
--      
--      IF user_count=0 THEN
-- 		INSERT INTO users (name,email) VALUES(input_name,input_email);
--         SET message='User Inserted Sucessfully.';
-- 	 ELSE 
--         SET message='Email Already Exists.';
-- 	 END IF;
-- END


SET @message='';  # variable
CALL add_user('Ankit','ankit1234@gmail.com',@message); 
SELECT @message; # display message to see the message 

CALL add_user('Deepa','deepa1234@gmail.com',@message); 
SELECT @message; # display message to see the message 
SELECT * FROM users;


# 3) Create a stored procedure to show order placed by a single user
-- CREATE DEFINER=`root`@`localhost` PROCEDURE `user_orders`(IN input_email VARCHAR(255))
-- BEGIN
--      DECLARE id INTEGER;
--      SELECT user_id INTO id FROM users WHERE email=input_email;
--      
--      SELECT * FROM orders WHERE user_id=id;
-- END
CALL user_orders('vartika@gmail.com'); 

# NOTE : HERE STORE_PROCEDURE IS GIVING A TABLE IN RETURN. THIS THING IS NOT POSSIBLE WITH FUNCTION (IT CAN ONLY RETURN A SINGLE RESULT).

# create a stored procedure to place an order (means we have to create an entry in both orders and order_detail column and show the amount of bill)
# let we are adding only 2 items while placing an order

-- CREATE PROCEDURE place_order (IN input_user_id INTEGER,IN input_r_id INTEGER,IN input_f_ids VARCHAR(255), OUT total_amount INTEGER)
-- BEGIN
--      -- insert into orders table 
--      DECLARE new_order_id INTEGER;
--      DECLARE f_id1 INTEGER;
--      DECLARE f_id2 INTEGER;
--      SET f_id1=SUBSTRING_INDEX(input_f_ids,',',1);
--      SET f_id2=SUBSTRING_INDEX(input_f_ids,',',-1);
--      SELECT MAX(order_id) + 1 INTO new_order_id FROM orders; 
--      SELECT SUM(price) INTO total_amount FROM menu WHERE r_id=input_r_id AND f_id IN(f_id1,f_id2);
--      INSERT INTO orders (order_id,user_id,r_id,amount,date) VALUES (new_order_id,input_user_id,input_r_id,total_amount,DATE(NOW()));
--      
--      -- insert into order_details table
--      INSERT INTO order_details (order_id,f_id) VALUES (new_order_id,f_id1),(new_order1,f_id2);
-- END

SET @order=0;

CALL place_order(2,1,'3,4',@total); # 4 food_id is not in menu thatswhy it is not added in tha bill
SELECT @total;

SELECT * FROM orders;
SELECT * FROM menu;
SELECT * FROM order_details;







-- TRANSACTIONS --

-- AUTO INCREMENT --
# 1) Each Sql write statement is autocommmit 
USE dsmp;
SELECT * FROM users;

UPDATE users SET city='Delhi' WHERE user_id=1; # we are updating our table in session 1

SELECT * FROM users;

# now we again connect to sql server (session 2) using above icon button (reconnect to DBMS)
SELECT * FROM users; 

-- NOTE : If we can see our changes in table across different session then it is a permanent change otherwise not.
-- So it proves that autocommit is byfault on whenever we execute any update statement

# 2) if we explicitely off autocommit 

USE dsmp;
SET AUTOCOMMIT =0; 

INSERT INTO users (name) VALUES ('rishab');
SELECT * FROM users;

# NOW IF WE AGAIN CONNECT TO SQL SERVER THEN WE CANNOT SEE THIS CHANGES
SELECT * FROM users;

# WE HAVE TO WRITE COMMIT EXPLICITELY TO SAVE THE CHANGES
INSERT INTO users VALUES (464,'rishab','Delhi','New Delhi');
COMMIT;
SELECT * FROM users;

# IF WE AGAIN RECONNECT TO SERVER THEN WE CAN SEE THE CHANGES
SELECT * FROM users;

CREATE TABLE person (
      id INTEGER PRIMARY KEY AUTO_INCREMENT,
      name VARCHAR(255) NOT NULL,
      dob DATE,
      gender VARCHAR(10),
      married VARCHAR(10),
      balance INTEGER
);

INSERT INTO person VALUES (1,'nitish','1990-10-24','M','Y',50000),
                          (2,'ankita','1993-02-11','F','Y',35000),
                          (3,'rahul','1995-06-19','M','N',10000),
                          (4,'amrita','2000-10-10','F','N',5000),
                          (5,'amit','2003-11-11','M','N',40000);

SELECT * FROM person;

-- TRANSACTIONS --

# we have to transfer 10000 rupees from nitish account to amrita account
START TRANSACTION;

UPDATE person SET balance=40000 WHERE id=1;
UPDATE person SET balance=15000 WHERE id=4;
SELECT * FROM person;

# AS NOW WE HAVENOT WRITE COMMIT OR ROLLBACK. IF WE RECONNECT TO SQL SERVER THEN THIS TRANSACTION WILL ROLLBACK TO ITS INITIAL STATE
SELECT * FROM person;

START TRANSACTION;

UPDATE person SET balance=40000 WHERE id=1;
UPDATE person SET balance=15000 WHERE id=4;
COMMIT;
SELECT * FROM person;

# changes updated
SELECT * FROM person;

# 4) All of none of transaction
# transfer 10000 from nitish to amrita 

START TRANSACTION;
UPDATE person SET balance=30000 WHERE id=1;
UPDATE person SET balance=25000 WHERE id2=4; # we are writing wrong column name intentionally to show rollback
COMMIT;
SELECT * FROM person; # amount is deducted from nitish but not received to amrita because of some error in query

--  BEST PART OF TRANSACTIONS
-- BOTH QUERY ARE A PART OF TRANSACTION. IF FIRST QUERY GETS EXECUTED SUCCESSFULLY AND SECOND QUERY FAILS. SO UPDATED WILL NOT HAPPEN IN DATABASE. 4

SELECT * FROM person; # reconnect to server and see

# 5) rollback
# transfer 10000 from nitish to amrita 
START TRANSACTION;
UPDATE person SET balance=30000 WHERE id=1;
UPDATE person SET balance=25000 WHERE id=4; 
ROLLBACK; # we can apply a check if before and after transaction amount is not same then rollback to inital state

SELECT * FROM person; # even after sucessful commit of the transaction there is rollback statement instead of commit. So no updation in database.

# 6) rollback with checkpoint
# transfer 10000 from nitish to amrita 
START TRANSACTION;
SAVEPOINT A;
UPDATE person SET balance=30000 WHERE id=1;
SAVEPOINT B;
UPDATE person SET balance=25000 WHERE id=4; 
ROLLBACK TO B;  

SELECT * FROM person; # amount is deducted from nitish but didnt recieved to amrita

# 7) rollback to commit
# transfer 10000 from nitish to amrita 
START TRANSACTION;
UPDATE person SET balance=20000 WHERE id=1;
COMMIT; # added to memory
SET AUTOCOMMIT=0; # after commit it gets set back to autocommit thatswhy we have to again off autoincrement
UPDATE person SET balance=25000 WHERE id=4; 
ROLLBACK; 

-- IF WE DONT HAVE COMMIT IN BETWEEN THE TRANSACTIOB QUERY THEN ROLLBACK RETURNED TO THE STARTING POINT OF TRANSACTION.
-- BUT IF WE HAVE COMMIT IN BETWEEN THE TRANSACTION QUERY THEN ROLLBACK WILL START FROM WHERE LAST COMMIT STATEMENT ENDS

SELECT * FROM person; # we can see amount is deducted from nitish but not received to amrita because of rollback
# till now every updates is permanent to the database