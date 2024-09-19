CREATE DATABASE zomato;

-- SCHEMA STRUCTURE --
# users -> orders (user_id)
# users -> delivery_partners (partner_id)
# restaurants -> orders (r_id)
# order_details -> orders (order_id)
# food -> menu (f_id)
# menu -> restaurants (r_id)
# ordder_details -> food (f_id)

# Select a database
USE zomato; # Now we don't need to write database name before every table name
SELECT * FROM users;

# count rows of a tablr
# return n random records 
SELECT * FROM users ORDER BY RAND() LIMIT 5;

# find null values 
SELECT * FROM orders WHERE restaurant_rating='';

# Fill null values by 0
UPDATE orders SET restaurant_rating=0 WHERE restaurant_rating='';

# find number of orders placed by each customers
SELECT t1.user_id, t1.name, COUNT(t2.order_id) AS 'total_orders' FROM users t1 JOIN orders t2 ON t1.user_id=t2.user_id 
GROUP BY t1.user_id ORDER BY total_orders DESC; 

# find restaurant with most no.of menus items
SELECT t1.r_name, COUNT(t2.menu_id) AS 'No. of menu items' FROM restaurants t1 JOIN menu t2 ON t1.r_id=t2.r_id 
GROUP BY t1.r_id ORDER BY t1.r_name DESC; 

# Find no of votes and average ratings for each restaurants
SELECT t1.r_name,COUNT(*) AS 'num_votes',ROUND(AVG(restaurant_rating),2) AS 'ratings' FROM restaurants t1 JOIN orders t2 ON t1.r_id=t2.r_id 
WHERE NOT restaurant_rating ='' GROUP BY t1.r_id;

# find the food that is sold at most number of restaurants
SELECT t1.f_name,COUNT(*) AS 'Total_Sale' FROM food t1 JOIN menu t2 ON t1.f_id=t2.f_id 
GROUP BY t1.f_id ORDER BY COUNT(*) DESC LIMIT 1;

# find restaurant with most revenue in a given month
SELECT t2.r_name, MONTHNAME(DATE(date)),SUM(t1.amount) AS 'Revenue' FROM orders t1 JOIN restaurants t2 ON t1.r_id=t2.r_id 
WHERE MONTHNAME(DATE(date))='May' GROUP BY t2.r_id ORDER BY Revenue DESC LIMIT 1; 
 
# month wise revenue of kfc restaurant
SELECT MONTHNAME(DATE(date)) AS 'month',SUM(t1.amount) AS 'Revenue' FROM orders t1 JOIN restaurants t2 ON t1.r_id=t2.r_id 
WHERE r_name='kfc' GROUP BY month ORDER BY month; 
 
# find restaurants with sales greater than x
# Let x=1500
SELECT t2.r_name,SUM(t1.amount) AS 'Revenue' FROM orders t1 JOIN restaurants t2 ON t1.r_id=t2.r_id 
GROUP BY t1.r_id HAVING Revenue>1500 ORDER BY Revenue DESC; 

# find customer who have never ordered
SELECT user_id,name FROM users EXCEPT SELECT t1.user_id,name FROM orders t1 JOIN users t2 ON t1.user_id=t2.user_id;

# Show order details of a particular customer on a given date range 
SELECT user_id,t2.order_id, date, t3.f_name FROM orders t1 JOIN order_details t2 ON t1.order_id=t2.order_id JOIN food t3 ON t2.f_id=t3.f_id
WHERE user_id='1' AND date BETWEEN '2022-05-15' AND '2022-06-15' ORDER BY date DESC;

# customers favorite food
select t1.user_id,t3.f_id,COUNT(DISTINCT ()) AS 'Frequency_of_order' from users t1 JOIN orders t2 ON t1.user_id=t2.user_id 
JOIN order_details t3 On t2.order_id=t3.order_id GROUP BY t1.user_id,t3.f_id;  

# find most costly restaurant (avg price/dish)
SELECT t1.r_id, t2.r_name, SUM(price)/COUNT(*) AS 'AVG_Price' FROM menu t1 JOIN restaurants t2 On t1.r_id=t2.r_id 
GROUP BY r_id ORDER BY AVG_Price DESC LIMIT 1;

# find delivery partner compensation using the formula (deliveries*100 + 1000*avg_rating)
SELECT t2.partner_id,t2.partner_name ,(Count(*) *100 + AVG(t1.delivery_rating)*1000) AS 'Compensation' FROM orders t1 
JOIN delivery_partner t2 ON t1.partner_id=t2.partner_id GROUP BY t2.partner_id ORDER BY Compensation DESC;

# find correlation between  delivery time and total rating
SELECT CORR(delivery_time,delivery_rating+restaurant_rating) FROM orders;

# find all the veg restaurant
SELECT t3.r_name,t2.f_name,t2.type FROM menu t1 JOIN food t2 ON t1.f_id=t2.f_id JOIN restaurants t3 ON t1.r_id=t3.r_id GROUP BY t1.r_id 
-- HAVING type='Veg';
HAVING MIN(type)='Veg' AND MAX(type)='Veg';

# find min and max value of every customer
SELECT t1.user_id,name,MIN(amount),MAX(amount),AVG(amount) FROM users t1 JOIN orders t2 ON t1.user_id=t2.user_id GROUP BY user_id;