USE laptop;
SELECT * FROM laptopdata;

-- DATA CLEANING --

-- Step 1: Create a backup of the data
CREATE TABLE laptop_backup LIKE laptop; 
INSERT INTO laptop_backup (SELECT * FROM laptop);

-- Step 2: Check number of rows
SELECT COUNT(*) FROM laptop;

-- Step 3: Check memory consumption for reference 
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES WHERE TABLE_SCHEMA='laptop' AND TABLE_NAME='laptop'; -- (256 KB DATASET)

-- Step 4: Drop non important columns
ALTER TABLE laptop RENAME COLUMN `Unnamed: 0` TO `index`;
SELECT * FROM laptop;

-- Step 5: Drop all rows that contains completely null values
DELETE FROM laptop
WHERE `index` IN (SELECT `index` FROM laptop
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
WEIGHT IS NULL AND Price IS NULL);

-- Step 6: Drop duplicates

-- Step 7: Clean RAM, change col datatype
UPDATE laptop l1
SET Ram = (SELECT REPLACE(Ram,'GB','') FROM laptop l2 WHERE l2.index = l1.index);
ALTER TABLE laptop MODIFY COLUMN Ram INTEGER;

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sql_cx_live'
AND TABLE_NAME = 'laptop';

-- Step 8: Clean weights, replace kg with blank 
UPDATE laptop l1 SET Weight = (SELECT REPLACE(Weight,'kg','') FROM laptop l2 WHERE l2.index = l1.index);
SELECT * FROM laptop;

-- Step 9: change price col datatype
UPDATE laptop l1 SET Price = (SELECT ROUND(Price) FROM laptop l2 WHERE l2.index = l1.index);
ALTER TABLE laptop MODIFY COLUMN Price INTEGER;

-- Step 10: Change inches column to decimal
ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1);

-- Step 11: Clean os column
SELECT DISTINCT OpSys FROM laptop;

-- mac
-- windows
-- linux
-- no os
-- Android chrome(others)

SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END AS 'os_brand'
FROM laptop;

UPDATE laptop
SET OpSys = 
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

SELECT * FROM laptop;

-- Step 12: Clean gpu column 

ALTER TABLE laptops
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptops l1
SET gpu_brand = (SELECT SUBSTRING_INDEX(Gpu,' ',1) 
				FROM laptop l2 WHERE l2.index = l1.index);

UPDATE laptops l1
SET gpu_name = (SELECT REPLACE(Gpu,gpu_brand,'') 
				FROM laptop l2 WHERE l2.index = l1.index);
                
SELECT * FROM laptop;

ALTER TABLE laptop DROP COLUMN Gpu;

-- Step 13: Clean cpu column 

SELECT * FROM laptops;

ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

SELECT * FROM laptop;

UPDATE laptop l1
SET cpu_brand = (SELECT SUBSTRING_INDEX(Cpu,' ',1) 
				 FROM laptop l2 WHERE l2.index = l1.index);

UPDATE laptop l1
SET cpu_speed = (SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','')
				AS DECIMAL(10,2)) FROM laptop l2 
                WHERE l2.index = l1.index);
 
UPDATE laptop l1
SET cpu_name = (SELECT
					REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'')
					FROM laptop l2 
					WHERE l2.index = l1.index);
                    
SELECT * FROM laptop;

ALTER TABLE laptop DROP COLUMN Cpu;
SELECT * FROM laptop;

-- Step 14: Clean screen resolution column 

SELECT ScreenResolution,
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)
FROM laptop;

ALTER TABLE laptop
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

SELECT * FROM laptop;

UPDATE laptop
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

ALTER TABLE laptop ADD COLUMN touchscreen INTEGER AFTER resolution_height;

SELECT ScreenResolution LIKE '%Touch%' FROM laptop;

UPDATE laptop SET touchscreen = ScreenResolution LIKE '%Touch%';

SELECT * FROM laptop;

ALTER TABLE laptop DROP COLUMN ScreenResolution;

SELECT * FROM laptop;

-- Step 15: Clean cpu_name column 

SELECT cpu_name, SUBSTRING_INDEX(TRIM(cpu_name),' ',2) FROM laptop;

UPDATE laptop SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

SELECT DISTINCT cpu_name FROM laptop;

-- Step 16: Clean screen memory column
SELECT Memory FROM laptop;

ALTER TABLE laptop
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;
 
SELECT * FROM laptop;

SELECT Memory,
CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptop;

UPDATE laptop
SET memory_type = CASE
	WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

SELECT Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END
FROM laptop;

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT 
primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
FROM laptop;

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

SELECT * FROM laptop;

# gpu_name column is not so important because of clutered information inside it
ALTER TABLE laptop DROP COLUMN gpu_name;

SELECT * FROM laptop;