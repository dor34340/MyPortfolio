-- Let's first do some cleaning. 
-- We create new columns which will allow us to look at medals a bit easier:

ALTER TABLE athlete_events
--ADD Gold INT
--ADD Silver INT
ADD Bronze INT
UPDATE athlete_events
--SET Gold = CASE WHEN Medal = 'Gold' then 1
	-- ELSE 0
	 --END
--SET Silver = CASE WHEN Medal = 'Silver' then 1
	-- ELSE 0
	-- END
SET Bronze = CASE WHEN Medal = 'Bronze' then 1
	 ELSE 0
	 END


-- QUESTION 1:
-- How many olympics games have been held?
Select COUNT(DISTINCT Games) AS Total_Games
FROM athlete_events

-- QUESTION 2:
-- List down all Olympics games held so far.
Select DISTINCT Games AS Games
FROM athlete_events

-- QUESTION 3:
-- Mention the total no of nations who participated in each olympics game?

CREATE VIEW Joined_Table AS (
SELECT ae.*, nr.region
FROM athlete_events ae join noc_regions$ nr
on ae.NOC = nr.NOC)

Select Games, COUNT(DISTINCT region) as num_of_nations
From Joined_Table
Group by Games

-- 4. Which year saw the highest and lowest no of countries participating in olympics
WITH CTE AS (Select Games, COUNT(DISTINCT region) as num_of_nations
From Joined_Table
Group by Games)
SELECT Games, num_of_nations
FROM CTE
WHERE num_of_nations = (SELECT MAX(num_of_nations) FROM CTE) OR num_of_nations = (SELECT MIN(num_of_nations) FROM CTE)

-- 5. Which nation has participated in all of the olympic games
WITH CTE AS (SELECT region, Count(Distinct Games) as count_of_games
FROM Joined_Table
Group By region)

SELECT *
FROM CTE
Where count_of_games = (Select COUNT(DISTINCT Games) AS Total_Games
FROM athlete_events)

-- 6. Identify the sport which was played in all summer olympics.

WITH CTE AS (SELECT Sport, Count(Distinct Games) as count_of_games
FROM Joined_Table
WHERE Season = 'Summer'
Group By Sport)

SELECT *
FROM CTE
Where count_of_games = (Select COUNT(DISTINCT Games) AS Total_Games
FROM athlete_events
Where Season = 'Summer')

--7. Which Sports were just played only once in the olympics
WITH CTE AS (SELECT Sport, Count(Distinct Games) as count_of_games
FROM Joined_Table
Group By Sport),

     CTE5 AS (SELECT *
FROM CTE
Where count_of_games = 1)

SELECT DISTINCT Joined_Table.Sport, Joined_Table.Games, count_of_games
FROM Joined_Table left join CTE5
ON Joined_Table.Sport = CTE5.Sport
Where CTE5.Sport is not null

--8. Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT Sport) AS num_of_sport
FROM Joined_Table
GROUP BY Games
order by num_of_sport DESC

-- 9. Fetch oldest athletes to win a gold medal
with cte as (SELECT *,
DENSE_RANK () OVER (order by Age DESC) as rnk
From Joined_Table
Where Medal = 'Gold')
Select *
FROM cte
where rnk = 1

-- 10. Find the Ratio of male and female athletes participated in all olympic games.

WITH CTE AS (SELECT(SELECT COUNT (ID) FROM athlete_events WHERE Sex = 'M') AS M, (SELECT COUNT(ID) FROM athlete_events WHERE Sex = 'F') AS F)

SELECT CONCAT('1:',CAST(M AS FLOAT)/CAST(F AS FLOAT)) AS Ratio
FROM CTE

--11. Fetch the top 5 athletes who have won the most gold medals.

WITH CTE AS (
Select Name, Sum(Gold) AS [Num of gold]
From Joined_Table
Group by Name),

CTE1 AS (SELECT Name, [num of gold], DENSE_RANK() OVER(ORDER BY [Num of gold] DESC) as rnk
FROM CTE)

select *
FROM CTE1
Where rnk <= 5

--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH CTE AS (
Select Name, (Sum(Gold)+SUM(Silver)+SUM(Bronze)) AS [Num of Medals]
From Joined_Table
Group by Name),

CTE1 AS (SELECT Name, [Num of Medals], DENSE_RANK() OVER(ORDER BY [Num of Medals] DESC) as rnk
FROM CTE)

select *
FROM CTE1
Where rnk <= 5



-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH CTE AS (
Select region, (Sum(Gold)+SUM(Silver)+SUM(Bronze)) AS [Num of Medals]
From Joined_Table
Group by region),

CTE1 AS (SELECT region, [Num of Medals], DENSE_RANK() OVER(ORDER BY [Num of Medals] DESC) as rnk
FROM CTE)

select *
FROM CTE1
Where rnk <= 5

-- 14. List down total gold, silver and bronze medals won by each country.
Select region, Sum(Gold) AS [Num of Gold], SUM(Silver) AS [Num of Silver], SUM(Bronze) AS [Num of Bronze]
From Joined_Table
Group by region
ORDER BY [Num of Gold] DESC

