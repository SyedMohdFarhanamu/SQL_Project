SHOW DATABASES;
CREATE DATABASE project;
USE project;
desc census_data1;
desc census_data2;
Select * from census_data1;
Select * from census_data2;

-- Number of rows into our dataset
SELECT COUNT(*) AS 'NUMBER OF ROWS' FROM census_data1;
SELECT COUNT(*) AS 'NUMBER OF ROWS' FROM census_data2;

-- Dataset for Jharkhand and Bihar
SELECT * FROM census_data1 WHERE state IN('Jharkhand', 'Bihar');
SELECT * FROM census_data2 WHERE state IN('Jharkhand', 'Bihar');

-- Population of India
select SUM(REPLACE(population,',','')) from census_data2;

-- avg growth of India
SELECT  AVG(growth) 'Average Growth of India' FROM census_data1;

-- avg growth of India by state wise
SELECT state, ROUND(AVG(growth),2) 'Average Growth State Wise' FROM census_data1 GROUP BY state;

-- avg sex ratio of India
SELECT ROUND(AVG(sex_ratio),2) 'Average Sex ration of India' FROM census_data1;

-- avg sex ratio of India by State wise
SELECT state, ROUND(AVG(sex_ratio),2) 'Average Sex ratio State Wise' FROM census_data1 GROUP BY state ORDER BY ROUND(AVG(sex_ratio),2);

-- avg literacy rate of India 
SELECT ROUND(AVG(literacy),2) FROM census_data1;

-- Avg literacy rate state wise 
SELECT state, ROUND(AVG(literacy),0) AS avg_literacy_rate 
FROM census_data1 
GROUP BY state 
ORDER BY avg_literacy_rate;

-- Avg literacy rate state wise which is greater than 90
SELECT state, ROUND(AVG(literacy),0) AS avg_literacy_rate 
FROM census_data1 
GROUP BY state HAVING ROUND(AVG(literacy),0) > 90 
ORDER BY avg_literacy_rate;

-- top 3 state showing highest growth ratio
SELECT state, ROUND(AVG(growth),2) 'Average Growth State Wise' 
FROM census_data1 
GROUP BY state 
ORDER BY ROUND(AVG(growth),2) DESC 
LIMIT 3;

-- bottom 3 state showing lowest sex ratio
SELECT state, ROUND(AVG(sex_ratio),2) 'Average Growth State Wise' 
FROM census_data1 
GROUP BY state 
ORDER BY ROUND(AVG(sex_ratio),2) ASC 
LIMIT 3;

-- top 3 and bottom 3 states in literacy state

create table topstates(
state varchar(55),
literacy_rate int
);

insert into topstates
(select state,round(avg(literacy),0) avg_literacy_ratio from census_data1 
group by state order by avg_literacy_ratio desc);

SELECT * FROM topstates;

SELECT * FROM topstates order by literacy_rate desc limit 3;

create table bottomstates
( state varchar(55),
  literacy_rate int
);

insert into bottomstates
(select state,round(avg(literacy),0) avg_literacy_ratio from census_data1 
group by state order by avg_literacy_ratio desc);

SELECT * FROM bottomstates;
SELECT * FROM bottomstates order by literacy_rate asc limit 3;

select * from (
select  * from topstates order by literacy_rate desc limit 3) a
union
select * from (
select * from bottomstates order by literacy_rate asc limit 3) b;

-- states starting with letter a
SELECT DISTINCT state FROM census_data1 WHERE state like 'a%';

-- states starting with letter a or b
SELECT DISTINCT state FROM census_data1 WHERE state like 'a%' OR state like 'b%';

-- states starting with letter a and ending with h
SELECT DISTINCT state FROM census_data1 WHERE state like 'a%' AND state like '%h';

-- states starting with letter a OR ending with h
SELECT DISTINCT state FROM census_data1 WHERE state like 'a%' OR state like '%h';


