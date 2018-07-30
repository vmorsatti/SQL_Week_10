-- Homework Assignment - SQL 
-- Authored by Verna Orsatti

-- Database = Sakila
Use sakila;

-- 1a. Display the first and last names of all actors from the table  'actor'.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column 'Actor Name'
SELECT CONCAT(UPPER(first_name), " ", UPPER(last_name)) as 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contains the letters GEN:
SELECT first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters 'LI'. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY 1,2;

-- 2d. Using 'IN', display the 'country_id' and 'country' columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a 'middle_name' column to the table 'actor. Position it between 'first_name' and 'last_name'. 
-- Hint:  you will need to specify the data type.
 
ALTER TABLE actor 
	ADD COLUMN middle_name VARCHAR(45) NOT NULL
		AFTER first_name;
        
SELECT	* FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names.  
-- Change the data type of the 'middle_name' column to 'blob'.
ALTER TABLE actor
	MODIFY COLUMN  middle_name  BLOB;
    
SELECT	* FROM actor;

-- 3c. Now delete the 'middle_name' column.
ALTER TABLE actor
	DROP COLUMN	middle_name;
    
SELECT	* FROM actor;
 
 -- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)
FROM actor
GROUP BY 1
ORDER BY 2 DESC;
 
 -- 4b. List last names of actors and the number of actors who have that last name,
 -- but only for names that are shared by at least two actors
SELECT * FROM(
	SELECT last_name, count(*) as last_name_count
    FROM actor
	GROUP BY 1
	ORDER BY 1 
 ) as t
 WHERE t.last_name_count > 1;
  
 -- 4c. Oh, no! The actor 'HARPO WILLIAMS' was accidentally entered in the 'actor' table as 'GROUCHO WILLIAMS'
 -- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
 
 UPDATE actor
 SET first_name = "HARPO"
 WHERE last_name = "WILLIAMS" AND first_name = "GROUCHO";
 
-- TEST FILE
SELECT * FROM actor
	WHERE last_name = 'Williams';
     
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, 
-- HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
    SET first_name  = (
		CASE
			WHEN first_name IN ("HARPO") THEN "GROUCHO"
			ELSE "MUCHO GROUCHO"
            END
	)
    WHERE
        actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
--  	Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
-- 
SELECT s.first_name, s.last_name, a.address
FROM staff s
	LEFT JOIN address a ON s.address_id = a.address_id;

-- Verna's Self Made BONUS point is to add the city table !
SELECT s.first_name, s.last_name, a.address, c.city
FROM address a
	JOIN city c ON c.city_id = a.city_id
	RIGHT JOIN staff s ON s.address_id = a.address_id;
    

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) 
FROM payment p
	JOIN staff s ON p.staff_id = s.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY 1,2;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner

SELECT f.title , COUNT(fa.actor_id) as `Number of Actors`
FROM film_actor fa
	INNER JOIN film f  ON fa.film_id= f.film_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(*)
FROM inventory i
	JOIN film f ON i.film_id = f.film_id
WHERE f.title = "Hunchback Impossible";


-- 6e. Using the tables: payment and customer and the JOIN command,
-- list the total paid by each customer. List the customers alphabetically by last name:
-- 
SELECT c.first_name, c.last_name, sum(p.amount) as `Total Paid`
	FROM customer c
		JOIN payment p ON c.customer_id= p.customer_id
GROUP BY 1,2
ORDER BY 2;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM(
	SELECT f.title,   l.name
	FROM film f 
		JOIN language l on f.language_id = l.language_id
) as t WHERE t.name = "English" and (LEFT(t.title,1) = 'K' OR LEFT(t.title,1) = 'Q');

-- Verna's optional BONUS way to do the same without queries!
SELECT f.title, l.name as 'language'
FROM film f
	JOIN language l on f.language_id = f.language_id
WHERE l.name = "English" and (LEFT(f.title,1) = 'K' OR LEFT(f.title,1) = 'Q');


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *FROM(
	Select a.first_name, a.last_name, f.title
	from film_actor fa
		 Join actor a ON fa.actor_id = a.actor_id
		 Join film f ON fa.film_id = f.film_id
 ) as t where t.title = "Alone Trip";


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.
Select c.first_name, c.last_name, c.email, cn.country
FROM customer c
	JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country cn ON ci.country_id = cn.country_id
WHERE cn.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT f.title, c.name as 'category'
FROM film_category fc
	JOIN film f ON f.film_id = fc.film_id
    JOIN category c ON c.category_id = fc.category_id
WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.film_id) as 'rented'
FROM rental r
	JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
GROUP BY 1
ORDER by 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;

SELECT s.store_id as Store, SUM(amount) as Gross_Amt
FROM payment p
	JOIN staff st ON p.staff_id = st.staff_id
    JOIN store s ON st.store_id = s.store_id
GROUP BY 1;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country
FROM store s
	JOIN address a ON s.address_id = a.address_id
    JOIN city c ON a.city_id = c.city_id
    JOIN country cn ON c.country_id = cn.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category,
-- inventory, payment, and rental.)
SELECT c.name as 'Top 5 Genre', SUM(p.amount) as 'Gross Revenue'
FROM payment p
	JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.


CREATE VIEW top5_genre_revenue AS
SELECT c.name as 'Top 5 Genre', SUM(p.amount) as 'Gross Revenue'
FROM payment p
	JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;



-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genre_revenue;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top5_genre_revenue;


-- missing tables: actor_info, customer_list, film_list, nicer_but_slower_film_list, sales_by_store,
-- 							sales_by_store, staff_listaddress`PRIMARcityfilm_idfilm_id