-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

SELECT DISTINCT Games, region, SUM([Gold]) OVER(PARTITION BY [Games],[region]) AS [Gold Medals]
							 , SUM([Silver]) OVER(PARTITION BY [Games],[region]) AS [Silver Medals]
							 , SUM([Bronze]) OVER(PARTITION BY [Games],[region]) AS [Bronze Medals]
FROM Joined_Table

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
CREATE view test1 AS 
( SELECT DISTINCT Games, region, SUM([Gold]) OVER(PARTITION BY [Games],[region]) AS [Gold Medals]
							 , SUM([Silver]) OVER(PARTITION BY [Games],[region]) AS [Silver Medals]
							 , SUM([Bronze]) OVER(PARTITION BY [Games],[region]) AS [Bronze Medals]
FROM Joined_Table)

select *
from test1
--CREATE VIEW Main as
WITH CTE AS (select Games, region,[Gold Medals], DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Gold Medals] DESC) rnkg
from test1),

CTE1 AS( select Games, region,[Silver Medals], DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Silver Medals] DESC) rnks
from test1),

CTE2 AS (select Games, region,[Bronze Medals], DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Bronze Medals] DESC) rnkb
from test1),

CTE3 AS (SELECT *
FROM CTE 
WHERE rnkg = 1),

CTE4 AS (SELECT *
FROM CTE1
WHERE rnks = 1),

CTE5 AS (SELECT *
FROM CTE2 
WHERE rnkb = 1)

SELECT CTE3.Games, CTE3.region AS MAX_GOLD, CTE4.region AS MAX_SILVER, CTE5.region AS MAX_BRONZE
FROM (CTE3 JOIN CTE4
ON CTE3.Games=CTE4.Games)
join CTE5 ON CTE3.Games = CTE5.Games
 
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

CREATE view test3 AS 
( SELECT DISTINCT Games, region, SUM([Gold]) OVER(PARTITION BY [Games],[region]) AS [Gold Medals]
							 , SUM([Silver]) OVER(PARTITION BY [Games],[region]) AS [Silver Medals]
							 , SUM([Bronze]) OVER(PARTITION BY [Games],[region]) AS [Bronze Medals],
							 SUM([Gold]+[Silver]+[Bronze]) OVER(PARTITION BY [Games],[region]) AS [Tot]
FROM Joined_Table)

WITH CTE AS (select Games, region, DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Gold Medals] DESC) rnkg
from test3),

CTE1 AS( select Games, region, DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Silver Medals] DESC) rnks
from test3),

CTE2 AS (select Games, region, DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Bronze Medals] DESC) rnkb
from test3),

CTE3 AS (select Games, region, DENSE_RANK() OVER(PARTITION BY Games ORDER BY [Tot] DESC) rnkt
from test3),

CTE4 AS (SELECT *
FROM CTE 
WHERE rnkg = 1),

CTE5 AS (SELECT *
FROM CTE1
WHERE rnks = 1),

CTE6 AS (SELECT *
FROM CTE2 
WHERE rnkb = 1),

CTE7 AS (SELECT *
FROM CTE3
WHERE rnkt = 1)

SELECT CTE4.Games, CTE4.region AS MAX_GOLD, CTE5.region AS MAX_SILVER, CTE6.region AS MAX_BRONZE, CTE7.region AS MAX_TOT
FROM (CTE4 JOIN CTE5
ON CTE4.Games=CTE5.Games)
join CTE6 ON CTE4.Games = CTE6.Games
join CTE7 ON CTE4.Games = CTE7.Games

-- 18. Which countries have never won gold medal but have won silver/bronze medals?
with CTE AS (
SELECT DISTINCT region, SUM([Gold]) OVER(PARTITION BY [region]) AS [Gold Medals]
							 , SUM([Silver]) OVER(PARTITION BY [region]) AS [Silver Medals]
							 , SUM([Bronze]) OVER(PARTITION BY [region]) AS [Bronze Medals]
FROM Joined_Table)

Select * 
from CTE
WHERE [Gold Medals] = 0 and [Bronze Medals] = 0 and [Silver Medals] != 0
UNION
SELECT *
FROM CTE
WHERE [Gold Medals] = 0 and [Silver Medals] = 0 and [Bronze Medals] != 0

-- 19. In which Sport/event, India has won highest medals.
With cte as
(Select Distinct Sport, SUM([Gold]+[Silver]+[Bronze]) OVER(PARTITION BY [Sport]) AS [Tot]
FROM (Select * From Joined_Table  WHERE region = 'India') g),

CTE2 AS (
Select *, DENSE_RANK() OVER(ORDER BY [Tot] DESC) AS rnk
From cte)

Select Sport, Tot
From CTE2
where rnk =1

-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
with cte as (
Select * From Joined_Table  WHERE region = 'India' and Sport = 'Hockey')


Select region as Team ,Sport, Games, (Sum(Gold) + SUM(Silver) + Sum(Bronze)) AS sum_Medals
from cte
GROUP BY Games, region, Sport
Order By sum_Medals desc