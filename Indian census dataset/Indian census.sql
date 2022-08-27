USE Project;
SELECT * FROM dbo.Data1;

SELECT * FROM dbo.Data2;

-- Number of rows into our dataset

SELECT count(*) from project..Data1 as rows
SELECT count(*) from project..Data2 as rows

-- dataset for jharkhand and bihar

SELECT * FROM project..data1 Where STATE in ('Jharkhand', 'Bihar')
ORDER BY state;

-- population of India

SELECT sum(population) as population FROM project..data2

-- Avg growth of country India

SELECT avg(growth)*100 as avg_growth FROM project..data1;

-- Avg growth by states

SELECT state,avg(growth)*100 as avg_growth FROM project..data1 
GROUP BY state ORDER BY avg_growth DESC;

-- Avg sex ratio

SELECT state, round(avg(sex_ratio),0) as sex_ratio FROM project..data1 
GROUP BY state ORDER BY sex_ratio DESC;

-- Avg literacy rate

SELECT state, round(avg(literacy),0) as literacy FROM project..data1 
GROUP BY state
HAVING round(avg(literacy),0) > 90
ORDER BY literacy DESC; 

-- Top 3 States which have hightest growth ratio

SELECT TOP 3 state,avg(growth)*100 as avg_growth FROM project..data1 GROUP BY state ORDER BY avg_growth DESC;

-- Bottom 3 States which have lowest sex ratio'

SELECT TOP 3 state, round(avg(sex_ratio),0) as sex_ratio FROM project..data1 
GROUP BY state ORDER BY sex_ratio ;

-- Top and Bottom 3 states in literacy state

DROP TABLE IF EXISTS topstates;

CREATE TABLE topstates
(state nvarchar(255),
 topstates float

  )

INSERT INTO topstates
SELECT TOP 3 state, round(avg(Literacy),0) as avg_literacy_ratio FROM project..data1 
GROUP BY state ORDER BY avg_literacy_ratio DESC;

SELECT * FROM topstates

-- break 

DROP TABLE IF EXISTS bottomstates;

CREATE TABLE bottomstates
(state nvarchar(255),
 bottomstates float

  )

INSERT INTO bottomstates
SELECT TOP 3 state, round(avg(Literacy),0) as avg_literacy_ratio FROM project..data1 
GROUP BY state ORDER BY avg_literacy_ratio;

SELECT * FROM bottomstates

-- Union operator

SELECT * FROM topstates
UNION
SELECT * FROM bottomstates

-- States starting with letter a & b

SELECT DISTINCT state FROM project..data1 WHERE lower(state) like 'a%' or lower(state) like 'b%'

SELECT DISTINCT state FROM project..data1 WHERE lower(state) like 'a%' or lower(state) like 'd%'

-- Joining both tables

SELECT a.district, a.state, a.sex_ratio, b.population, a.growth 
FROM project..data1 a 
INNER JOIN
project..data2 b
ON a.district = b.district;

--  deriving the formula for finding the total no of males and females, DISTRICT LEVEL

--  females / males = sex_ratio ...........1
--  females + male = population ...........2
--  females = population - males ..........3

-- FORMULA FOR MALE POPULATION

--  using eq - 1

--  (population-males) = (sex_ratio)  * males
--  population = males (sex_ratio + 1)
--  males = population/(sex_ratio + 1) ...... FINAL FORMULA FOR MALE

-- FORMULA FOR FEMALE POPULATION
-- from eq-3
-- females = population -population/(sex_ratio+1)


-- finding the total no of males and females, DISTRICT LEVEL

SELECT c.district, c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females FROM
(SELECT a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population 
FROM project..data1 a 
INNER JOIN
project..data2 b
ON a.district = b.district) c;

-- finding the total no of males and females, STATE LEVEL

SELECT d.state, sum(d.males) total_males, sum(d.females) total_females FROM
(SELECT c.district, c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females FROM
(SELECT a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population 
FROM project..data1 a 
INNER JOIN
project..data2 b
ON a.district = b.district) c) d
GROUP BY d.state;

-- Total literacy rate

SELECT c.state, SUM(literate_people) total_literate_pop, SUM(illiterate_people) total_illiterate_pop FROM
(SELECT d.district, d.state, ROUND(d.literacy_ratio*d.population,0) literate_people,
ROUND((1-d.literacy_ratio)* d.population,0) illiterate_people FROM
(SELECT a.district, a.state, a.literacy/100 literacy_ratio, b.population FROM project..data1 a
inner join project..data2 b on a.district=b.district) d) c
GROUP BY c.state

-- Population in Previous census
-- Formula
-- PC + G * PC = CC
-- PC[1 + G] = P 
-- PC = P/[1+G]

SELECT SUM(f.previous_census_population) previous_census_population, SUM(f.current_census_population) current_census_population FROM 
(SELECT e.state, SUM(e.previous_census_population) previous_census_population, SUM(e.current_census_population) current_census_population FROM
(SELECT d.district, d.state, ROUND(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population FROM
(SELECT a.district, a.state, a.growth growth, b.population FROM project..data1 a INNER JOIN project..data2 b on a.District=b.district) d) e
GROUP BY state) f; 

-- Population vs Area

SELECT k.total_area/k.previous_census_population previous_census_population, k.total_area/k.current_census_population current_census_population FROM
(SELECT i.*, j.total_area FROM (

SELECT '1' AS KEYY, g.* FROM
(SELECT SUM(f.previous_census_population) previous_census_population, SUM(f.current_census_population) current_census_population FROM 
(SELECT e.state, SUM(e.previous_census_population) previous_census_population, SUM(e.current_census_population) current_census_population FROM
(SELECT d.district, d.state, ROUND(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population FROM
(SELECT a.district, a.state, a.growth growth, b.population FROM project..data1 a INNER JOIN project..data2 b on a.District=b.district) d) e
GROUP BY state) f) g) i INNER JOIN (

SELECT '1' AS KEYY, h.* FROM (
SELECT SUM(area_km2) total_area FROM project..data2)h) j ON i.keyy=j.keyy) k

-- Window 

SELECT a.* FROM 
(SELECT state, district, literacy, rank() over(partition by state order by literacy desc) rnk FROM project..data1) a

WHERE a.rnk in (1,2,3) ORDER BY state;