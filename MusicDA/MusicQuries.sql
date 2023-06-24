--Q.1 Who is senior most employee based on job title?
-- The senior most employee reports to no one
select first_name, last_name
from employee
where reports_to is null;
-- The sernior most employee has the highest level
select first_name, last_name
from employee
order by levels desc
limit 1;

--Q.2 Which contries have the most invoices?
--We will group by billing countries
select billing_country, count(*) as country_count
from invoice
group by billing_country
order by country_count desc;

--Q.3 What are top 3 values of total in invoice?
--Sort total and limit 3
select total
from invoice
order by total desc
limit 3;

--Q.4 Which city has the best customers?
/*We would like to throw a promotional music festival in the city we made the most money.
Write a query that returns that top city which has the higest some of invoice totals.
Return both city and sum of all invoice totals*/
select billing_city, sum(total) as Total
from invoice
group by billing_city
order by Total desc
limit 1;

--Q.5 Who is the best customer?
--The customer who has spent most money will be declared best customer
select ct.first_name, ct.last_name, sum(iv.total) as total_spent
from invoice iv
left join customer ct
on ct.customer_id = iv.customer_id
group by ct.first_name, ct.last_name
order by total_spent desc
limit 1;

--Q.6 Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.
select distinct ct.first_name, ct.last_name, ct.email
from customer ct
join invoice iv on ct.customer_id=iv.customer_id
join invoice_line ivl on iv.invoice_id=ivl.invoice_id
join track tk on tk.track_id = ivl.track_id
join genre gn on gn.genre_id = tk.genre_id
where gn.name='Rock'
order by ct.email;
--optimize this one

--Q.7 Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands.
select ar.name, count(*) as track_count
from artist ar 
join album ab on ab.artist_id =  ar.artist_id
join track tr on tr.album_id = ab.album_id
join genre gn on gn.genre_id = tr.genre_id
where gn.name like 'Rock'
group by ar.name
order by track_count desc
limit 10;

--Q.8 Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds)
	from track)
order by milliseconds desc;

--Q.9 Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent
select ct.first_name, ct.last_name, ar.name,  sum(ivl.unit_price*ivl.quantity) as total_expenditure
from artist ar 
join album ab on ab.artist_id =  ar.artist_id
join track tr on tr.album_id = ab.album_id
join invoice_line ivl on ivl.track_id = tr.track_id
join invoice iv on iv.invoice_id = ivl.invoice_id
join customer ct on ct.customer_id = iv.customer_id
group by ar.name, ct.first_name, ct.last_name
order by total_expenditure desc ;
--understand your data
--take repeatations of sum, avg, count into account after joining
--optimize thid one: cause we need breakdown of highest selling artist in relation with customer: NO WE DON'T
--not the highest cuustomer-artist relationship
--looking at his solution where the output is only 43 lines it seems impossible for me to assume
--that there will be only 43 relationships, those could be between customers and top selling artist
--adding where ar.name like 'Queen' to above proves my assumption just right
--no need to optimize the query

--Q.10 We want to find out the most popular music Genre for each country (using count of albums sold)
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre.
--For countries where the maximum number of purchases is shared return all Genres.
--COULDN'T DO THIS ONE

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo --Quite difficult to grasp 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

--method 2: difficult to grasp as well. why two tables?
WITH RECURSIVE --why this?
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country --this is the tricky part
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



--Q.11 Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.
--COUNDN'T DO IT
--follows same as above
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



/* Method 2: Using Recursive */

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
