create database bike_sales_raw;
use bike_sales_raw;
--upload the dataset file throught manually into sql--

CREATE TABLE bike_raw (State VARCHAR(50), Avg_Daily_Distance VARCHAR(30), Brand VARCHAR(50), Model VARCHAR(50),
  Price VARCHAR(30), Year_Manufacture VARCHAR(10), Engine_cc VARCHAR(20), Fuel_Type VARCHAR(30),
  Mileage VARCHAR(30), Owner_Type VARCHAR(30), Registration_Year VARCHAR(10),
  Insurance_Status VARCHAR(30), Seller_Type VARCHAR(30), Resale_Price VARCHAR(30), City_Tier VARCHAR(30)
) CHARACTER SET utf8mb4;
select * from bike_raw;
DROP TABLE IF EXISTS bike_sales_raw.bike_sales_india_raw;
CREATE TABLE bike_sales_raw.bike_sales_india_raw (State VARCHAR(50), Avg_Daily_Distance VARCHAR(30), Brand VARCHAR(50), Model VARCHAR(50),
  Price VARCHAR(30), Year_Manufacture VARCHAR(10), Engine_cc VARCHAR(20), Fuel_Type VARCHAR(30),
  Mileage VARCHAR(30), Owner_Type VARCHAR(30), Registration_Year VARCHAR(10),
  Insurance_Status VARCHAR(30), Seller_Type VARCHAR(30), Resale_Price VARCHAR(30), City_Tier VARCHAR(30)
) CHARACTER SET utf8mb4;
SELECT COUNT(*) FROM bike_sales_raw.bike_sales_india_raw;
CREATE TABLE bike_clean AS SELECT * FROM bike_raw;  
SELECT COUNT(*) FROM bike_clean;
SELECT State, COUNT(*) FROM bike_clean GROUP BY State ORDER BY 2 DESC;  
SELECT Brand, Model, Price, COUNT(*) FROM bike_clean
GROUP BY State, Avg_Daily_Distance, Brand, Model, Price, Year_Manufacture, Engine_cc, Fuel_Type, Mileage,
         Owner_Type, Registration_Year, Insurance_Status, Seller_Type, Resale_Price, City_Tier HAVING COUNT(*) > 1;  
UPDATE bike_clean SET State = TRIM(State), Brand = TRIM(Brand), Model = TRIM(Model), Fuel_Type = TRIM(Fuel_Type), Owner_Type = TRIM(Owner_Type), Insurance_Status = TRIM(Insurance_Status),
  Seller_Type = TRIM(Seller_Type), City_Tier = TRIM(City_Tier);
  UPDATE bike_clean SET State = CASE
  WHEN State IN ('UP','U.P.') THEN 'Uttar Pradesh'
  WHEN State IN ('TN','Tamilnadu') THEN 'Tamil Nadu'
  WHEN State IN ('MH','Maharastra') THEN 'Maharashtra'
  WHEN State IN ('KA','Karnatak') THEN 'Karnataka'
  WHEN State IN ('New Delhi','DL') THEN 'Delhi'
  WHEN State IN ('WB','W. Bengal') THEN 'West Bengal'
  ELSE State END;

UPDATE bike_clean SET Brand = CASE
  WHEN Brand IN ('RE','Royal-Enfield','Royal Enfeild') THEN 'Royal Enfield'
  WHEN Brand IN ('Hero MotoCorp','Hero Honda') THEN 'Hero'
  WHEN Brand = 'Bajaj Auto' THEN 'Bajaj'
  WHEN Brand = 'Honda Motorcycle' THEN 'Honda'
  ELSE Brand END;

UPDATE bike_clean SET Fuel_Type = CASE
  WHEN Fuel_Type = 'Gasoline' THEN 'Petrol'
  WHEN Fuel_Type IN ('EV','Elec') THEN 'Electric' ELSE Fuel_Type END;

UPDATE bike_clean SET Owner_Type = CASE
  WHEN Owner_Type IN ('1st','1','First Owner') THEN 'First'
  WHEN Owner_Type IN ('2nd','2') THEN 'Second'
  WHEN Owner_Type IN ('3rd','3') THEN 'Third' ELSE Owner_Type END;

UPDATE bike_clean SET City_Tier = CASE
  WHEN City_Tier IN ('T1','Tier-1','Tier1') THEN 'Tier 1'
  WHEN City_Tier IN ('T2','Tier-2') THEN 'Tier 2'
  WHEN City_Tier IN ('T3','Tier-3') THEN 'Tier 3'
  WHEN City_Tier IN ('Metropolitan','Metro City') THEN 'Metro' ELSE City_Tier END;

