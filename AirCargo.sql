create database AirCargo;
use AirCargo;

-- Creating 4 tables for database (customer, pof, routes, ticket_details) and inserting data using import wizard.
drop table if exists customer;
CREATE TABLE if not exists customer (
  customer_id int,
  first_name varchar(100) NOT NULL,
  last_name varchar(100) DEFAULT NULL,
  date_of_birth date NOT NULL,
  gender varchar(1) NOT NULL,
  PRIMARY KEY (customer_id),
  CONSTRAINT Gender_check CHECK ((gender in ('M','F','O')))
);


describe customer;


##Q2. Write a query to create route_details table using suitable data types for the fields, such as route_id, 
#flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. Implement the check constraint for 
#the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0.
CREATE TABLE routes (
  route_id int NOT NULL,
  flight_num int NOT NULL,
  origin_airport varchar(3) NOT NULL,
  destination_airport varchar(100) NOT NULL,
  aircraft_id varchar(100) NOT NULL,
  distance_miles int NOT NULL,
  PRIMARY KEY (route_id),
  CONSTRAINT Flight_number_check CHECK ((substr(flight_num,1,2) = 11)),
  CONSTRAINT routes_chk_1 CHECK ((distance_miles > 0))
);

CREATE TABLE pof (
  customer_id int NOT NULL,
  aircraft_id varchar(100) NOT NULL,
  route_id int NOT NULL,
  depart varchar(3) NOT NULL,
  arrival varchar(3) NOT NULL,
  seat_num varchar(10) DEFAULT NULL,
  class_id varchar(100) DEFAULT NULL,
  travel_date date DEFAULT NULL,
  flight_num int NOT NULL,
  KEY customer_id (customer_id),
  KEY route (route_id),
  CONSTRAINT pof_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
  CONSTRAINT pof_ibfk_2 FOREIGN KEY (route_id) REFERENCES routes (route_id) 
);