-- Number of males and females in state wise
/* 1- Replace ',' in population with blank string 
   2-  divide by 1000 in sex ratio b/c defining in terms of 1000
   3- joining two tables
   4- find the formula to calculate males and females with the help of sex_ratio and population
   5- make group of states
   6- FORMULA TO CALCULATE  MALES AND FEMALES
	  males + females = population
      sex_ratio = females/males
      ---------------------------
      males = population/(sex_ratio + 1)
      females = (population * sex_ratio)/(sex_ratio + 1)
*/

SELECT d.state, SUM(d.Toatal_males),SUM(d.Total_females) 
FROM (SELECT c.district,c.state state,ROUND(c.population/(c.sex_ratio+1),0) AS Toatal_males,
ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1),0) AS Total_females
FROM (SELECT a.district,a.state,a.sex_ratio/1000 AS sex_ratio,REPLACE(b.population,',','') AS population 
FROM census_data1 AS a INNER JOIN census_data2 AS b
ON a.district=b.district ) c) d 
GROUP BY d.state;


desc census_data2;
select SUM(REPLACE(population,',','')) from census_data2;


-- total literacy rate in state wise 
/* Literacy Ratio = total literate people/population
   total literate people = Literacy Ratio * population
   total illitrate people = (1-Literacy Ratio) * population

*/

SELECT c.state, SUM(Literate_people) Total_literate_pop, SUM(Illiterate_people) Total_illiterate_pop
FROM (SELECT d.district, d.state, ROUND(d.literacy_ratio*d.population,0) AS Literate_people, ROUND((1-d.literacy_ratio)*d.population,0) AS Illiterate_people
FROM (SELECT a.district,a.state,a.literacy/100 AS literacy_ratio, REPLACE(b.population,',','') AS population 
FROM census_data1 AS a INNER JOIN census_data2 AS b
ON a.district=b.district) d) c 
GROUP BY c.state;


-- Population in previous cencus
/* Population :-
   population = previous cencus + growth * previous cencus
   previous cencus = population / (1 + growth)
   -- growth must be divided by 100 b/c its given in terms of percentage.
   */
   
SELECT SUM(m.previous_cencus_population) AS previous_cencus_population, SUM(m.current_cencus_population) AS current_cencus_population FROM
(SELECT c.state, SUM(c.previous_cencus_population) previous_cencus_population, SUM(c.current_cencus_population) current_cencus_population FROM
(SELECT d.district, d.state, ROUND(d.population/(1+d.growth),0) AS previous_cencus_population, d.population AS current_cencus_population FROM
(SELECT a.district,a.state,ROUND(a.growth/100,4) AS growth, REPLACE(b.population,',','') AS population 
FROM census_data1 AS a INNER JOIN census_data2 AS b
ON a.district=b.district) d) c
GROUP BY c.state) m ;


-- Population VS Area

SELECT g.total_area/g.previous_cencus_population AS previous_cencus_population_vs_area,
g.total_area/g.current_cencus_population AS current_cencus_population_vs_area FROM
(SELECT q.*, r.total_area FROM  
(SELECT '1' AS keyy, n.* FROM (
SELECT SUM(m.previous_cencus_population) AS previous_cencus_population, SUM(m.current_cencus_population) AS current_cencus_population FROM
(SELECT c.state, SUM(c.previous_cencus_population) previous_cencus_population, SUM(c.current_cencus_population) current_cencus_population FROM
(SELECT d.district, d.state, ROUND(d.population/(1+d.growth),0) AS previous_cencus_population, d.population AS current_cencus_population FROM
(SELECT a.district,a.state,ROUND(a.growth/100,4) AS growth, REPLACE(b.population,',','') AS population 
FROM census_data1 AS a INNER JOIN census_data2 AS b
ON a.district=b.district) d) c
GROUP BY c.state) m ) n ) q INNER JOIN 

(SELECT '1' AS keyy, z.* FROM(
SELECT SUM(REPLACE(area_km2,',','')) total_area from census_data2) z) r ON q.keyy=r.keyy) g  ;

-- window function
-- Ques:- output top 3 districts from each state with highest literacy rate.

SELECT a.* FROM 
(SELECT district, state, literacy, rank() OVER(PARTITION BY state ORDER BY literacy DESC) AS rnk FROM census_data1) a
WHERE rnk IN(1,2,3);