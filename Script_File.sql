/* Requirement Set 1 */

/* 1: Who is the senior most employee based on job title? */

SELECT 
    first_name, last_name, title
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

/* 2: Which countries have the most Invoices? */

SELECT 
    COUNT(invoice_id) AS invoive_count, billing_country
FROM
    invoice
GROUP BY billing_country
ORDER BY invoive_count DESC
LIMIT 10;

/* 3: What are top 3 values of total invoice? */

SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;

/* 4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select * from invoice;

SELECT 
    billing_city, SUM(total) AS total_value
FROM
    invoice
GROUP BY billing_city
ORDER BY total_value DESC
LIMIT 1;

/* 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(i.total) AS total_spent
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id , c.first_name , c.last_name
ORDER BY total_spent DESC
LIMIT 1;

/* Requirement Set 2 */

/* 1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT
    c.email, c.first_name, c.last_name
FROM
    customer c
        JOIN
    invoice i ON c.customer_id = i.customer_id
        JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
        JOIN
    track t ON il.track_id = t.track_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.`name` = 'Rock'
ORDER BY c.email;

/* 2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select * from artist;
select * from album;
select * from track;
select * from genre;

SELECT 
    a.artist_id, a.`name`, COUNT(a.artist_id) AS total_song
FROM
    artist a
        JOIN
    album al ON a.artist_id = al.artist_id
        JOIN
    track t ON al.album_id = t.album_id
        JOIN
    genre g ON t.genre_id = g.genre_id
WHERE
    g.`name` = 'Rock'
GROUP BY a.artist_id , a.`name`
ORDER BY total_song DESC
LIMIT 10;

/* 3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT 
    `name`, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_length
        FROM
            track);

/* Requirement Set 3 */

/* 1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve:
Identify the Best-Selling Artist. Retrieve Customer Purchase Information for the Best-Selling Artist. */

WITH best_selling AS (
    SELECT a.artist_id, a.`name`, SUM(il.unit_price * il.quantity) AS total_sales
    FROM artist a
    JOIN album al ON a.artist_id = al.artist_id
    JOIN track t ON al.album_id = t.album_id
    JOIN invoice_line il ON t.track_id = il.track_id
    GROUP BY a.artist_id, a.`name`
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bs.`name`, SUM(il.unit_price * il.quantity) AS amount_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN best_selling bs ON bs.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bs.`name`
ORDER BY amount_spent DESC;

/* 2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH popular_genre AS (
    SELECT g.genre_id, g.`name`, i.billing_country, COUNT(il.quantity) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS row_num
    FROM genre g
    JOIN track t ON g.genre_id = t.genre_id
    JOIN invoice_line il ON t.track_id = il.track_id
    JOIN invoice i ON il.invoice_id = i.invoice_id
    GROUP BY g.genre_id, g.`name`, i.billing_country
)
SELECT * FROM popular_genre WHERE row_num = 1;

/* 3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH customer_with_country AS (
    SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(i.total) AS total_spent,
           ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS row_num
    FROM invoice i
    JOIN customer c ON i.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT * FROM customer_with_country WHERE row_num = 1;