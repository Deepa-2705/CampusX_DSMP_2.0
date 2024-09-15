-- QUERY EXECUTION ORDER --
--  F J W G H S D O (from->join->where->groupby->having->select->default->orderby)


# Find top 5 samsung phone with biggest screen size
SELECT model,screen_size FROM dsmp.smartphones WHERE brand_name='samsung' ORDER BY screen_Size DESC LIMIT 5;

# Sort all the phones in descending order of number of total cameras
SELECT model, num_front_cameras+num_rear_cameras AS 'Total_Cameras' FROM dsmp.smartphones ORDER BY Total_Cameras DESC;

# Sort data based on ppi in decresing order
SELECT model, ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size,2) AS 'PPI' FROM dsmp.smartphones
ORDER BY PPI DESC;

# Find the phone having second largest battery capacity  (LIMIT 10,2 start from row 10 and fetch 2 row)
SELECT model, battery_capacity FROM dsmp.smartphones ORDER BY battery_capacity DESC LIMIT 2;
SELECT model, battery_capacity FROM dsmp.smartphones ORDER BY battery_capacity DESC LIMIT 1,1; # start from index 1 and get 1 row

# Find name and rating of worst rated apple phone
SELECT brand_name,rating FROM dsmp.smartphones WHERE brand_name='apple' ORDER BY rating ASC LIMIT 1;

# Sorting on a combination of columns 
# Sort the dataset alphabetically on brandname with their affordable phone on top 
SELECT * FROM dsmp.smartphones  ORDER BY brand_name ASC , price ASC;

# Sort the dataset alphabetically on brandname with their best rating phone on top 
SELECT * FROM dsmp.smartphones  ORDER BY brand_name ASC , rating DESC;

# Group smartphone by brandand get the count, average price, max rating, avg. screen size, and avg. battery capacity
SELECT brand_name, count(*) AS 'Nums_Phone', AVG(price) AS 'Avg_Price', MAX(rating) AS 'Max_Rating', ROUND(AVG(screen_size),2) AS 'Avg_Screen_Size',
ROUND(AVG(battery_capacity),2) AS 'Avg_Battery_Capacity' FROM dsmp.smartphones GROUP BY brand_name ORDER BY Nums_Phone DESC LIMIT 15;

# group smartphone by whether they have an NFC and get the average price and rating
SELECT has_nfc, AVG(price) AS 'avg_price', AVG(rating) AS 'avg_rating' FROM dsmp.smartphones GROUP BY has_nfc; 

# group smartphone by whether they have an extended memory and get the average price and rating
SELECT extended_memory_available, AVG(price) AS 'avg_price', AVG(rating) AS 'avg_rating' FROM dsmp.smartphones GROUP BY extended_memory_available;

# group smartphone by the brand name and processor brand and get the count of the models and the average primary camera resolution (rear)
SELECT brand_name, processor_brand, COUNT(*) AS 'Total_Phone', ROUND(AVG(primary_camera_rear),2) AS 'Avg Camera Resolution' FROM dsmp.smartphones
GROUP BY brand_name,processor_brand;

# top 5 most costly phones brands
SELECT brand_name, AVG(price) AS 'Avg_Price' FROM dsmp.smartphones GROUP BY brand_name ORDER BY Avg_Price DESC LIMIT 5;

# which brand makes the smallest size screen phones
SELECT brand_name, ROUND(AVG(screen_size),2) AS 'Avg_Screen_Size' FROM dsmp.smartphones GROUP BY brand_name ORDER BY screen_size ASC LIMIT 1;

# group smartphones by the brand, and find the brand with the highest number of models that have both NFC and an IR blaster  
SELECT brand_name, COUNT(*) AS 'Count' FROM dsmp.smartphones WHERE has_nfc='True' AND has_ir_blaster='True' GROUP BY brand_name 
ORDER BY Count DESC LIMIT 1;

# Find all the 5g samsung phone and calculate abg price for nfc and non nfc phone
SELECT has_nfc, brand_name, ROUND(AVG(price),2) AS 'Avg_Price' FROM dsmp.smartphones WHERE brand_name='samsung' AND has_5g='True' GROUP BY has_nfc;

# Having Clause 
# Find average rating of smartphone brands which have more than 20 phones
SELECT brand_name, ROUND(AVG(rating),2) AS 'Avg_Rating', COUNT(*) AS 'COUNT' FROM dsmp.smartphones GROUP BY brand_name 
HAVING Count>20 ORDER BY Avg_Rating DESC;

# find the top 3 brands with the highest avg ram that have a refresh rate of atleast 90 hz and fast charging available 
# and dont consider brands which have less than 10 phone 
SELECT brand_name, ROUND(AVG(ram_capacity),2) AS 'avg_ram_capacity', COUNT(*) AS 'count' FROM dsmp.smartphones 
WHERE refresh_rate>='90' AND fast_charging_available='1' 
GROUP BY brand_name HAVING count>10 ORDER BY avg_ram_capacity DESC LIMIT 3;

# find average price of all the phone brands with avg rating > 70 and num_phones more than 10 among all 5g enabled phones
SELECT brand_name, ROUND(AVG(price),2) AS 'avg_price' FROM dsmp.smartphones 
WHERE has_5g='True' GROUP BY brand_name HAVING ROUND(AVG(rating))>'70' AND COUNT(*)>'10';



# Practice 
# find top 5 batsman in ipl
SELECT * FROM dsmp.ipl;
SELECT batter, SUM(batsman_run) AS 'batsman_run' FROM dsmp.ipl GROUP BY batter ORDER BY batsman_run DESC LIMIT 5;

# find the second highest 6 hitter in ipl
SELECT batter,COUNT(*) AS 'num_sixes' FROM dsmp.ipl WHERE batsman_run='6' GROUP BY batter ORDER BY num_sixes DESC LIMIT 1,1;

# Find top 10 batsman with centuries in ipl
SELECT batter,ID,SUM(batsman_run) AS 'score' FROM dsmp.ipl GROUP BY batter, ID HAVING score>=100 ORDER BY batter DESC LIMIT 10;

# find the top 5 batsman with highest strike rate who have played a min of 1000 balls
SELECT batter,SUM(batsman_run) AS 'score' ,COUNT(batsman_run), ROUND((SUM(batsman_run)/COUNT(batsman_run)*100),2) AS 'strikerate' FROM dsmp.ipl 
GROUP BY batter HAVING COUNT(batsman_run)>1000 ORDER BY strikerate DESC LIMIT 5;