CREATE TABLE ticket_details (
  p_date date NOT NULL,
  customer_id int NOT NULL,
  aircraft_id varchar(100) NOT NULL,
  class_id varchar(100) DEFAULT NULL,
  no_of_tickets int DEFAULT NULL,
  a_code varchar(3) DEFAULT NULL,
  Price_per_ticket int DEFAULT NULL,
  brand varchar(100) DEFAULT NULL,
  KEY customer_id (customer_id),
  CONSTRAINT ticket_details_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

#show global variables like 'local_infile';
#SET GLOBAL local_infile=ON;
#load data local infile 'F:/DATA-SCIENTIST-COURSE-MATERIAL/My SQL/AirCargo-data/ticket_details.csv' into table ticket_details
#>>FIELDS TERMINATED BY ','
#>>LINES TERMINATED BY '\n'
#>>IGNORE 1 LINES;


TRUNCATE TABLE pof;

select *from customer;
select *from routes;
select *from pof;
select *from ticket_details;

##Q1.Create an ER diagram for the given airlines database



##Q3. Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data 
# from the passengers_on_flights table.

select customer_id from pof
where route_id between 1 and 25;

##4.Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.

select count(customer_id) as number_of_passengers ,sum(Price_per_ticket*no_of_tickets) as revenue from ticket_details
#where class_id='Bussiness';
group by (class_id)
having class_id='Bussiness';

#5.	Write a query to display the full name of the customer by extracting the first name and last name from the customer table.

select concat(first_name,' ',last_name) as full_name from customer;

#6.	Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.
 
select distinct c.customer_id, c.first_name, c.last_name
from customer c
join ticket_details t using (customer_id)
where no_of_tickets = 1 
order by c.customer_id desc;

#? 7.Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) 
#from the ticket_details table.

select c.customer_id, c.first_name, c.last_name from customer c
join ticket_details t using (customer_id)
where brand='Emirates'
order by c.customer_id desc;

#8?.	Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the
# passengers_on_flights table.

select c.customer_id, c.first_name, c.last_name, p.class_id
from customer c
join pof p using (customer_id)
group by c.customer_id
having p.class_id = 'Economy plus'
order by c.customer_id;

#9.	Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.

select *from ticket_details;
select if(sum(no_of_tickets*Price_per_ticket) >10000,'Revenue Crossed 10000', 'Revenue less than 10000') as revenue_status from ticket_details;

#10.Write a query to create and grant access to a new user to perform operations on a database

#11.Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.

select *from ticket_details;
select distinct class_id, brand, max(Price_per_ticket) over (partition by brand order by class_id) as max_tkt_pr
from ticket_details; 

# this means that I want to select class_id,brand and max_ticket price of each of the class_id from each of the brand
#in short for every airways , I have got the maximum ticket price for each of their class

#12.Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.

select *from pof;
select customer_id from pof
where route_id=4;

#For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

#13.For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

select *from pof where route_id=4;

#14.	Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.

##The ROLLUP in MySQL is a modifier used to produce the summary output, including extra rows that represent 
#super-aggregate (higher-level) summary operations. It enables us to sum-up the output at multiple levels of analysis using a single query. 
#It is mainly used to provide support for OLAP (Online Analytical Processing) operations.

select *from ticket_details;

select a_code,sum(Price_per_ticket*no_of_tickets) as total_price from ticket_details
group by a_code with rollup;

#15.	Write a query to create a view with only business class customers along with the brand of airlines.
create view first_class as
select customer_id, class_id from ticket_details
where class_id='Bussiness';

select * from first_class;

#16.Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. 
#Also, return an error message if the table doesn't exist.

select * from pof;
select * from customer where customer_id in (select customer_id from pof where route_id in (1,5)) 
#this is selecting the details of the customers from customer table who has taken the route 1 to 5 mentioned in table pof

delimiter &&
CREATE PROCEDURE check_route(in rid varchar(255))
BEGIN
DECLARE TableNotFound condition for 1146;
declare exit handler for TableNotFound
select 'Please check if table customer/route_id are created-
one/both missing' Message;
set @query=concat('select * from customer where customer_id in (Select distinct customer_id from pof where route_id in (',rid,'));');
#Sometimes, there is a need to add the element into an existing SET column, then a CONCAT() function allows us to insert a new element in the comma-separated list.
prepare sql_query from @query;
execute sql_query;
END &&
delimiter ;;
call check_route("1,5");



## 17.	Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance
# is more than 2000 miles

select *from routes;

delimiter &&
CREATE PROCEDURE travel_dist()
BEGIN
select *from routes where distance_miles >2000;
END &&
delimiter ;;

call travel_dist();

##18.	Write a query to create a stored procedure that groups the distance travelled by each flight into 
#three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles,
#intermediate distance travel (IDT) for >2000 AND <=6500,and long-distance travel (LDT) for >6500.

DELIMITER // 
 CREATE Function flight_time(dist int)
 returns varchar(30)
 BEGIN
 DECLARE Distance varchar(30)  ;
 IF dist between 0 AND 2000  THEN
 SET Distance = 'Short';
 ELSEIF dist between 2000 AND 6500 Then
 SET Distance = 'Intermediate';
 ELSEIF dist >6500 Then
 SET Distance = 'Long';
 END IF;
 return (Distance);
 END //
 
 
 create procedure flight_time_proc()
 Begin
  Select flight_num,origin_airport, distance_miles, flight_time(distance_miles) as distance_covered from routes;
  End //
  DELIMITER ;;
 
 call flight_time_proc();
  
  #19.Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are
  #provided for the specific class using a stored function in stored procedure on the ticket_details table.
  
 drop function  commodity;
 DELIMITER $$ 
 CREATE Function commodity(class varchar(30))
 returns varchar(30)
 deterministic
 BEGIN
 DECLARE Response varchar(30)  ;
 IF class='Bussiness' then
 SET Response = 'Yes';
 ELSEIF class='Economy Plus' then
 SET Response = 'Yes';
 ELSE 
 SET Response = 'No';
 END IF;
 return (Response);
 END $$
 
 
 create procedure commodity_proc()
 Begin
  Select p_date,customer_id, class_id, commodity(class_id) as extra_service from ticket_details;
  End $$
  DELIMITER ;;
 
 call commodity_proc();
 
## 20. Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.

select *from customer;

 