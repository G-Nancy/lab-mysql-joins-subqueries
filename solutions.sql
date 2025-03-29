-- Add you solution queries below:
use sakila;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
select film.film_id,  count(inventory.inventory_id)
from film
inner join inventory
on film.film_id = inventory.film_id
where film.title = 'Hunchback Impossible'
group by film.film_id;

-- List all films whose length is longer than the average of all the films.
select film.*
from film
where length > (select avg(length) from film)
order by length asc;

select avg(length) from film; -- 115.27

-- Use subqueries to display all actors who appear in the film Alone Trip.
select *
from actor
where exists (
select actor_id 
from film_actor
inner join film
on film_actor.film_id = film.film_id
where title = 'Alone Trip'
and film_actor.actor_id = actor.actor_id);

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film.*
from film_Category
inner join Category
on film_Category.category_id = Category.category_id
inner join film
on film.film_id = film_Category.film_id
where Category.name = 'Family';

-- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select customer.first_name, customer.last_name, customer.email
from customer
inner join address
on customer.address_id = address.address_id
inner join city
on address.city_id = city.city_id
inner join country
on city.country_id = country.country_id
where country.country = 'Canada';

with country as 
(
select *
from country
where country = 'Canada'
),
city as 
(
select *
from city 
where country_id in (select country_id from country)
),
address as
(
select *
from address
where city_id in (select city_id from city)
)

select * 
from customer
where address_id in (select address_id from address);

-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
with actor as 
(
select film_actor.actor_id
from film_actor
group by film_actor.actor_id
order by count(film_actor.film_id) desc
limit 1)

select film.*
from film
inner join film_actor
on film.film_id = film_actor.film_id
where film_actor.actor_id in 
(select actor_id from actor)
;

-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
with cust as 
(
select customer_id, sum(amount) as amt
from payment
group by customer_id
order by amt desc
limit 1),
rent as
(
select inventory.*
from rental 
inner join cust
on cust.customer_id = rental.customer_id
inner join inventory
on rental.inventory_id = inventory.inventory_id
)

select film.*
from film
inner join rent 
on film.film_id = rent.film_id;

-- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
with cust as
(
select customer_id, sum(amount) as amt
from payment
group by customer_id
)

select customer_id, sum(amount) as amt
from payment
group by customer_id
having amt >
(select avg(amt)
from cust
)
order by amt asc;