UPDATE bike_clean SET Insurance_Status = 'Not Available'
WHERE Insurance_Status IN ('NA','N/A','None');
SET SQL_SAFE_UPDATES = 0;
UPDATE bike_clean SET State = NULL WHERE State IN ('','NA','N/A','null','nan','-','?','Unknown');
-- repeat for the other columns
UPDATE bike_clean SET
  Price = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Price,'₹',''),'Rs.',''),'INR',''),',',''),' ',''),
  Resale_Price = REPLACE(REPLACE(REPLACE(REPLACE(Resale_Price,'₹',''),'Rs',''),'.' ,'.'),',',''),
  Engine_cc = REPLACE(REPLACE(LOWER(Engine_cc),'cc',''),' ',''),
  Mileage = REPLACE(REPLACE(LOWER(Mileage),'kmpl',''),'km/l',''),
  Avg_Daily_Distance = REPLACE(LOWER(Avg_Daily_Distance),'km','');
 ALTER TABLE bike_clean
  MODIFY Price DECIMAL(12,2), MODIFY Resale_Price DECIMAL(12,2),
  MODIFY Engine_cc INT, MODIFY Mileage DECIMAL(6,2), MODIFY Avg_Daily_Distance DECIMAL(6,2);
SELECT DISTINCT Price FROM bike_clean WHERE Price NOT REGEXP '^-?[0-9]+([.][0-9]+)?$';
SELECT DISTINCT Resale_Price FROM bike_clean WHERE Resale_Price NOT REGEXP '^-?[0-9]+([.][0-9]+)?$';
SELECT DISTINCT Engine_cc FROM bike_clean WHERE Engine_cc NOT REGEXP '^-?[0-9]+$';
SELECT DISTINCT Mileage FROM bike_clean WHERE Mileage NOT REGEXP '^-?[0-9]+([.][0-9]+)?$';
SELECT DISTINCT Avg_Daily_Distance FROM bike_clean WHERE Avg_Daily_Distance NOT REGEXP '^-?[0-9]+([.][0-9]+)?$';

SET SQL_SAFE_UPDATES = 0;

UPDATE bike_clean SET Price = NULL WHERE TRIM(Price) IN ('','NA','N/A','null','nan','-','?','Unknown','None');
UPDATE bike_clean SET Resale_Price = NULL WHERE TRIM(Resale_Price) IN ('','NA','N/A','null','nan','-','?','Unknown','None');
UPDATE bike_clean SET Engine_cc = NULL WHERE TRIM(Engine_cc) IN ('','NA','N/A','null','nan','-','?','Unknown','None');
UPDATE bike_clean SET Mileage = NULL WHERE TRIM(Mileage) IN ('','NA','N/A','null','nan','-','?','Unknown','None');
UPDATE bike_clean SET Avg_Daily_Distance = NULL WHERE TRIM(Avg_Daily_Distance) IN ('','NA','N/A','null','nan','-','?','Unknown','None');
ALTER TABLE bike_clean
  MODIFY Price DECIMAL(12,2), MODIFY Resale_Price DECIMAL(12,2),
  MODIFY Engine_cc INT, MODIFY Mileage DECIMAL(6,2), MODIFY Avg_Daily_Distance DECIMAL(6,2);
  UPDATE bike_clean SET Year_Manufacture = CONCAT('20', Year_Manufacture) WHERE LENGTH(Year_Manufacture) = 2;
UPDATE bike_clean SET Registration_Year = REPLACE(Registration_Year, '.0', '');
ALTER TABLE bike_clean MODIFY Year_Manufacture INT, MODIFY Registration_Year INT;
UPDATE bike_clean SET Price = NULL WHERE Price NOT BETWEEN 40000 AND 500000;
UPDATE bike_clean SET Resale_Price = NULL WHERE Resale_Price NOT BETWEEN 10000 AND 400000;
UPDATE bike_clean SET Mileage = NULL WHERE Mileage NOT BETWEEN 10 AND 120;
UPDATE bike_clean SET Engine_cc = NULL WHERE Engine_cc NOT BETWEEN 90 AND 1100;
UPDATE bike_clean SET Avg_Daily_Distance = NULL WHERE Avg_Daily_Distance NOT BETWEEN 1 AND 150;
UPDATE bike_clean SET Registration_Year = NULL WHERE Registration_Year < Year_Manufacture;
DELETE FROM bike_clean WHERE Price IS NULL OR Resale_Price IS NULL;

UPDATE bike_clean SET Mileage = (SELECT m FROM (SELECT ROUND(AVG(Mileage),2) AS m FROM bike_clean) t)
WHERE Mileage IS NULL;

