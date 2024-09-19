SELECT * FROM dsmp.users;
SELECT * FROM dsmp.membership;
SELECT * FROM dsmp.groups;

# cross join
SELECT * FROM dsmp.users t1 CROSS JOIN dsmp.groups t2;

# inner join
SELECT * FROM dsmp.users t1 INNER JOIN dsmp.membership t2 ON t1.user_id=t2.user_id;

# right join
SELECT * FROM dsmp.users t1 LEFT JOIN dsmp.membership t2 ON t1.user_id=t2.user_id;

# left join
SELECT * FROM dsmp.users t1 RIGHT JOIN dsmp.membership t2 ON t1.user_id=t2.user_id;

# full outer join
# In SQL we cannot perfrom full outer join. This needs to be done using set
SELECT * FROM dsmp.users t1 FULL OUTER JOIN dsmp.membership t2 ON t1.user_id=t2.user_id;

# SQL OPERATORS
SELECT * FROM dsmp.person1;
SELECT * FROM dsmp.person2;

# Union
SELECT * FROM dsmp.person1 t1 UNION SELECT * FROM dsmp.person2 t2;

# Union all 
SELECT * FROM dsmp.person1 t1 UNION ALL SELECT * FROM dsmp.person2 t2;

# intersect
SELECT * FROM dsmp.person1 t1 INTERSECT SELECT * FROM dsmp.person2 t2;

# Except
SELECT * FROM dsmp.person1 t1 EXCEPT SELECT * FROM dsmp.person2 t2;
SELECT * FROM dsmp.person2 t1 EXCEPT SELECT * FROM dsmp.person1 t2;

# full outer join using set
# LEFT JOIN + UNION + RIGHT JOIN
SELECT * FROM dsmp.users t1 LEFT JOIN dsmp.membership t2 ON t1.user_id=t2.user_id
UNION
SELECT * FROM dsmp.users t1 RIGHT JOIN dsmp.membership t2 ON t1.user_id=t2.user_id;

# Self join
# find the emergency contact person of every person in the table
SELECT * FROM dsmp.users1;
SELECT * FROM dsmp.users1 t1 JOIN dsmp.users1 t2 ON t1.emergency_contact=t2.user_id;

# join two or more table
SELECT * FROM dsmp.students;
SELECT * FROM dsmp.class;
SELECT * FROM dsmp.students t1 JOIN dsmp.class t2 ON t1.enrollment_year=t2.class_year AND t1.class_id=t2.class_id;


# Flipkart data
SELECT * FROM dsmp.users;
SELECT * FROM dsmp.orders;
SELECT * FROM dsmp.category;
SELECT * FROM dsmp.order_details;

# Find order name and corresponding category name 
 SELECT t1.order_id,t1.amount,t1.profit,t3.name FROM dsmp.order_details t1 
 JOIN dsmp.orders t2 ON t1.order_id=t2.order_id JOIN dsmp.users t3 ON t2.user_id=t3.user_id;
 
 # find order_id,name,city from user and order table
SELECT t2.order_id,t1.name,t1.city FROM dsmp.users t1 JOIN dsmp.orders t2 ON t1.user_id=t2.user_id;

 # find order_id,product category by joining order_details and category
SELECT t1.order_id, t2.category FROM dsmp.order_details t1 JOIN dsmp.category t2 ON t1.category_id=t2.category_id;

# find all the order that were placed in pune
SELECT t2.order_id,t1.name,t1.city FROM dsmp.users t1 JOIN dsmp.orders t2 ON t1.user_id=t2.user_id WHERE t1.city='pune';

# find all orders under chair category 
SELECT t1.order_id, t2.vertical FROM dsmp.order_details t1 JOIN dsmp.category t2 ON t1.category_id=t2.category_id WHERE t2.vertical='Chairs';

# find all profitable orders
SELECT t1.order_id, SUM(t2.profit) AS 'Profit' FROM dsmp.orders t1 
JOIN dsmp.order_details t2 ON t1.order_id=t2.order_id GROUP BY t1.order_id HAVING Profit>0;

# find the customer who has placed ,maximum order
SELECT t2.name, COUNT(*) AS 'Total_Orders' FROM dsmp.orders t1 JOIN dsmp.users t2 ON t1.user_id=t2.user_id 
GROUP BY t2.name ORDER BY Total_Orders DESC LIMIT 1;

# Which is the most profitable category
SELECT t2.vertical, SUM(t1.profit) AS 'Profit' FROM dsmp.order_details t1 JOIN dsmp.category t2 ON t1.category_id=t2.category_id 
GROUP BY t2.vertical ORDER BY PROFIT DESC LIMIT 1;

# Which is the most profitable state
SELECT t1.state, SUM(t3.profit) AS 'Profit' FROM dsmp.users t1 
JOIN dsmp.orders t2 ON t1.user_id=t2.user_id 
JOIN dsmp.order_details t3 ON t2.order_id=t3.order_id
GROUP BY t1.state ORDER BY PROFIT DESC LIMIT 1;

# find all the category with profit higher than 5000
SELECT t2.vertical, SUM(t1.profit) AS 'Profit' FROM dsmp.order_details t1 JOIN dsmp.category t2 ON t1.category_id=t2.category_id 
GROUP BY t2.vertical HAVING Profit>5000;












