# Where 1 means we are fetching all rows without applying any conditions and * means fetching all columns 
SELECT * FROM smartphones WHERE 1;
SELECT model,price,rating FROM smartphones;

# Alias -> renaming columns 
SELECT os AS 'Operating System', model, battery_capacity AS 'Battery_Capacity(mAH)' FROM smartphones;

# PPI = d0/d1 (where d0 is (w^2+h^2)**0.5)
# w is no of pixel along the horizontal lines, h is no of pixel along the vertical lines , d1 is diagonal screen size in inches

# Create expression using columns 
SELECT model, 
sqrt(resolution_width * resolution_width + resolution_height * resolution_height)/screen_size AS PPI FROM dsmp.smartphones;

# Constants : We can create a column that have same value for entire row using constants
SELECT model,'smartphone' AS 'Type' FROM dsmp.smartphones; 

# Distinct (uniques) values from a column
SELECT distinct(brand_name) AS 'All_Brands' from dsmp.smartphones;
SELECT distinct(os) AS 'All_OS' from dsmp.smartphones;

# Distinct combos values from a column
SELECT distinct brand_name,processor_brand from dsmp.smartphones;

# filter rows based on where clause
SELECT * FROM dsmp.smartphones WHERE brand_name='samsung';
SELECT * FROM dsmp.smartphones WHERE price>100000;

# Between operator (2 ways for same result)
SELECT * FROM dsmp.smartphones WHERE price>10000 and price<20000;
SELECT * FROM dsmp.smartphones WHERE price BETWEEN 10000 and 20000;

SELECT * FROM dsmp.smartphones WHERE rating>80 AND price<15000;
SELECT * FROM dsmp.smartphones WHERE rating>80 AND price<15000 AND processor_brand='snapdragon';

SELECT distinct(brand_name) FROM dsmp.smartphones WHERE price>50000;

# In/Not In (2 ways to get same result)
SELECT * FROM dsmp.smartphones WHERE processor_brand='snapdragon' OR processor_brand='exynos' OR processor_brand='bionic';
SELECT * FROM dsmp.smartphones WHERE processor_brand IN('snapdragon','exynos','bionic');
SELECT * FROM dsmp.smartphones WHERE processor_brand NOT IN('snapdragon','exynos','bionic');

# Mediatek is same brand as dimensionality so make changes in database accordingly
UPDATE dsmp.smartphones SET processor_brand='dimensity' WHERE processor_brand='mediatek';
SELECT * FROM dsmp.smartphones WHERE processor_brand='mediatek';

# remove all phone whose price> 200000
SELECT * FROM dsmp.smartphones WHERE price>200000;
DELETE FROM dsmp.smartphones WHERE price>200000; # outliers
SELECT * FROM dsmp.smartphones WHERE price>200000;

# remove all samsung phone whose primary(rear)_camera>150 px
SELECT * FROM dsmp.smartphones WHERE primary_camera_rear>150 AND brand_name='samsung';
DELETE FROM dsmp.smartphones WHERE primary_camera_rear>150 AND brand_name='samsung'; # outliers
SELECT * FROM dsmp.smartphones WHERE primary_camera_rear>150 AND brand_name='samsung';

# SQL Function
# 1) BuildIn function
#       a) scalar : It gives individual value for each row. Ex: round function
#       b) aggregate : It gives single value for one column. Ex: average function
# 2) User defined function 


# Max/min
SELECT MAX(price) FROM dsmp.smartphones WHERE brand_name='samsung';
SELECT MIN(price) FROM dsmp.smartphones;

# avg 
# avg of rating of apple phones
SELECT AVG(rating) FROM dsmp.smartphones WHERE brand_name='apple';
SELECT AVG(price) FROM dsmp.smartphones WHERE brand_name='apple';

# sum 
SELECT SUM(price) FROM dsmp.smartphones;

# count
SELECT COUNT(*) FROM dsmp.smartphones WHERE brand_name='oneplus';

# count(distinct)
SELECT count(distinct(brand_name)) AS 'All_Brands' from dsmp.smartphones;

# std
SELECT STD(screen_size) AS 'All_Brands' from dsmp.smartphones;

# variance
SELECT VARIANCE(screen_size) AS 'All_Brands' from dsmp.smartphones;

# abs
SELECT ABS(price-100000) AS 'Absolute' from dsmp.smartphones;

# round
SELECT model, ROUND(SQRT(resolution_width * resolution_width + resolution_height * resolution_height)/screen_size,2) AS PPI FROM dsmp.smartphones;

# ceil/floor
SELECT CEIL(screen_size) AS 'CEIL' from dsmp.smartphones;
SELECT FLOOR(screen_size) AS 'FLOOR' from dsmp.smartphones;