DELETE FROM bike_clean WHERE State IS NULL OR Brand IS NULL OR Model IS NULL OR Fuel_Type IS NULL
   OR Owner_Type IS NULL OR Insurance_Status IS NULL OR Seller_Type IS NULL OR City_Tier IS NULL
   OR Year_Manufacture IS NULL OR Registration_Year IS NULL OR Engine_cc IS NULL;
   
   DELETE FROM bike_clean WHERE Price IS NULL OR Resale_Price IS NULL;

UPDATE bike_clean SET Mileage = (SELECT m FROM (SELECT ROUND(AVG(Mileage),2) AS m FROM bike_clean) t)
WHERE Mileage IS NULL;

DELETE FROM bike_clean WHERE State IS NULL OR Brand IS NULL OR Model IS NULL OR Fuel_Type IS NULL
   OR Owner_Type IS NULL OR Insurance_Status IS NULL OR Seller_Type IS NULL OR City_Tier IS NULL
   OR Year_Manufacture IS NULL OR Registration_Year IS NULL OR Engine_cc IS NULL;
   CREATE TABLE bike_final AS SELECT DISTINCT * FROM bike_clean;
   
   ALTER TABLE bike_final ADD COLUMN Vehicle_Age INT, ADD COLUMN Depreciation_Amount DECIMAL(12,2),
  ADD COLUMN Resale_Percentage DECIMAL(6,2), ADD COLUMN Depreciation_Percentage DECIMAL(6,2);

UPDATE bike_final SET
  Vehicle_Age = 2026 - Year_Manufacture,
  Depreciation_Amount = Price - Resale_Price,
  Resale_Percentage = Resale_Price / Price * 100,
  Depreciation_Percentage = (Price - Resale_Price) / Price * 100;
  SELECT Brand, ROUND(AVG(Resale_Percentage),1) AS avg_resale_pct, COUNT(*) AS bikes
FROM bike_final GROUP BY Brand ORDER BY avg_resale_pct DESC;

SELECT State, COUNT(*) FROM bike_final GROUP BY State ORDER BY 2 DESC;

SELECT Fuel_Type, Owner_Type, ROUND(AVG(Resale_Price)) FROM bike_final GROUP BY Fuel_Type, Owner_Type;

SET SQL_SAFE_UPDATES = 0;


UPDATE bike_clean SET Price = NULL WHERE TRIM(Price) REGEXP '^-';
UPDATE bike_clean SET Resale_Price = NULL WHERE TRIM(Resale_Price) REGEXP '^-';
UPDATE bike_clean SET Engine_cc = NULL WHERE TRIM(Engine_cc) REGEXP '^-';
UPDATE bike_clean SET Mileage = NULL WHERE TRIM(Mileage) REGEXP '^-';
UPDATE bike_clean SET Avg_Daily_Distance = NULL WHERE TRIM(Avg_Daily_Distance) REGEXP '^-';


UPDATE bike_clean SET
  Price = NULLIF(REGEXP_REPLACE(REPLACE(Price,'Rs.',''),'[^0-9.]',''),''),
  Resale_Price = NULLIF(REGEXP_REPLACE(REPLACE(Resale_Price,'Rs.',''),'[^0-9.]',''),''),
  Engine_cc = NULLIF(REGEXP_REPLACE(Engine_cc,'[^0-9.]',''),''),
  Mileage = NULLIF(REGEXP_REPLACE(Mileage,'[^0-9.]',''),''),
  Avg_Daily_Distance = NULLIF(REGEXP_REPLACE(Avg_Daily_Distance,'[^0-9.]',''),'');
  SELECT Price FROM bike_clean WHERE Price NOT REGEXP '^[0-9]+([.][0-9]+)?$' LIMIT 20;   
  ALTER TABLE bike_clean
  MODIFY Price DECIMAL(12,2), MODIFY Resale_Price DECIMAL(12,2),
  MODIFY Engine_cc INT, MODIFY Mileage DECIMAL(6,2), MODIFY Avg_Daily_Distance DECIMAL(6,2);
  UPDATE bike_clean SET Year_Manufacture = NULL WHERE Year_Manufacture NOT REGEXP '^[0-9]+(\\.0)?$';
UPDATE bike_clean SET Registration_Year = NULL WHERE Registration_Year NOT REGEXP '^[0-9]+(\\.0)?$';
UPDATE bike_clean SET Year_Manufacture = REPLACE(Year_Manufacture,'.0',''), Registration_Year = REPLACE(Registration_Year,'.0','');
UPDATE bike_clean SET Year_Manufacture = CONCAT('20',Year_Manufacture) WHERE LENGTH(Year_Manufacture) = 2;
UPDATE bike_clean SET Registration_Year = CONCAT('20',Registration_Year) WHERE LENGTH(Registration_Year) = 2;
ALTER TABLE bike_clean MODIFY Year_Manufacture INT, MODIFY Registration_Year INT;

