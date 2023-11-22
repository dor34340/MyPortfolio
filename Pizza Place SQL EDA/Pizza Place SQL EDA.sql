Select *
From pizzas$
select *
from pizza_types$
select *
from orders$
select* 
from order_details$
select *
from Orders_Pizzas_Type

--Let's do some cleaning first

select TimeConverted,DATEPART(Hour,TimeConverted)
FROM orders$

ALTER TABLE orders$
ADD DateConverted Date
ADD TimeConverted time
UPDATE orders$ 
SET DateConverted = CONVERT(Date, date)
SET TimeConverted = convert(time, time)

--Let's try to find how many how many costumer we have each day in average:

-- Option 1:
select count(order_id)/count(distinct DateConverted)
from orders$

-- Option 2 - Using CTE:
WITH AVGCostumer AS
(
select  DateConverted,count(order_id) AS CountCos
from orders$ 
GROUP BY DateConverted
)
SELECT AVG(CountCos) AS AVGCostumer
from AVGCostumer



-- We can see that there is 59 costumer each day!

--Let's try to find how many how many Pizzas we sell each day in average:
Select Sum(quantity)/count(distinct DateConverted) as CountPizzas
FROM orders$ A join order_details$ B
ON A.order_id = B.order_id

-- We sell each day around 138 Pizzas!

-- For porpuse of inventory Stock, I would like to know how many Pizzas I should have for each day.
-- We can see that the AVG is around 138 and the STD is around 24. So the inventory stock is depend on how stringent we want to be.
-- For this calculation I used CTE in order to get vector of Sums of Pizzas per day for AVG and STD calcualtion.

WITH AVGPizzas AS
(
select  DateConverted, SUM(quantity) AS SumPizzas
FROM orders$ A join order_details$ B
ON A.order_id = B.order_id
GROUP BY DateConverted
)
SELECT AVG(SumPizzas) AS AVGPizz, STDEV(SumPizzas) AS STDPizzas
from AVGPizzas

--SELECT AVG(SumPizzas)
--From AVGPizzas

-- let's serach for peaks hour in orders and peaks hours in revenue
--Create a view for a table that we are goona use a lot.
CREATE VIEW Orders_Pizzas AS
select A.order_id, A.DateConverted, A.TimeConverted, B.order_details_id,B.pizza_id, B.quantity, C.pizza_type_id, C.size, C.price, quantity*price AS profit
FROM orders$ A join order_details$ B
ON A.order_id = B.order_id 
join pizzas$ C
On B.pizza_id = C.pizza_id


SELECT DATEPART(Hour,TimeConverted), COUNT(order_id)
From Orders_Pizzas
GROUP BY DATEPART(Hour,TimeConverted)
ORDER BY COUNT(order_id) DESC

select DATEPART(Hour,TimeConverted) AS TimeHour, ROUND(SUM(profit),2) AS Profit
from Orders_Pizzas
Group BY DATEPART(Hour,TimeConverted)
Order By Profit DESC
 

 -- We can see that 12,13,18,17 is the Busiest time, with a peak in order's quantity.
 -- The slowest hours is 9,10,23.
 -- Also we can see that accrodingly 12,13,18,17 is the most profitable hours.

SELECT DateConverted , COUNT(order_id)
From Orders_Pizzas
GROUP BY DateConverted
ORDER BY COUNT(order_id) DESC

SELECT DATENAME(WEEKDAY,DateConverted) , COUNT(order_id)
From Orders_Pizzas
GROUP BY DATENAME(WEEKDAY,DateConverted)
ORDER BY COUNT(order_id) DESC

-- The dates with the most orders are 26-27.11.2015 and 15.10.2015
-- The busiest weekday is Friday,Saturday, Thursday which corresponds with weekend's days.

SELECT DATENAME(WEEKDAY,DateConverted) AS WEEKDAY, AVG(CountOrders) AS AVGOrders, STDEV(CountOrders) STDOrders
FROM (SELECT DateConverted, COUNT(order_id) AS CountOrders
From Orders_Pizzas
GROUP BY DateConverted) AS COUNTPizzasDay
Group By DATENAME(WEEKDAY,DateConverted)
ORDER BY AVGOrders DESC

