select *
from sales

-- Data Preprocessing

-- Changing data type of customerid column 
alter table sales
alter column customerid TYPE VARCHAR(255);

-- Replacing the null values with "NoID".
update sales
set customerid = 'NoID'
where customerid is null

-- Checking data distribution of priceperunit

select
    percentile_cont(0.1) within group (order by priceperunit) as p10,
    percentile_cont(0.5) within group (order by priceperunit) as p50,
    percentile_cont(0.9) within group (order by priceperunit) as p90
from sales

--checking data distribution of totalamount

select
    percentile_cont(0.1) within group (order by totalamount) as p10,
    percentile_cont(0.5) within group (order by totalamount) as p50,
    percentile_cont(0.9) within group (order by totalamount) as p90
from sales

--Replacing the null values in totalamount column with the Average value.

update sales
set totalamount = (select Avg(totalamount) from sales where totalamount is not null)
WHERE totalamount is null

--Replacing the null values in priceperunit column with the median value.

with MedianValue as (
    select percentile_cont(0.5) within group (order by priceperunit) as median_value
    from sales
    where priceperunit is not null
)

UPDATE sales
set priceperunit = (select median_value from MedianValue)
WHERE priceperunit is null

-- Filling in null values of discountapplied

update sales
set discountapplied = 0
where discountapplied is null

-- Removing duplicate transactionid and using row number to have all unique transaction ids'

alter table sales
add column unique_id serial

alter table sales
drop column transactionid

alter table sales
rename column unique_id to transactionid


-- Shifting the column to the first

create table sales_new as
select
    transactionid,
	CustomerID,
	TransactionDate,
	ProductID,
	ProductCategory,
	Quantity,
	PricePerUnit,
	TotalAmount,
	TrustPointsUsed,
	PaymentMethod,
	DiscountApplied
from sales

drop table sales

alter table sales_new
rename to sales

-- grouping by productcategory and aggregate

select productcategory, sum(quantity) as totalquantity, sum(totalamount) as totalsales, round(avg(priceperunit),2) as avgprice
from sales
group by productcategory
order by totalsales

-- grouping by customerid

select customerid, count(transactionid) as transactioncount, sum(quantity) as totalquantity, sum(totalamount) as totalspent, sum(discountapplied) as totaldiscount
from sales
group by customerid

-- totalcount of each payment method

select paymentmethod, count(*) as totalcount
from sales
group by paymentmethod
order by totalcount desc

-- Sales trend

select transactiondate, sum(totalamount) as total_sales
from sales
group by transactiondate

-- sales trend by day

select to_char(transactiondate, 'Day') as weekday, sum(totalamount) as total_sales
from sales
group by weekday
order by total_sales

-- Data Validation
-- checking number of orders returned
select *
from sales
where quantity < 0 or totalamount < 0

-- checking for duplicates
select transactionid, count(*)
from sales
group by transactionid
having count(*) > 1;

-- checking linearity

select corr(quantity, totalamount) as correlation_coefficient
from sales

-- --0.325, hence, moderate positive linear relationship.


















































































