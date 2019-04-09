-- MYSQL HW MUBBASHEER AHMED

-- Use Sakila Database for HW
Use Sakila;

-- 1a. Display the first and last names of all actors from the table actor.
Select first_name, last_name
from actor;

-- 1b. Display first & last name actors in a single column in upper case letters. Name the column Actor Name.
Select UPPER(CONCAT(first_name, ' ', last_name)) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor with first name, "Joe."
Select actor_id, first_name, last_name
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
Select actor_id, first_name, last_name
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. Order by: last name and then first name
Select actor_id, first_name, last_name
from actor
where last_name like '%LI%'
Order by last_name asc, first_name asc;

-- 2d. Using IN, display the country_id and country columns for: Afghanistan, Bangladesh, and China:
Select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
ADD COLUMN description blob After Last_name;

-- 3b. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name)
from actor
group by last_name
having count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SET SQL_SAFE_UPDATES=0; #DISABLE SAFE MODE
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
	first_name = 'Groucho' and last_name = 'Williams';
 SET SQL_SAFE_UPDATES=1; #ENABLE SAFE MODE
 
-- 4d. If the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES=0; #DISABLE SAFE MODE
UPDATE actor 
SET 
    first_name = 'Groucho'
WHERE
	first_name = 'HARPO';
SET SQL_SAFE_UPDATES=1; #ENABLE SAFE MODE

-- 5a. Locate the schema of the address table.
Show Create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select staff.first_name, staff.last_name, address.address
from staff
INNER join address
on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
Select staff.first_name, staff.last_name, sum(amount) as 'Total Amount ($)'
from payment
INNER join staff
on payment.staff_id = staff.staff_id
where payment_date like '%2005-08%'
group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
Select film.title, count(film_actor.actor_id) as 'Actors/Film' 
from film_actor
INNER join film
on film_actor.film_id = film.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
Select film.title, count(inventory.film_id) as "Total Inventory"
from inventory
INNER join film
on inventory.film_id = film.film_id
where film.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
Select customer.first_name, customer.last_name, sum(payment.amount) as 'Total Amount ($)'
from payment
inner join customer
on payment.customer_id = customer.customer_id
group by payment.customer_id
order by customer.last_name asc;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
Select title as "Titles"
from film
where (title like 'K%' or title like 'Q%') AND language_id IN 
	(select language_id
	from language
	where name = "English"
	);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
Select first_name, last_name
from actor
where actor_id IN
    (select actor_id
	from film_actor
	where film_id IN 
		(select film_id
		from film
		where title = "Alone Trip"
		)
	);
    
-- 7c. the names and email addresses of all Canadian customers  -using joins.
select customer.first_name, customer.last_name, customer.email, city.city
from customer
Inner Join address on customer.address_id = address.address_id #get all customers living in canadian cities
Inner Join city on address.city_id = city.city_id	#get all the address with canadian cities
Inner Join country on city.country_id = country.country_id #get all the cities with canada country id
where country.country = "Canada";

-- 7d. Identify all movies categorized as family films.
Select title #film titles for family films
from film
where film_id IN
    (select film_id	#Film_id for Family films
    from film_category
    Where category_id IN
		(select category_id  #Category_id for Family
		from category
		where name = "Family"
		)
	);

-- 7e. Display the most frequently rented movies in descending order.	
select title, count(film.film_id) as 'Rental Freq'				#add up same film_ids
from film
join inventory on inventory.film_id = film.film_id				#get film id of movies that were rented based on inventory_id
join rental on rental.inventory_id = inventory.inventory_id		#get inventory_id from rental table	
group by title													#group by title
order by count(film.film_id) desc; 								#descending order by counts

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) as 'Total Revenue ($)'
from store
join staff on staff.store_id = store.store_id	
join payment on payment.staff_id = staff.staff_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
  select store.store_id, city.city, country.country
  from country
  join city on city.country_id = country.country_id
  join address on address.city_id = city.city_id
  join store on store.address_id = address.address_id;

-- 7h. List the top five genres in gross revenue in descending order.
select category.name, sum(amount) as 'Revenue $'
from category
join film_category on category.category_id = film_category.category_id
join inventory on inventory.film_id = film_category.film_id
join rental on rental.inventory_id = inventory.inventory_id
join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(amount) desc
LIMIT 5;

-- 8a. Create a View to see Top five genres by gross revenue.
CREATE VIEW Category_Revenue AS
select category.name, sum(amount) as 'Revenue $'
from category
join film_category on category.category_id = film_category.category_id
join inventory on inventory.film_id = film_category.film_id
join rental on rental.inventory_id = inventory.inventory_id
join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(amount) desc
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM Category_Revenue;

-- 8c. Write a query to delete view from 8a
DROP VIEW Category_Revenue;