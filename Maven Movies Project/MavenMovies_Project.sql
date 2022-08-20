                                                             /* Maven Movies Project */

/* 
We will need a list of all staff members, including their first and last name,
email adresses, and the store identification number where they work
*/

SELECT 
	first_name,
    last_name,
    email,
    store_id
FROM staff;

/*  We will need separate counts of inventory items held at each of your two stores */

SELECT 
	store_id,
    COUNT(inventory_id) as Number_of_items
FROM inventory 
GROUP BY store_id;

/* We will need a count of active customers for each of your stores. Separately, please */

SELECT 
	store_id as Store,
    count(customer_id) as Number_of_active_customer
FROM customer
WHERE active=1 
GROUP BY store_id;

/* In order to asses the liability of a data breach, we will need you to provide 
a count of all customer email adresses stored in the database */

select 
	count(email) as Number_of_email
FROM customer;

/*
We are interested in how diverse your film offering is as a means of understanding how likely you are to keep customers engaged in the future
Please provide a count of unique film title you have in inventory at each store
and then provide a count of the unique categories of films you provide
*/

SELECT 
	store_id,
    count(DISTINCT film_id) as Count_of_films
FROM inventory 
GROUP BY 
	store_id;

Select 
	COUNT(DISTINCT category_id) AS Count_of_categories
FROM category;

/*
We would like to understand the replacement cost of your films.
Please provide the replacement cost for the film that is least expensive to replace,
the most expensive to replace, and the average of all films you carry
*/

Select 
	MIN(replacement_cost) AS Min_Replacement_Cost,
    MAX(replacement_cost) AS Max_Replacement_Cost,
    AVG(replacement_cost) AS Avg_Replacement_Cost
FROM film;


/* 
We are interested in having you put payment monitoring systems and maximum payment processing restrictions
in place in order to minimize the risk of fraud by your staff.
Please provide the average payment you process, as well as the maximum payment you have processed 
*/

Select
	AVG(amount) AS Average_payment,
    MAX(amount) AS MAX_payment
from payment;

/*
We would like to better understand what our customer base looks like. Please provide a list of all customer identification values,
with a count of rentals they have made all-time, with your highest volume customers at the top of the list
*/

SELECT
	customer_id,
    count(rental_id) AS Number_of_rentals
FROM rental
GROUP BY 
	customer_id
ORDER BY 
	count(rental_id) DESC;
    

/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 

SELECT
	staff.store_id AS Store,
	staff.first_name AS Manager,
    address.address AS Adress,
    address.district AS District,
    city.city AS City,
    country.country AS Country
FROM store
	LEFT JOIN staff
		ON store.manager_staff_id=staff.staff_id
	LEFT JOIN address
		ON store.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id = city.city_id
	LEFT JOIN country
		ON city.country_id = country.country_id;
        
        
    
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/


SELECT
	inventory.inventory_id,
    inventory.store_id,
    film.title AS Name_of_film,
    film.rating,
    film.rental_rate,
    film.replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id;
    
    
/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/


SELECT
    inventory.store_id,
    film.rating,
    COUNT(inventory_id) AS inventory_items
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
GROUP BY 
	inventory.store_id,
    film.rating;
    





/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 


SELECT

	inventory.store_id AS Store,
    category.name AS Film_category,
    COUNT(inventory_id) AS Number_of_films,
    AVG(film.replacement_cost) AS Average_replacement_cost,
    SUM(film.replacement_cost) AS Total_replacement_cost
    
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
	LEFT JOIN film_category
		ON film.film_id = film_category.film_id
	LEFT JOIN category
		ON film_category.category_id = category.category_id
        
GROUP BY
	Store,
    Film_category
    
ORDER BY Total_replacement_cost DESC;
    


/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/


SELECT
	customer.first_name,
    customer.last_name,
    customer.store_id AS Store,
    customer.active,
    address.address,
    city.city,
    country.country
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id = city.city_id
	LEFT JOIN country
		ON city.country_id = country.country_id;
        

/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

SELECT
	customer.first_name,
    customer.last_name,
    COUNT(rental.rental_id) AS Total_rentals,
    SUM(payment.amount) AS Total_payments
FROM customer
	LEFT JOIN payment
		ON customer.customer_id =payment.customer_id
	LEFT JOIN rental
		ON payment.rental_id =rental.rental_id
GROUP BY
	customer.first_name,
    customer.last_name
ORDER BY 
	 Total_payments DESC;

    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/


SELECT 
	'Investor' AS type,
    first_name,
    company_name
FROM investor

UNION

SELECT 
	'Advisor' AS type,
	first_name,
    NULL
FROM advisor;


/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/

SELECT
	CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
		WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony','Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END AS number_of_awards,
    AVG( CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS Percentage_with_1_film
FROM actor_award

GROUP BY
	(CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
		WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony','Oscar, Tony') THEN '2 awards'
        ELSE '1 award' 
        END)
	