UPDATE bike_clean SET Price = NULL WHERE Price NOT BETWEEN 40000 AND 500000;
UPDATE bike_clean SET Resale_Price = NULL WHERE Resale_Price NOT BETWEEN 10000 AND 400000;
UPDATE bike_clean SET Mileage = NULL WHERE Mileage NOT BETWEEN 10 AND 120;
UPDATE bike_clean SET Engine_cc = NULL WHERE Engine_cc NOT BETWEEN 90 AND 1100;
UPDATE bike_clean SET Avg_Daily_Distance = NULL WHERE Avg_Daily_Distance NOT BETWEEN 1 AND 150;
UPDATE bike_clean SET Registration_Year = NULL WHERE Registration_Year < Year_Manufacture;

DELETE FROM bike_clean WHERE Price IS NULL OR Resale_Price IS NULL OR State IS NULL OR Brand IS NULL
   OR Model IS NULL OR Fuel_Type IS NULL OR Owner_Type IS NULL OR Insurance_Status IS NULL
   OR Seller_Type IS NULL OR City_Tier IS NULL OR Year_Manufacture IS NULL OR Registration_Year IS NULL
   OR Engine_cc IS NULL OR Mileage IS NULL OR Avg_Daily_Distance IS NULL;
   
   DROP TABLE IF EXISTS bike_final;
CREATE TABLE bike_final AS SELECT DISTINCT * FROM bike_clean;

ALTER TABLE bike_final ADD COLUMN Vehicle_Age INT, ADD COLUMN Depreciation_Amount DECIMAL(12,2),
  ADD COLUMN Resale_Percentage DECIMAL(6,2), ADD COLUMN Depreciation_Percentage DECIMAL(6,2);

UPDATE bike_final SET
  Vehicle_Age = 2026 - Year_Manufacture,
  Depreciation_Amount = Price - Resale_Price,
  Resale_Percentage = Resale_Price / Price * 100,
  Depreciation_Percentage = (Price - Resale_Price) / Price * 100;
  SELECT COUNT(*) FROM bike_final;
SELECT Brand, COUNT(*) FROM bike_final GROUP BY Brand;  
SELECT Price, Resale_Price, ROUND(Resale_Price / Price * 100, 1) AS pct
FROM bike_final
WHERE Price NOT BETWEEN 40000 AND 500000
   OR Resale_Price NOT BETWEEN 10000 AND 400000
   OR Resale_Price > Price
LIMIT 20;

SET SQL_SAFE_UPDATES = 0;

UPDATE bike_clean SET Price = NULL WHERE Price NOT BETWEEN 40000 AND 500000;
UPDATE bike_clean SET Resale_Price = NULL WHERE Resale_Price NOT BETWEEN 10000 AND 400000;
UPDATE bike_clean SET Mileage = NULL WHERE Mileage NOT BETWEEN 10 AND 120;
UPDATE bike_clean SET Engine_cc = NULL WHERE Engine_cc NOT BETWEEN 90 AND 1100;
UPDATE bike_clean SET Avg_Daily_Distance = NULL WHERE Avg_Daily_Distance NOT BETWEEN 1 AND 150;
UPDATE bike_clean SET Registration_Year = NULL WHERE Registration_Year < Year_Manufacture;

DELETE FROM bike_clean WHERE Price IS NULL OR Resale_Price IS NULL OR State IS NULL OR Brand IS NULL
   OR Model IS NULL OR Fuel_Type IS NULL OR Owner_Type IS NULL OR Insurance_Status IS NULL
   OR Seller_Type IS NULL OR City_Tier IS NULL OR Year_Manufacture IS NULL OR Registration_Year IS NULL
   OR Engine_cc IS NULL OR Mileage IS NULL OR Avg_Daily_Distance IS NULL;

-- also remove rows where resale is higher than the original price
DELETE FROM bike_clean WHERE Resale_Price > Price;
DROP TABLE IF EXISTS bike_final;
CREATE TABLE bike_final AS SELECT DISTINCT * FROM bike_clean;

ALTER TABLE bike_final ADD COLUMN Vehicle_Age INT, ADD COLUMN Depreciation_Amount DECIMAL(12,2),
  ADD COLUMN Resale_Percentage DECIMAL(6,2), ADD COLUMN Depreciation_Percentage DECIMAL(6,2);

UPDATE bike_final SET
  Vehicle_Age = 2026 - Year_Manufacture,
  Depreciation_Amount = Price - Resale_Price,
  Resale_Percentage = Resale_Price / Price * 100,
  Depreciation_Percentage = (Price - Resale_Price) / Price * 100;

SELECT COUNT(*) FROM bike_final;
