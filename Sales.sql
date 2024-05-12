
-- ############ 1. SETTING UP DATA ############ --

-- Creating the Sales Table that will hold the raw data --
-- Imported Dataset via the PgAdmin4 GUI -- 
CREATE TABLE IF NOT EXISTS Sales ( 
	"Date" Date,
	AveragePrice real,
	TotalVolume real,
	plu4046 real,
	plu4225 real,
	plu4770 real,
	TotalBags real,
	SmallBags real,
	LargeBags real,
	XLargeBags real,
	"type" varchar(100),
	"year" varchar(100),
	region varchar(100)
);

-- Creating a copy of Sales table -- 
-- This is so I dont mess with the raw data while cleaning or analyzing -- 
CREATE TABLE IF NOT EXISTS sales_copy AS
SELECT * FROM sales;

-- ############ 2. CLEANING DATA ############ --

-- Checking for Duplicates --
-- There were None in the data -- 
SELECT region, "Date", COUNT(*)
FROM sales_copy
GROUP BY "Date", averageprice, totalvolume, plu4046, plu4225, plu4770, totalbags, smallbags, largebags, xlargebags, "type", "year", region
HAVING COUNT(*) > 1;

-- Checking to see if the regions are standardized or if they need cleaning -- 
-- They needed cleaning -- 
SELECT DISTINCT region
FROM sales_copy
ORDER BY region asc;

-- Standaraizing the New York region rows -- 
UPDATE sales_copy
SET region = 'NewYork'
WHERE region = 'New York';

-- Standaraizing the Northern New England region rows -- 
UPDATE sales_copy
SET region = 'NorthernNewEngland'
WHERE region = 'Northern New England';

-- checking if the TotalUS region is needed -- 
SELECT * 
FROM sales_copy 
where region = 'TotalUS';

-- Dropping the rows with the region "TotalUS" as it is not an actual region or city and would mess with later calculations
DELETE FROM sales_copy 
WHERE region = 'TotalUS';

-- Checking to see if the "type"s are standardized or if they need cleaning -- 
-- They needed cleaning -- 
SELECT DISTINCT "type"
FROM sales_copy
ORDER BY "type" asc;

-- Standaraizing the Conventional rows --
UPDATE sales_copy
SET "type" = 'Conventional'
WHERE "type" = 'conventional';

-- Standaraizing the Organic rows --
UPDATE sales_copy
SET "type" = 'Organic'
WHERE "type" = 'organic';

-- ############ 3. ANALYZING THE DATA ############ --

-- Q: What regions sold the most amount of bags? -- 
/* A: 1. West 
      2. Northwest
      3. SouthCentral 
      4. California 
      5. Southeast */
SELECT region, SUM(totalbags) AS total_bags_per_region
FROM sales_copy
GROUP BY region
ORDER BY total_bags_per_region desc
LIMIT 5;

-- Q: Which year sold the most bags of avocados? -- 
/* A: 2017 */
SELECT "year", SUM(totalbags) AS total_bags_per_region
FROM sales_copy
GROUP BY "year"
ORDER BY total_bags_per_region desc;

-- Q: What is the total number of bags sold by type? --
/* A: Conventional: 5.01 Billion
      Organic:      404  Million  */
SELECT "type", sum(totalbags)
FROM sales_copy
GROUP BY "type";

-- Q: What region sold the most amount of single avocados based on their size? -- 
/* A: Small/Medium: SouthCentral
      Large:        Northeast
      X-Large:      GreatLakes
*/ 
-- Small/Medium --
SELECT region, sum(plu4046) as small
FROM sales_copy
GROUP BY region
ORDER BY small DESC
LIMIT 1;
-- Large -- 
SELECT region, sum(plu4225) as "large"
FROM sales_copy
GROUP BY region
ORDER BY "large" DESC
LIMIT 1;
-- X-Large -- 
SELECT region, sum(plu4770) as "x-large"
FROM sales_copy
GROUP BY region
ORDER BY "x-large" DESC
LIMIT 1;

-- Q: What region sold the most amount of avocado bags based on their size? -- 
/* A: Small:    California
      Large:    West
      X-Large:  GreatLakes
*/ 
-- Small --
SELECT region, sum(smallbags) as small
FROM sales_copy
GROUP BY region
ORDER BY small DESC
LIMIT 1;
-- Large -- 
SELECT region, sum(largebags) as "large"
FROM sales_copy
GROUP BY region
ORDER BY "large" DESC
LIMIT 1;
-- X-Large -- 
SELECT region, sum(xlargebags) as "x-large"
FROM sales_copy
GROUP BY region
ORDER BY "x-large" DESC
LIMIT 1;

-- Q: What was the average price of an avocado? -- 
/* A: $1.42 */
SELECT ROUND(CAST(AVG(averageprice) AS numeric), 2) AS avg_price
FROM sales_copy;

-- Q: What was the average price of an avocado for each region? -- 
/* A: This is a long listed answer and it is better to print out to see for yourself */
SELECT region, ROUND(CAST(AVG(averageprice) AS numeric), 2) AS avg_price
FROM sales_copy
GROUP BY region
ORDER BY region ASC;

-- Q: What was the average price of an avocado for each region per year? -- 
/* A: This is a long listed answer and it is better to print out to see for yourself */
SELECT region, "year", ROUND(CAST(AVG(averageprice) AS numeric), 2) AS avg_price
FROM sales_copy
GROUP BY region, "year"
ORDER BY region ASC, "year" ASC;

-- Q: What was the average price of an avocado for each region per year based on the type? -- 
/* A: This is a long listed answer and it is better to print out to see for yourself */
SELECT region, "year", "type", ROUND(CAST(AVG(averageprice) AS numeric), 2) AS avg_price
FROM sales_copy
GROUP BY region, "year", "type"
ORDER BY region ASC, "year" ASC, "type" ASC;