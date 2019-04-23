use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) as 'Actor Names' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name='JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select concat(first_name, ' ', last_name) as 'Actor Names' from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select concat(last_name, ' ', first_name) as 'Actor Names' from actor where last_name like '%LI%' order by last_name,first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,country from country where country in ('Afghanistan', 'Bangladesh','China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries 
-- on a description, so create a column in the table `actor` named `description` and use the 
-- data type `BLOB` (Make sure to research the type `BLOB`, as the 
-- difference between it and `VARCHAR` are significant).
alter table actor add( description blob NOT NULL);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name) from actor group by last_name having count(last_name)>=2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor set first_name = 'HARPO' where last_name='WILLIAMS' and first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor set first_name = 'GROUCHO' where first_name = 'HARPO' and last_name='WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show tables like '%ADDRESS%';
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address from staff s inner join address a on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select s.first_name "First Name",s.last_name as "Last Name",sum(p.amount) as "Total Amount", date_format(p.payment_date,"%Y-%M") as "Year-Month" 
from payment p inner join staff s on s.staff_id = p.staff_id 
where date_format(p.payment_date,"%Y-%M") = "2005-August" 
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title as "Film Name",count(fa.actor_id) as "Number of Actors" 
from film f 
inner join film_actor fa on f.film_id = fa.film_id 
group by fa.actor_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select f.title as "Film Name", count(f.film_id) as "Number of Copies" 
from film f 
inner join inventory i on f.film_id = i.film_id 
where f.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name as "First Name", c.last_name as "Last Name", sum(p.amount) as "Total Amount" 
from customer c 
inner join payment p on c.customer_id=p.customer_id 
group by c.customer_id;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select fa.title as "film",l.name as "language" 
from language l,film fa 
where l.language_id = 1 
and fa.title in (select f.title from film f where f.title like 'K%' or f.title like 'Q%');

-- Alternate querying method

select fa.title as "film",l.name as "language"  
from language l 
inner join film fa on fa.title in (select f.title from film f where f.title like 'K%' or f.title like 'Q%') 
and l.language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select a.first_name as "First Name",a.last_name as "Last Name" 
from actor a,film_actor fa 
where a.actor_id = fa.actor_id 
and fa.film_id in (select f.film_id from film f where f.title = "Alone Trip");

-- Alternate querying method

select a.first_name as "First Name",a.last_name as "Last Name"  
from actor a inner join film_actor fa on a.actor_id = fa.actor_id  
and fa.film_id in (select f.film_id from film f where f.title = "Alone Trip");

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cu.first_name as "First Name",cu.last_name as "Last Name",cu.email as "Email ID" from customer cu,address ad,city ci,country co 
where cu.address_id = ad.address_id and
ad.city_id = ci.city_id and
ci.country_id = co.country_id and
co.country = 'Canada';

-- Alternate querying method

select cu.first_name as "First Name",cu.last_name as "Last Name",cu.email as "Email ID"  
from customer cu  
inner join address ad on cu.address_id = ad.address_id 
inner join city ci on ad.city_id = ci.city_id  
inner join country co on ci.country_id = co.country_id  
and co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
select f.title as "Film Name",f.description as "Description",c.name as "Category"
from film f,film_category fc,category c 
where f.film_id = fc.film_id and 
fc.category_id = c.category_id and c.name = 'Family';

-- Alternate querying method

select f.title as "Film Name",f.description as "Description",c.name as "Category" 
from film f  
inner join film_category fc on f.film_id = fc.film_id    
inner join category c  on fc.category_id = c.category_id  
and c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.title as "Film Name", count(r.rental_id) as "Rental Count" 
from film f,rental r,inventory i where i.inventory_id = r.inventory_id 
and f.film_id = i.film_id 
group by f.title 
order by count(r.rental_id) desc;

-- Alternate querying method

select f.title as "Film Name", count(r.rental_id) as "Rental Count"  
from rental r 
inner join inventory i on i.inventory_id = r.inventory_id   
inner join film f on f.film_id = i.film_id  
group by f.title  
order by count(r.rental_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select  st.store_id as "Store", sum(py.amount) as "Total (in $)"
from store st,staff stf,payment py 
where st.store_id= stf.store_id
and py.staff_id = stf.staff_id
group by st.store_id;

-- Alternate querying method

select st.store_id as "Store", sum(py.amount) as "Total (in $)" 
from store st   
inner join staff stf on st.store_id= stf.store_id 
inner join payment py on py.staff_id = stf.staff_id 
group by st.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select  st.store_id as "Store", ci.city as "City", co.country as "Country"
from store st,address ad,city ci,country co 
where st.address_id= ad.address_id 
and ad.city_id = ci.city_id  
and co.country_id =ci.country_id 
group by st.store_id;

-- Alternate querying method

select  st.store_id as "Store", ci.city as "City", co.country as "Country" 
from store st 
inner join address ad on st.address_id= ad.address_id  
inner join city ci on ci.city_id = ad.city_id 
inner join country co on co.country_id =ci.country_id  
group by st.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select  ca.name as "Genre",  sum(py.amount) as "Total revenue"
from film_category fc, category ca, inventory i, rental r, payment py
where ca.category_id= fc.category_id
and fc.film_id = i.film_id
and r.inventory_id = i.inventory_id
and py.rental_id= r.rental_id
group by ca.name 
order by sum(py.amount) desc
limit 5;

-- Alternate querying method
select  ca.name as "Genre",  sum(py.amount) as "Total revenue"
from category ca 
inner join film_category fc on ca.category_id= fc.category_id 
inner join inventory i on i.film_id = fc.film_id 
inner join rental r on r.inventory_id = i.inventory_id 
inner join payment py on py.rental_id= r.rental_id 
group by ca.name order by sum(py.amount) desc 
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genre as 
select  ca.name as "Genre",  sum(py.amount) as "Total revenue"
from film_category fc, category ca, inventory i, rental r, payment py
where ca.category_id= fc.category_id
and fc.film_id = i.film_id
and r.inventory_id = i.inventory_id
and py.rental_id= r.rental_id
group by ca.name 
order by sum(py.amount) desc
limit 5;

-- Alternate querying method
create view top_five_genre as 
select  ca.name as "Genre",  sum(py.amount) as "Total revenue"
from category ca 
inner join film_category fc on ca.category_id= fc.category_id 
inner join inventory i on i.film_id = fc.film_id 
inner join rental r on r.inventory_id = i.inventory_id 
inner join payment py on py.rental_id= r.rental_id 
group by ca.name order by sum(py.amount) desc 
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genre;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genre;



