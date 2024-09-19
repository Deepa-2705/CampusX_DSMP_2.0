USE zomato;

SELECT * FROM zomato.movies;

# find the highest rated movies
SELECT MAX(score) FROM movies;# this query is not dynamic 
SELECT * FROM movies WHERE score=9.3;

# subquery way
SELECT * FROM movies WHERE score=(SELECT MAX(score) FROM movies);

# independent subquery is those which can run independently and will show the result
# correlated subquery is those which cannot run independently and will show error while running independently.

-- INDEPENDENT SUBQUERY - SCALAR SUBQUERY
# find the movie with highest profit (vs order by)
# using sub query
SELECT * FROM movies WHERE (gross - budget)=(SELECT MAX((gross - budget)) FROM movies);

# Using order by
SELECT * FROM movies ORDER BY (gross-budget) DESC LIMIT 1;

# Second query is faster in bigger data because of indexing concept which makes searching and sorting faster
# If we remove indexing in order by case then it will longer time than first query 
# Time complexity(subquery) = O(N)+O(N) = O(2N) ~ O(N)
# Time complexity(order by) = O(N LOG N)

# How many movies have a rating greater than average of all movies (find the count of above average rating movies)
SELECT COUNT(*) FROM movies WHERE score>(SELECT AVG(score) FROM movies);

# find the highest rated movie of year 2000
SELECT * FROM movies WHERE year=2000 AND score=(SELECT MAX(score) FROM movies WHERE year=2000);

# find the highest rated movies among all the movies whose number of votes are> the dataset average votes
SELECT * FROM movies WHERE score=(SELECT MAX(score) FROM movies WHERE votes>(SELECT AVG(votes) FROM movies));

-- INDEPENDENT SUBQUERY - ROW SUBQUERY(1 COLUMN MULTIPLE ROWS)
# Find all users who never ordered
SELECT name FROM users WHERE user_id NOT IN (SELECT DISTINCT user_id FROM orders);

# find all movies made by top 3 directors in terms of total gross income
SELECT * FROM movies WHERE director IN (SELECT director FROM movies GROUP BY director ORDER BY SUM(gross) DESC); 

# the above query is not giving correct result 
# write correct query using common table expression (CT
with top_directors AS(SELECT director FROM movies GROUP BY director ORDER BY SUM(gross) DESC LIMIT 3)
SELECT * FROM movies WHERE director IN (SELECT * FROM top_directors);

# find all movies of those actors whose filmography avg rating>8.5 (take 25000 votes as cutoff)
SELECT * FROM movies WHERE star IN (SELECT star  FROM movies WHERE votes>25000 GROUP BY star HAVING AVG(score)>8.5);

-- NOTE : WHEN WE SEARCH SCALAR VALUE IN TABLE WE USE = BUT WHEN WE EXTRACT MULTIPLE ROW VALUE FROM A ROW OR TABLE WE USE IN OPERATOR. 

-- INDEPENDENT SUBQUERY - TABLE SUBQUERY (MULTIPLE COLUMNS AND MULTIPLE ROWS)
# find most profitable movie of each year 
SELECT * FROM movies WHERE (year,gross) IN (SELECT year,MAX(gross) FROM movies GROUP BY year);

# find highest rated movie of its genre votes cutoff of 25000
SELECT * FROM movies WHERE (genre,score) IN (SELECT genre,MAX(score) FROM movies WHERE votes>25000 GROUP BY genre) AND votes>25000;

# find the highest grossing movies of top 5 actors/director combo in terms of total gross income
# As again we have limit in our query so we cannot use subquery we will use ct 

with top_duos AS (SELECT star,director,MAX(gross) FROM movies GROUP BY star,director ORDER BY SUM(gross) DESC LIMIT 5)
SELECT * FROM movies WHERE (star,director,gross) IN (SELECT * FROM top_duos);                                                                        
																	
-- CORRELATED SUBQUERY
# Find all the movies that have a rating higher than the average rating of the movie having in same genre[Animation]	
# inner query is depending upon outer query (we will check avg of its genre for every movie than print the highest rating movie in its entire genre)
SELECT * FROM movies m1 WHERE score> (SELECT AVG(score) FROM movies m2 WHERE m1.genre=m2.genre); # cannot run independently

# find the favourite food of every customer
WITH fav_food AS(SELECT t1.user_id,t4.name,t3.f_name,COUNT(*) AS 'Num_Order' FROM orders t1 
				JOIN order_details t2 ON t1.order_id=t2.order_id 
				JOIN food t3 ON t2.f_id=t3.f_id
				JOIN users t4 ON t1.user_id=t4.user_id
				GROUP BY t4.user_id,t3.f_id)

SELECT * FROM fav_food f1 WHERE Num_Order=(SELECT MAX(Num_Order) FROM fav_food f2 WHERE f1.user_id=f2.user_id);
                                                                        
-- USAGE OF QUERIES WITH SELECT 	
# Get the percentage of the votes fo reach movies compared to the total numner of votes.
SELECT name,votes FROM movies GROUP BY name;		

# same result with subquery
SELECT name, (votes/(SELECT SUM(votes) FROM movies))*100 FROM movies;														

# display all movie names, genre,score, avg(score) of genre
SELECT name, genre,score,(SELECT ROUND(AVG(score),2) FROM movies m2 WHERE m1.genre=m2.genre) AS 'Avg_genre_score' FROM movies m1;

-- USAGE WITH FROM
# display the average ratings of all the restaurants
SELECT r_name,Avg_Rating FROM (SELECT r_id,ROUND(AVG(restaurant_rating),2) AS 'Avg_Rating' FROM orders GROUP BY r_id) t1 
JOIN restaurants t2 ON t1.r_id=t2.r_id;

-- USAGE WITH HAVING
# find genre having avg score > avg score of all the movies
SELECT genre,ROUND(AVG(score),2) FROM movies GROUP BY genre HAVING AVG(score)>(SELECT AVG(score) FROM movies);

-- NOTE : WE HAVE TO BE MORE CAREFUL WHILE USING SUBQUERY INSIDE A SELECT STATEMENT. AS IT WILL TAKE A LOT OF TIME AND BECOMES VERY INEFFICIENT.
-- AS WE ARE PROCESSING EVERY ROW WITH A SUBQUERY. (SO AVOID DOING SUBQUERY INSIDE SELECT STATEMENT).

-- SUBQUERY IN INSERT

# Populate an already created loyal_customers table with records of only those customers who have ordered food more than 3 times
CREATE TABLE loyal_users (
       user_id INT,
       name VARCHAR(255),
       money INT
);

# insert into 2 columns only and dont use values keyword here. So that we can add the records that we have extracted into the table
INSERT INTO loyal_users (user_id,name)SELECT t1.user_id,t2.name FROM orders t1 JOIN users t2 ON t1.user_id=t2.user_id 
GROUP BY user_id HAVING COUNT(*)>3;

SELECT * FROM loyal_users;

-- SUBQUERY IN UPDATE
# populate the money column of loyal_customers table using order table. Provide a 10% app money to all customers based on their order value.
UPDATE loyal_users SET money=(SELECT SUM(amount)*0.1 FROM orders WHERE orders.user_id=loyal_users.user_id);
SELECT * FROM loyal_users;

-- SUBQUERY IN DELETE
# Delete all the coustomers details who have never ordered
DELETE FROM users WHERE user_id IN (SELECT user_id FROM (SELECT user_id FROM users WHERE user_id NOT IN (SELECT DISTINCT(user_id) FROM orders))AS u);
SELECT * FROM users;
