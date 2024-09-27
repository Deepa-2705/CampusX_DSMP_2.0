USE dsmp;
# 1. Find the month with most number of flights
SELECT * FROM flights;
SELECT MONTHNAME(Date_of_Journey),COUNT(*) FROM flights GROUP BY MONTHNAME(Date_of_Journey) ORDER BY COUNT(*) DESC LIMIT 1;

# 2. Which week day has most costly flights
SELECT DAYNAME(Date_of_Journey),SUM(Price) FROM flights GROUP BY DAYNAME(Date_of_Journey) ORDER BY SUM(Price) DESC LIMIT 1;

# 3. Find number of indigo flights every month
SELECT MONTHNAME(Date_of_Journey),COUNT(*) FROM flights WHERE Airline='IndiGo' GROUP BY MONTHNAME(Date_of_Journey);

# 4. Find list of all flights that depart between 10AM and 2PM from Banglore to Delhi
SELECT * FROM flights WHERE Source='Banglore' And Destination='Delhi' AND Dep_Time BETWEEN '10:00:00' AND '12:00:00';

# 5. Find the number of flights departing on weekends from Bangalore
SELECT COUNT(*) FROM flights WHERE Source='Banglore' AND DAYNAME(Date_of_Journey) IN ('saturday','sunday');

# 6. Calculate the arrival time for all flights by adding the duration to the departure time.
ALTER TABLE flights ADD COLUMN departure DATETIME;

UPDATE flights
SET departure = STR_TO_DATE(CONCAT(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i');

ALTER TABLE flights
ADD COLUMN duration_mins INTEGER,
ADD COLUMN arrival DATETIME;

SELECT Duration,
REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 + 
CASE
	WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
END AS 'mins'
FROM flights; 


UPDATE flights SET duration_mins = 
CASE 
   WHEN Duration LIKE '%h %m' THEN
		SUBSTRING_INDEX(Duration, 'h', 1)*60 + 
        REPLACE(SUBSTRING_INDEX(Duration,'',-1),'m',1)
   WHEN Duration LIKE '%h' THEN
		SUBSTRING_INDEX(Duration, 'h', 1)*60
   WHEN Duration LIKE '%m' THEN
        SUBSTRING_INDEX(Duration, 'm',1)
END;
                   

SELECT * FROM flights;

UPDATE flights
SET arrival = DATE_ADD(departure,INTERVAL duration_mins MINUTE);

SELECT * FROM flights;
SELECT TIME(arrival) FROM flights;

# 7. Calculate the arrival date for all the flights
SELECT Date(arrival) FROM flights;

# 8. Find the number of flights which travel on multiple dates.
SELECT COUNT(*) FROM flights WHERE DATE(departure) != DATE(arrival);

# 9. Calculate the average duration of flights between all city pairs. The answer should In xh ym format.
SELECT source,destination,TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM flights
GROUP BY source,destination;

# 10. Find all flights which departed before midnight but arrived at their destination after midnight having only 1 stop.
SELECT * FROM flights WHERE total_stops = 'non-stop' AND DATE(departure) < DATE(arrival);

# 11. Find quarter wise number of flights for each airline
SELECT airline, QUARTER(departure), COUNT(*) FROM flights GROUP BY airline, QUARTER(departure);

# 12. Find the longest flight distance(between cities in terms of time) in India



# 13. Average time duration for flights that have 1 stop vs more than 1 stops 14. Find all Air India flights in a given date range originating 
# from Delhi
WITH temp_table AS (SELECT *,
CASE 
	WHEN total_stops = 'non-stop' THEN 'non-stop'
    ELSE 'with stop'
END AS 'temp' FROM flights)

SELECT temp,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration',
AVG(Price) AS 'avg_price' FROM temp_table GROUP BY temp;

-- 	14. Find all Air India flights in a given date range originating from Delhi
SELECT * FROM flights WHERE source = 'Delhi' AND DATE(Departure) BETWEEN '2019-03-01' AND '2019-03-10';

# 15. Find the longest flight of each airline
SELECT Airline, TIME_FORMAT(SEC_TO_TIME(MAX(duration_mins)*60),'%kh %im') AS 'max_duration'
FROM flights GROUP BY airline ORDER BY MAX(duration_mins) DESC;

# 16. Find all the pair of cities having average time duration > 3 hours
SELECT source,destination, TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM flights
GROUP BY source,destination HAVING AVG(duration_mins) > 180;

# 17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi
SELECT DAYNAME(departure),
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM - 6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM - 12PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM - 6PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM - 12PM'
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure)
ORDER BY DAYOFWEEK(departure) ASC;

# 18 Make a weekday vs time grid showing avg light price from Banglate and Delhi
SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM - 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12PM'
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure)
ORDER BY DAYOFWEEK(departure) ASC;