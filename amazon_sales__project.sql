create database amazon_sales; 
use amazon_sales;
CREATE TABLE sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT(6,4) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(11,9) NOT NULL,
    gross_income DECIMAL(10,2) NOT NULL,
    rating FLOAT(2,1) NOT NULL
); 
-- created a table named sales using amazon sales database and added all coloumns requred for sales analysis used not null to restrict 
-- null values in to the data and imported values in to respected coloumns from csv file 

alter table sales                             -- alter used to add new column to the sales table 
add column time_of_day varchar(15);  


set sql_safe_updates=0; -- sql safe updates =0 allows you to perform updates in table 
update sales 
set time_of_day =        -- case statement is used to decide wether morning or evening based on time 
case
	when time(time)>= '00:00:00' and  time(time) <'12:00:00' then 'Morning'
    when time(time)>='12:00:00' and  time(time) < '18:00:00' then 'Afternoon'
    else 'Evening' 
end ;

alter table sales                      -- added new column day_name to sales data 
add column day_name varchar(15); 

set sql_safe_updates =0 ; 
update sales 
set day_name = dayname(date(date));           -- used dayaname function to extract name of day from date column

alter table sales 
add column month_name varchar(15);         -- added month_name new column to sales table

set sql_safe_updates =0 ;
update sales 
set month_name = monthname(date);         -- monthname function is used to extract name of month from date column

/*1) What is the count of distinct cities in the dataset?*/  
select  city,count(distinct city) as city_name from sales 
group by city ;    -- aggregate func count used to count unique cities in sales data

/* 2)For each branch, what is the corresponding city? */ 
select distinct branch,city from sales ;  -- unique branch is displayed respective to cities 


/* 3)What is the count of distinct product lines in the dataset?  */ 
select product_line,count(distinct product_line) as product_line from sales 
group by product_line;    -- gives count and  distinct product lines in sales data by groupping product_line


/* 4)Which payment method occurs most frequently?  */ 
select payment_method,count(payment_method) as frequent_payment_count 
from sales 
group by payment_method 
order by frequent_payment_count desc 
limit 1;     -- counts which payment method are frequently used by costumers sorting count of the methods in descending order and values limits to one

/* 5) Which product line has the highest sales? */ 
select product_line,sum(quantity) as highest_sales
from sales 
group by product_line 
order by highest_sales desc 
;                 -- count the which product line has high sales using order by clause 

/* 6) How much revenue is generated each month? */ 
select distinct month_name,sum(total) as revenue 
from sales 
group by month_name 
order by revenue desc;    -- sums the total revenue generated for each month by groupping month_name 

/* 7)In which month did the cost of goods sold reach its peak? */ 
select month_name,max(cogs) as high_cogs 
from sales 
group by month_name 
order by high_cogs desc 
limit 1;     -- selects the month has the peak cogs using max function limits to high value 

/* 8)Which product line generated the highest revenue?  */ 
select product_line,sum(total) as highest_revenue 
from sales 
group by product_line 
order by highest_revenue desc 
limit 1;   -- selects productline and sums the total sale revenue and groups the productline sorts highest_revenue in desc order

/*9)  In which city was the highest revenue recorded?   */  
select city,sum(total) as highest_revenue from sales 
group by city 
order by highest_revenue desc 
limit 1 ;   -- selects the city and sums the total revenue groups the city name sort the highest value using limit

/* 10)Which product line incurred the highest Value Added Tax? */  
select distinct product_line,sum(vat) as highest_vat from sales 
group by product_line 
order by highest_vat desc 
limit 1;  -- selects the product line and sums the vat groups the productline

/* 11)For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." */  
-- Step 1: Define a Common Table Expression (CTE) to calculate the average total sales
WITH cte AS (
    SELECT AVG(total) AS average_sales
    FROM sales
)

-- Step 2: Select product line, total sales, average sales, and classify sales as 'good' or 'bad'
SELECT 
    product_line, -- Select the product line
    SUM(total) AS total_sales, -- Calculate the total sales for each product line
    cte.average_sales, -- Include the average sales from the CTE
    CASE 
        WHEN SUM(total) > cte.average_sales THEN 'good' -- Classify as 'good' if total sales are above average
        ELSE 'bad' -- Classify as 'bad' if total sales are below average
    END AS sales_type -- Alias for the classification result
