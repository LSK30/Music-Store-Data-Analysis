create database music_data_store;
use music_data_store;

-- Creating Tables--  

CREATE table employee (employee_id int primary key,
    last_name text,
    first_name
 text,
    title
 text,reports_to
int , levels text,birthdate text,hire_data text,address text,city text,state text,country text,postal_code text,phone varchar(40),fax text,email text);
CREATE table customer (customer_id int primary key,
    first_name text,
    last_name
 text,
    company
 text,address
text , city text,state text,country text,postal_code text,phone varchar(60),fax text,email text,support_rep_id int,FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id) on update cascade on delete cascade); 
CREATE table invoice (invoice_id int primary key,
    customer_id int,
    invoice_date
 text,
    billing_address
 text,billing_city
text , billing_state text,billing_country text,billing_postal_code text,total double ,foreign key(customer_id) References customer(customer_id) on update cascade on delete cascade);
create table media_type(media_type_id int primary key,name text);
create table genre(genre_id int  primary key ,name text);
create table artist( artist_id int primary key, name text);
create table album(album_id int primary key,title text ,artist_id int,foreign key (artist_id) 
References artist (artist_id) on update cascade on delete cascade);
create table track (track_id int primary key ,name text,album_id int,media_type_id int, 
genre_id int ,composer text,milliseconds int ,bytes int ,unit_price double,foreign key (media_type_id) 
References media_type (media_type_id) on update cascade on delete cascade,
foreign key (genre_id) References genre (genre_id) on update cascade on delete cascade,
foreign key (album_id) References album (album_id) on update cascade on delete cascade);
CREATE TABLE invoice_line (invoice_line_id int primary key,
invoice_id int,
    track_id
 int,unit_price double,
    quantity
 int,foreign key (track_id) references track(track_id) ,
 foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade );
create table playlist(playlist_id int primary key primary key ,name text);
create table playlist_track(playlist_id int, track_id int,foreign key (playlist_id) 
References playlist (playlist_id) on update cascade on delete cascade,
foreign key (track_id) References track (track_id) on update cascade on delete cascade);

-- Major Task --
-- •	Who is the senior most employee based on job title?
select first_name , last_name,title  from employee order by levels desc limit 1; 

-- •	Which countries have the most Invoices?
select billing_country ,count(billing_country) as c from invoice group by billing_country order by c desc limit 1 ;

-- •	What are top 3 values of total invoice?
select total from invoice order by total desc limit 3;

-- • 	Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals
select billing_city , sum(total) as t from invoice group by billing_city order by t desc limit 1;

-- •	Write a query that returns the person who has spent the most money
select c.first_name , c.last_name , sum(total) as `most money spent` from customer as c inner join invoice as i 
on c.customer_id = i.customer_id group by c.customer_id order by  `most money spent` desc limit 1;

-- MODERATE --

-- •	Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
select distinct(c.email) , c.first_name , c.last_name from customer as c inner join invoice as i on 
c.customer_id = i.customer_id inner join invoice_line as l on i.invoice_id = l.invoice_id inner join 
track as t on l.track_id = t.track_id inner join genre as g on t.genre_id = g.genre_id  
where g.name = "Rock"  order by c.email asc; 

-- •	 Write a query that returns the Artist name and total track count of the top 10 rock bands
select `Artist Name`,count(ct) as `Total Track` from (select a.name as `Artist Name`, t.name  as ct from track as t
  inner join genre as g ON t.genre_id = g.genre_id
  inner join album as  al ON al.album_id = t.album_id
  inner join artist as a ON a.artist_id = al.artist_id
  where g.name='Rock') as r group by `Artist Name`  order by `Total Track`  desc;
  


-- •	Return all the track names that have a song length longer than the average song length. Return the Name and 
-- Milliseconds for each track. Order by the song length with the longest songs listed first
select name,milliseconds  from track where milliseconds >(select avg(milliseconds) as avg_song_length
from track) order by milliseconds desc; 



-- Advanced --


-- •	Find how much amount spent by each customer on artists? Write a query to return customer name, 
-- artist name and total spent 

 select * from (select customer.customer_id,customer.first_name,customer.last_name,sa.artist_name,sum(il.unit_price*il.quantity) 
 as amount_spent from invoice i join customer  on customer.customer_id = i.customer_id  join  invoice_line  as il on il.invoice_id=i.invoice_id join track  t on  t.track_id = il.track_id join album as a on a.album_id = t.album_id  
 join (select b.artist_id as artist_id ,b.name as artist_name , sum(i.unit_price *i.quantity) as total_spent from invoice_line as i
 join track as t on t.track_id = i.track_id join album as a on a.album_id = t.album_id join artist as b on b.artist_id=a.artist_id 
 group by 1 order by 3  desc )  as sa  on sa .artist_id = a.artist_id group by 1,2,3,4 ) as k order by first_name desc;

-- •	We want to find out the most popular music Genre for each country. We determine the most popular 
-- genre as the genre with the highest amount of purchases. Write a query that returns each country along 
-- with the top Genre. For countries where the maximum number of purchases is shared return all Genres

select billing_country ,name, (purchase_amount) from (select i.billing_country,g.name ,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from invoice as i  inner join invoice_line as il using(invoice_id) inner join track as t using(track_id)
 inner join genre as g using(genre_id) group by i.billing_country,g.name) as cte where a =1;

-- •	Write a query that determines the customer that has spent the most on music for each country.
--  Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

select  billing_country,customer_id,purchase_amount  from (select i.billing_country,c.customer_id,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc) as a
from customer as c inner join  invoice as i using(customer_id)  group by i.billing_country,c.customer_id) as cte where a =1;