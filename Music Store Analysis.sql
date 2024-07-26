select * from album;

--1. Who is the senior most employee based on job title?
select Top 1 * from employee
order by levels desc

--2. Which countries have the most Invoices?
select count(*) as most_invoices, billing_country
from invoice
group by billing_country
order by most_invoices desc

-- 3. What are top 3 values of total invoice?
select top 3 total from invoice
order by total desc

/*4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/

select top 1 billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc


/*5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/

 select c.customer_id,c.first_name, c.last_name, sum(i.total) as total_spent
 from customer as c
 join invoice as i
 on c.customer_id = i.customer_id
 group by  c.customer_id,c.first_name, c.last_name
 order by total_spent desc


 /*6. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/

select DISTINCT c.email, c.first_name, c.last_name
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
where track_id IN
( SELECT track_id FROM track
  JOIN genre ON track.genre_id = genre.genre_id
  where genre.name LIKE 'Rock'
)
order by email

/*7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands */

select TOP 10 ar.artist_id, ar.name, count(ar.artist_id) as number_of_songs
from artist as ar
join album as a on ar.artist_id = a.artist_id
join track as t on a.album_id = t.album_id
where track_id IN
( SELECT track_id FROM track
  JOIN genre ON track.genre_id = genre.genre_id
  where genre.name LIKE 'Rock'
)
group by ar.artist_id, ar.name
order by number_of_songs desc


/*8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

SELECT name, Milliseconds
FROM track
where milliseconds > (Select AVG(milliseconds) as avg__Track_length from track)
order by Milliseconds desc

/*9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice i
JOIN 
    customer c ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album alb ON alb.album_id = t.album_id
JOIN 
    artist a ON a.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, a.name
ORDER BY 
    amount_spent DESC;


/*10. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres */

WITH popular_genre AS 
(
    SELECT 
        customer.country, 
        genre.name AS genre_name, 
        COUNT(invoice_line.quantity) AS purchases,
        RANK() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RankNo
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name

)
SELECT country, genre_name, purchases 
FROM popular_genre 
WHERE RankNo = 1;

/* 10. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount */WITH customer_with_country AS (
    SELECT 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
        i.billing_country AS country, 
        SUM(i.total) AS total_spending,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS RankNo
    FROM customer AS c
    JOIN invoice AS i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT 
    country, 
    customer_id, 
    first_name, 
    last_name, 
    total_spending 
FROM 
    customer_with_country 
WHERE 
    RankNo = 1;