FROM 
    sales, cte -- Use the sales table and the CTE
GROUP BY 
    product_line, cte.average_sales; -- Group by product line and average sales


/* 12) Identify the branch that exceeded the average number of products sold. */ 
set @avg_sales= (select avg(total) as average from sales) ;  -- avg of total cost stored in avg_sales
select branch,sum(total) as branch_sales from sales 
group by branch 
having branch_sales>@avg_sales ;  -- select which branch has more sales than avg sales 


/* 13)Which product line is most frequently associated with each gender? */ 
select product_line ,gender,count(gender) as frequently_ass_gender 
from sales 
group by product_line ,gender
order by frequently_ass_gender desc ; -- selects the productline and counts which gender has mostly assosiated sorting in desc



/* 14) Calculate the average rating for each product line.*/ 
select product_line,avg(rating) as average_rating from sales
group by product_line 
order by average_rating desc; -- selects the product line and fins avg using avg() func sorts in desc order

/*15) Count the sales occurrences for each time of day on every weekday.*/
select time_of_day,count(*) as sale_occurences 
from sales 
group by time_of_day 
order by sale_occurences desc;  -- counts the sale that occurs in time of day and sorted the count values

/*16) Identify the customer type contributing the highest revenue.*/
select customer_type , sum(total) as highest_revenue from sales 
group by customer_type 
order by highest_revenue desc 
limit 1;  -- lists the total revenue spent by which customer type and sorts the order limita to 1 value using limit 

/* 17) Determine the city with the highest VAT percentage. */ 
select city ,(sum(vat)/sum(total))*100 as highest_vat_percentage
from sales 
group by city 
order by highest_vat_percentage desc 
limit 1 ;  -- didviding by total of vat and total cost * 100 to obtain percentage respective to city sorts in desc order 

/* 18) Identify the customer type with the highest VAT payments. */  
select customer_type,sum(vat) as highest_vat 
from sales 
group by customer_type 
order by highest_vat desc 
limit 1;  -- selects which type of customer high vat payments using sum func sorts the ressult and limit to 1 to see highest

/* 19) What is the count of distinct customer types in the dataset? */   
select customer_type,count(distinct customer_type) as ct from sales 
group by customer_type;  -- count agg func used to find distinct type of customer type from sales 

/* 20) What is the count of distinct payment methods in the dataset? */  
select payment_method,count(distinct payment_method) as no_of_methods 
from sales 
group by payment_method;   -- counts the distinct payment_method and groups it 

/* 21) Which customer type occurs most frequently? */ 
select customer_type,count( customer_type) as frequency 
from sales 
group by customer_type 
order by frequency desc 
limit 1;   -- count is used to find no of customer type nd groups customer type and sort the count to limit 1 values

/* 22) Identify the customer type with the highest purchase frequency. */ 
select customer_type,count(*) as purchase_frequency 
from sales 
group by customer_type 
order by purchase_frequency 
limit 1;   -- selects count of customer type highest purchase freq

/* 23) Determine the predominant gender among customers. */ 
select Gender, count(*) as predominant_gender
from sales
group by Gender
order by predominant_gender 
desc limit 1;  

/* 24) Examine the distribution of genders within each branch. */
select Gender, branch,count(*) as gender_count
from sales
group by Gender, Branch
order by gender_count 
desc;  

/* 25) Identify the time of day when customers provide the most ratings.*/  
select  time_of_day,count(rating) as most_ratings
 from sales 
 group by time_of_day
 order by most_ratings desc 
 limit 1;

/* 26) Determine the time of day with the highest customer ratings for each branch.*/  
select time_of_day ,branch,max(rating) as  highrating 
from sales 
group by time_of_day,branch 
order by highrating desc ;

/* 27) Identify the day of the week with the highest average ratings.*/ 
select day_name ,avg(rating) as highest_average_ratings 
from sales 
group by day_name 
order by  highest_average_ratings desc 
limit 1;

/* 28) Determine the day of the week with the highest average ratings for each branch.*/ 
-- Select the day of the week, branch, and calculate the average rating for each day in each branch
SELECT day_name, branch, AVG(rating) AS avghighrating
FROM sales
-- Group the results by day of the week and branch
GROUP BY day_name, branch
-- Order the results by the average rating in descending order
ORDER BY avghighrating DESC
-- Limit the result to the first entry for each branch
LIMIT 1;

























 
