Use dsmp;

SELECT * FROM ipl_data;

# Show all team and give ranking to every respective batsman (top 5)
SELECT * FROM( SELECT BattingTeam,batter,SUM(batsman_run) AS 'Total_runs', DENSE_RANK() OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC)
 AS 'Rank_within_team' FROM ipl_data GROUP BY BattingTeam,batter)t WHERE t.Rank_within_team<6 ORDER BY t.BattingTeam,t.Rank_within_team;
 
-- CUMMULATIVE SUM --
# find the cummulative sum of runs made by virat kohli on his 50th, 100th and 200th match
SELECT * FROM(SELECT CONCAT("MATCH-",CAST(ROW_NUMBER() OVER(ORDER BY ID)AS char)) AS 'Match_id',SUM(batsman_run) AS 'runs_Scored',
SUM(SUM(batsman_run)) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS 'Cummulative_score'
FROM ipl_data WHERE batter='V Kohli' GROUP BY ID)t WHERE t.Match_id='MATCH-50' OR t.Match_id='MATCH-100' OR t.Match_id='MATCH-200';

-- CUMMULATIVE AVERAGE --
# find the cummulative average of runs made by virat kohli 
SELECT * FROM(SELECT CONCAT("MATCH-",CAST(ROW_NUMBER() OVER(ORDER BY ID)AS char)) AS 'Match_id',SUM(batsman_run) AS 'runs_Scored',
SUM(SUM(batsman_run)) OVER w AS 'Cummulative_Sum', AVG(SUM(batsman_run)) OVER w AS 'Career_Avg'
FROM ipl_data WHERE batter='V Kohli' GROUP BY ID WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))t;

-- RUNNING AVERAGE --
# find the running average of runs made by virat kohli over previous 10 matches 
SELECT * FROM(SELECT CONCAT("MATCH-",CAST(ROW_NUMBER() OVER(ORDER BY ID)AS char)) AS 'Match_id',SUM(batsman_run) AS 'runs_Scored',
SUM(SUM(batsman_run)) OVER w AS 'Cummulative_Sum', AVG(SUM(batsman_run)) OVER w AS 'Career_Avg',
AVG(SUM(batsman_run)) OVER(ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS 'Running_Avg'
FROM ipl_data WHERE batter='V Kohli' GROUP BY ID WINDOW w AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))t;

-- PERCENTAGE OF TOTAL --
USE zomato;
# find the most profitable dish of every restaurants
SELECT t3.f_name, (total_value/SUM(total_value) OVER())*100 AS 'Percentage_Of_Total' FROM (SELECT f_id,SUM(amount) AS 'total_value' FROM orders t1 
JOIN order_details t2 ON t1.order_id=t2.order_id WHERE r_id=1 GROUP BY f_id)t JOIN food t3 ON t.f_id=t3.f_id;

-- PERCENTAGE CHANGE --

# find percentage change of views month by month
SELECT  YEAR(Date), MONTHNAME(Date),SUM(views) AS 'views', 
((SUM(views)-LAG(SUM(views)) OVER(ORDER BY YEAR(Date),MONTH(Date)))/LAG(SUM(views)) OVER(ORDER BY YEAR(Date),MONTH(Date)))*100 AS 'Percentage Change'
FROM youtube_views GROUP BY YEAR(Date), MONTHNAME(Date) ORDER BY  YEAR(Date), MONTH(Date);

# using lag with 7 days gap
SELECT * , ((views- LAG(views,7) OVER(ORDER BY Date))/LAG(views,7) OVER(ORDER BY Date))*100 AS 'Weekly_percentage_change'FROM youtube_views;

-- PERCENTILES AND QUARTILES --

# Find the median  branchwise marks of the students 
SELECT *, PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) AS 'Median_Marks',
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY marks) OVER(PARTITION BY branch) AS 'Median_Marks' FROM marks;

# NOTE : DIFFERENCE BETWEEN PERCENTILE_DISC AND PERCENTILE_CONT 
# THE PERCENTILE_CONT CONSIDERS VALUE OF COLUMN AS CONTINUES VALUE AND IT PRINT THE RESULT IN CONTINUOUS VALUE AS WELL. 
# IT MAY RETURN MEDIAN WHICH MAY NOT PRESENT IN ORIGINAL DATASET
# THE PERCENTILE_DISC CONSIDERS VALUE OF COLUMN AS CONTINUES VALUE AND IT PRINT THE RESULT IN DISCRETE VALUE AS WELL. 
# IT MAY RETURN MEDIAN WHICH IS PRESENT IN ORIGINAL DATASET

# NOTE : PERCENTILE_DISC AND PERCENTILE_CONT THESE FUNCTIONS ARE NOT IN MYSQL(InoDB) (WORKBENCH DEFAULT SERVER).
# IT WILL WORK IF WE USE XAMPP MYSQL SERVER WITH WORKBENCH

SELECT * FROM marks;
# insert a outlier
INSERT INTO marks VALUES(17,'Abhi','EEE',1);
SELECT * FROM marks;

# ways to remove outlier (using inter quartile range way)
SELECT * FROM( SELECT *, PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q1',
PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q3' FROM marks)t 
Where t.marks>t.Q1-(1.5*(t.Q3-tQ1)) AND t.marks<t.Q1+(1.5*(t.Q3-tQ1)) ORDER BY t.student_id;

# find outlier
SELECT * FROM( SELECT *, PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q1',
PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY marks) OVER() AS 'Q3' FROM marks)t 
Where t.marks<=t.Q1-(1.5*(t.Q3-tQ1));

-- SEGMENTATION --
SELECT *,NTILE(3) OVER() AS 'buckets' FROM marks;

# highest marks student will come in bucket 1, medium scorer student in bucket 2 and low scorer student in bucket 3.
SELECT *,NTILE(3) OVER(ORDER BY marks DESC) AS 'buckets' FROM marks;

# reserve the original ordering of the students
SELECT *,NTILE(3) OVER(ORDER BY marks DESC) AS 'buckets' FROM marks ORDER BY student_id;

# divide the smarphones in 3 ranges based on price
SELECT * FROM smartphones;

SELECT brand_name,model,price,
CASE 
    WHEN Bucket=1 THEN 'Budget'
    WHEN Bucket=2 THEN 'Mid Range'
    WHEN Bucket=3 THEN 'Premium'
END AS 'price_range'
FROM(SELECT brand_name,model,price,NTILE(3) OVER(ORDER BY price) AS 'Bucket' FROM smartphones)t;


-- CUMULATIVE DISTRIBUTION --
SELECT *, CUME_DIST() OVER(ORDER BY marks) AS 'Percentile_Score' FROM marks;

SELECT * FROM (SELECT *, CUME_DIST() OVER(ORDER BY marks) AS 'Percentile_Score' FROM marks) t WHERE t.Percentile_Score > 0.90;

-- PARTITION BY MULTIPLE COLUMNS --
SELECT * FROM (SELECT source,destination,airline,AVG(price) AS 'avg_fare',
DENSE_RANK() OVER(PARTITION BY source,destination ORDER BY AVG(price)) AS 'rank' FROM flights
GROUP BY source,destination,airline) t WHERE t.rank < 2
