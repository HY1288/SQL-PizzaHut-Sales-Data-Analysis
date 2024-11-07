create database pizzahut;
use pizza;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );



-- BASIC:
-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;



-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(quantity * price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

 
-- 3. Identify the highest-priced pizza.
SELECT 
    name, pizza_id, price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1 , 2 , 3
ORDER BY 3 DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_details_id) AS order_counts
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY order_counts DESC
LIMIT 1;


-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    p.pizza_type_id, COUNT(*)
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 5;



-- INTERMEDIATE:
-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity)
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC;


-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY 2 DESC;


-- 8. Join relevant tables to find the distribution of pizzas on basis of category

-- (A) Distribution of pizza category
select category, count(name) from pizza_types group by category; 

-- (B) Distribution of Pizza variants (includes sizes)
select category, count(pizza_id)
from pizzas p 
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by category
order by count(pizza_id) desc;  


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(total_quantity)) from
(select order_date,sum(quantity) as total_quantity
from order_details od
join orders o on od.order_id=o.order_id
group by order_date) as order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.
select pt.name, sum(quantity*price) as total_revenue
from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on p.pizza_id=od.pizza_id
group by 1
order by 2 desc limit 3;



-- ADVANCED:
-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select pt.category, 
round(sum(quantity*price) / (SELECT SUM(quantity * price) AS total_revenue FROM order_details od JOIN pizzas p ON od.pizza_id = p.pizza_id) *100,2) as percent_share
from pizza_types pt
join pizzas p on pt.pizza_type_id=p.pizza_type_id
join order_details od on od.pizza_id=p.pizza_id
group by 1
order by 2 desc;




-- 12. Analyze the cumulative revenue generated over time.
select order_date, sum(total_revenue) over(order by order_date) as cum_revenue from
(select order_date,
sum(quantity*price) as total_revenue
from order_details od
join pizzas p on od.pizza_id=p.pizza_id
join orders o on od.order_id=o.order_id
group by order_date) as day_wise_revenue;



-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue, rank() over(partition by category order by revenue desc) as rankk from
	(select category, name, sum(quantity*price) as revenue
	from order_details od
	join pizzas p on od.pizza_id=p.pizza_id
	join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
	group by 1,2
	order by 3 desc) as a;
