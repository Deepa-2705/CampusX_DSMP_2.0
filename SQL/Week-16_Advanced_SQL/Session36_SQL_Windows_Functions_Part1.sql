USE dsmp;

CREATE TABLE dsmp.marks (
 student_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);

INSERT INTO marks (name,branch,marks)VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);


# WINDOW FUNCTIONS
SELECT * FROM marks;
SELECT AVG(marks) FROM marks;

# Difference between group by and window functions
SELECT *, AVG(marks) FROM marks GROUP BY branch; # It aggregated marks of students branchwise and it will show it in only one column

# divide the whole data into groups 
SELECT *, AVG(marks) OVER() FROM marks; # window function contains the rows equal to the rows of the original table

# divide the whole data into groups based on branch column
SELECT *, AVG(marks) OVER(PARTITION BY branch ) FROM marks; 

# select minimum nad maximum of marks using windows function
SELECT *,MIN(marks) OVER(), MAX(marks) OVER() FROM marks;

SELECT *,MIN(marks) OVER(), MAX(marks) OVER(),MIN(marks) OVER(PARTITION BY branch),MAX(marks) OVER(PARTITION BY branch) FROM marks ORDER BY student_id;


# Aggregate function with over()
# Find all the students who have marks higher than the average marks of their respective branch
SELECT * FROM ( SELECT *, AVG(marks) OVER(PARTITION BY branch) AS 'branch_avg' FROM marks)t WHERE t.marks>t.branch_avg;

# NOTE : THE SAME QUERY WAS SOLVED USING SUBQUERY. BUT WE SHOULD AVOID USING CORRELATED QUERY. THIS WINDOW FUNCTION WAY IS MUCH MORE OPTIMIZE.

# RANK, DENSE_RANK, ROW_NUMBER
# Rank every student branch wise according to their marks
SELECT *, RANK() OVER(ORDER BY marks DESC) AS 'Overall_ranking' FROM marks; # overall_ranking
SELECT *, RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Branchwise_ranking' FROM marks; # branchwise_ranking

# NOTE : IF TWO ROW HAVE SAME VALUE THEN RANK FUNCTION WILL ASSIGN SAME RANK VALUE TO BOTH. FOR EX: 2 STUDENT HAVE SAME HIGHEST MARKS THEN 
# RANK 1 WILL BE ASSIGN TO BOTH AND NEXT STUDENT WILL GET 3 RANK (RANK 2 WILL BE SKIPED)

# DIFFERENCE BETWEEN RANK AND DENSE_RANK
# AS DISCUSSED ABOVE, RANK ASSIGN 1,1 TO TOP STUDENT HAVING SAME MARKS THEN 3 RANK TO SECOND HIGHEST MARKS
# DENSE_RANK ASSIGN 1,1 TO TOP STUDENT HAVING SAME MARKS THEN 2 RANK TO SECOND HIGHEST MARKS
SELECT *, RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'RANK',
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'DENSE_RANK'  FROM marks; # branchwise_ranking

# ROW_NUMBER : It assigns row_number to our dataset
SELECT *,ROW_NUMBER() OVER() FROM marks;
SELECT *,ROW_NUMBER() OVER(PARTITION BY branch) FROM marks;

# create a unique roll no
SELECT *, CONCAT(branch,'-',ROW_NUMBER() OVER(PARTITION BY branch)) FROM marks;

USE zomato;
# Find top 2 most paying customers of each month
SELECT * FROM(SELECT MONTHNAME(date), user_id, SUM(amount), RANK() OVER(PARTITION BY MONTHNAME(date) ORDER BY SUM(AMOUNT)DESC) AS 'Total_Expense' 
FROM orders GROUP BY MONTHNAME(date), user_id ORDER BY MONTHNAME(date))t WHERE Total_Expense<3;

# FIRST_VALUE, LAST_VALUE, NTH_VALUE

USE dsmp;
SELECT *, FIRST_VALUE(name) OVER(ORDER BY marks DESC) 'University Topper' FROM marks;

SELECT *, LAST_VALUE(marks) OVER(ORDER BY marks DESC) 'University Failure' FROM marks;

# EXPECTED RESULT : WE SHOULD GET THE MIN. MARKS IN EVERY ROW OF LAST COLUMN
# EXPECTED RESULT IS NOT SAME WHY? THE REASON IS FRAME. (DEFAULT FRAMES IS SET AS ROW BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
# OTHER OPTIONS : ~ ROWS BETWEEN ONE PRECEDING AND ONE FOLLOWING
#                 ~ ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
#                 ~ ROWS BETWEEN 3 PRECEDING AND 2 

SELECT *, LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
AS 'Branchwise Lowest Marks' FROM marks;
# this will not work without ordering

# 2nd topper of every branch
SELECT *, NTH_VALUE(name,2) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
AS 'Branchwise Lowest Marks' FROM marks;

# find the branch topper
SELECT name,marks,branch FROM (SELECT *, FIRST_VALUE(NAME) OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Topper_name', 
FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Topper_marks' FROM marks)t
WHERE t.name=t.Topper_name and t.marks=t.Topper_marks;

# find the branchwise weakest student
SELECT name,marks,branch FROM 
(SELECT *, LAST_VALUE(NAME) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'Topper_name', 
LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'Topper_marks' 
FROM marks)t WHERE t.name=t.Topper_name and t.marks=t.Topper_marks;

# WE CAN SEE THE REPEATED CODE ABOVE. WE CAN REDUCE IT BY FOLLOWING WAY.
SELECT name,marks,branch FROM 
(SELECT *, LAST_VALUE(NAME) OVER w AS 'Topper_name', 
LAST_VALUE(marks) OVER w AS 'Topper_marks' 
FROM marks)t WHERE t.name=t.Topper_name and t.marks=t.Topper_marks
WINDOW w AS (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);


# LEAD / LAG
SELECT * FROM marks;
SELECT *, LAG(marks) OVER(ORDER BY student_id DESC) FROM marks;
SELECT *, LEAD(marks) OVER(ORDER BY student_id DESC) FROM marks;

SELECT *, LAG(marks) OVER(PARTITION BY branch ORDER BY student_id DESC) FROM marks;
SELECT *, LEAD(marks) OVER(PARTITION BY branch ORDER BY student_id DESC) FROM marks;

# find MOM revenue growth of zomato
USE zomato;

SELECT MONTHNAME(date),SUM(amount), 
(SUM(amount)-LEAD(SUM(amount)) OVER(ORDER BY MONTHNAME(date)))/LEAD(SUM(amount)) OVER(ORDER BY MONTHNAME(date))*100
AS 'MOM'FROM orders GROUP BY MONTHNAME(date) ORDER BY MONTH(date);