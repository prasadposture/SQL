#showing all tables
show tables;

#describing a table
desc sales;

#getting all the columns from a tbale
select * from sales limit 5;

#getting selected columns from a table
select SaleDate, Amount, Customers from sales limit 5;

#getting selected columns with different order
select Amount, SaleDate, GeoID from sales;

#calculating amount per box each day
SELECT 
    SaleDate, Amount, Boxes, Amount / Boxes
FROM
    sales;

#renaming the column using alias
SELECT 
    SaleDate, Amount, Boxes, Amount / Boxes as 'Amount per Box'
FROM
    sales;
    
#selecting entries with sales amount higher than 10000
select * 
from sales
where Amount>10000;

#ordering above by amount (descending)
select *
from sales 
where amount>10000
order by amount desc;

-#entries with GeoID G1 and ordered by PID and Amount
select *
from sales
where GeoID='G1'
order by PID, Amount desc;

#sales from in the year 2022 which are greater than 10000
select *
from sales
where amount>10000 and SaleDate>='2022-01-01' and SaleDate<='2022-12-31';

#similiary the above can be done using year() function
select * 
from sales
where amount>10000 and year(SaleDate)=2022;

#entries with all the boxes from 0 to 50
select *
from sales
where boxes>=0 and boxes<=50;

#same as above but using between 
select *
from sales
where boxes between 0 and 50;

#sales on friday using weekday function 0 for monday, 6 for sunday
#shop is closed on weekends
select SaleDate, Amount, Weekday(SaleDate) as 'Day of week'
from sales
where weekday(SaleDate)=4;

#people who are from team delish or jucies
select * from people
where Team='Delish' or Team='Jucies';

#another way using in
select * from peole
where Team in ('Delish','Jucies');

#names of the salesperson starting with B
select * from people
where Salesperson like 'B%';

#names containing B
select * from people
where salesperson like '%B%';

#categorize sales amount 
select Amount, Boxes,
	case 
		when amount<1000 then 'Under 1k'
		when amount<5000 then 'Under 5k'
		when amount<10000 then 'Under 10k'
    else '10k or more'
end as 'Amount Category'
from sales;

#getting salesperson and the amount
select p.Salesperson, s.Amount, s.Boxes
from sales s
join people p on p.SPID=s.SPID;

#getting salesdate, amount and product
select pr.Product, s.SaleDate, s.Amount
from sales s
left join products pr
on pr.PID=s.PID;
    
#joining multiple tables
select pr.Product, p.Salesperson, s.Amount
from sales s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID;

#conditinal joining: with amount<500  team delish
select pr.Product, p.Salesperson, s.Amount
from sales s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
where s.amount<500 and p.team='Delish';

#same above but people without team
select pr.Product, p.Salesperson, s.Amount
from sales s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
where s.amount<500 and p.team='';

#additional condition: people fro New Zealand or India
select pr.Product, p.Salesperson, s.Amount, g.Geo, s.SaleDate
from sales s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
join geo g on g.GeoID=s.GeoID
where s.amount<500 and p.team=''
and Geo in ('New Zealand', 'India')
order by s.SaleDate;

# Sales by GeoID
select GeoID, sum(Amount) as 'Total Amount', avg(Amount) as 'Average Amount', sum(Boxes) as 'Count of Boxes'
from sales
group by GeoID;

#calculate amount by each sales person in year 2022 order by the increasing tota amount
select p.Salesperson, sum(s.Amount) as 'Total Amount'
from sales s
join people p on p.SPID=s.SPID
where year(s.SaleDate)=2022
group by p.Salesperson
order by sum(s.Amount) desc;

#Grouping by Geography
select g.Geo, sum(Amount) as 'Total Amount', avg(Amount) as 'Average Amount', sum(Boxes) as 'Count of Boxes'
from sales s
join geo g on g.GeoID=s.GeoID
group by g.Geo
order by 'Total Amount' desc;

#Highes selling category with team not null
select pr.category, p.team, sum(boxes) as 'Total Boxes',
sum(amount) as 'Total Amount'
from sales s
join people p on p.SPID=s.SPID
join products pr on pr.PID=s.PID
where team<>''
group by pr.Category, p.Team
order by pr.category, p.Team;

#Top 10 highest selling products
select pr.Product, sum(s.amount)
from sales s
join products pr on pr.PID=s.PID
group by pr.Product
order by sum(s.Amount) desc
limit 10;