SELECT DATENAME(WEEKDAY,DateConverted) AS WEEKDAY, AVG(SumOrders) AS AVGProfit, STDEV(SumOrders) STDProfit
FROM (SELECT DateConverted, Sum(profit) AS SumOrders
From Orders_Pizzas
GROUP BY DateConverted) AS COUNTPizzasDay
Group By DATENAME(WEEKDAY,DateConverted)
ORDER BY AVGProfit DESC

-- Now we can see that the busiest days on Average is Friday, Saturday and Thursday!
-- Accorddingly, Friday, Saturday and Thursday are the most profitable days.
-- NOTE: Thursday and Friday with the largest STDEV.
-- As conclusion of the last 3 findings I would suggest to increase inventory stock for Friday, Saturday and Thursday - 
-- So I can be sure to captilized on potenial profit oppertunities.
-- For Thursday and Friday I would be more cauious with the inventory stock because of the increased STDEV.

CREATE VIEW Orders_Pizzas_Type AS
select A.order_id, A.DateConverted, A.TimeConverted, B.order_details_id,B.pizza_id, B.quantity, C.pizza_type_id, C.size, C.price, D.name, D.category, quantity*price AS profit
FROM orders$ A join order_details$ B
ON A.order_id = B.order_id 
join pizzas$ C
On B.pizza_id = C.pizza_id
join pizza_types$ D
on C.pizza_type_id = D.pizza_type_id


SELECT *
FROM Orders_Pizzas_Type

-- Best seller:
SELECT name, count(order_id) as countpizza
FROM Orders_Pizzas_Type
Group by name
order by countpizza DESC

SELECT B.name, SUM(A.countpizza) as sumcount
FROM (SELECT pizza_id,pizza_type_id, count(order_id) as countpizza
FROM Orders_Pizzas
Group by pizza_id, pizza_type_id) A JOIN pizza_types$ B
ON A.pizza_type_id = B.pizza_type_id
Group by B.name
order by sumcount DESC

SELECT pizza_id, count(order_id) as countpizza
FROM Orders_Pizzas
Group by pizza_id
order by countpizza DESC

-- We can see that the best sell pizza is the Big Meat S pizza and Thai Chicken L which sold the most time.
-- But in the types category is The Classic Deluxe Pizza and The Babeceue Chicken Pizza.

SELECT pizza_id, SUM(profit) as Revenue
FROM Orders_Pizzas_Type
GROUP BY pizza_id
Order by Revenue DESC

SELECT name, Sum(profit) as Revenue
FROM Orders_Pizzas_Type
GROUP BY name
order by Revenue DESC

-- We can see that our best seller by Revenue is the Thai Chicken L Pizza.
-- Our lease profitable is the Greek XXL Pizza.
-- I think We should consider take this pizza and Calabrese S Pizza off the menu!


SELECT size, count(order_id) AS COUNT, SUM(profit) as Revenue
From Orders_Pizzas_Type
GROUP BY size
ORDER BY COUNT DESC

select size, count(distinct order_id)/count(distinct DateConverted) AS CountOrders
From Orders_Pizzas_Type
GROUP BY size
Order by CountOrders DESC

-- We can see that if we talk about pizzas's size, we should plan in a lot of L and M pizzas and a small number of XL and XXL
-- pizzas. When the dough is ready for baking in advance - this important information. we can plan on how to destribue our preparation. 
-- For further understanging we can see that each day we need to prepare approximally:
-- 35 L, M 31, S 29, XL 2, XXL 1 pieces of dough.

--Let's look at profit per order:

select Sum(profit)/count(distinct order_id) as ProfitPerOrder
from Orders_Pizzas

-- We can see that the profit is 38.2$ per order.

Select Sum(Profit) As Total_Profit
From Orders_Pizzas_Type

-- we can see that our Yearly Revenue is 817,860$

select Month(DateConverted), Sum(profit) as MonthlyProfit
From Orders_Pizzas_Type
Group By Month(DateConverted)
Order By Sum(profit) DESC


select Month(DateConverted), Sum(profit) as MonthlyProfit
From Orders_Pizzas_Type
Group By Month(DateConverted)
Order By Month(DateConverted)
-- We can see that our best month is 11 and 1.





