-- create new data base "space_mission_db"
create database space_mission_db

use space_mission_db

--1. Define a SQL table to store information about space missions.
select * from space_missions

-- to drop Price columns cose we have more then 3500 row null .

alter table space_missions
drop column Price


--2. Add records for at least three space missions conducted by different companies.
select Company
from space_missions
group by Company

insert into space_missions
values	
		('RVSN USSR','Matroh,Egypt','2022-08-03','18:50:00.00','Sputnik 8K71PS','Sputnik-1','Retired','Success'),
		('US Navy','Monofia,Egypt','2022-08-10','18:50:00.00','Sputnik 8K71','Sputnik-2','Retired','Success'),
		('AMBA','Alexandra,Egypt','2022-09-04','18:50:00.00','Sputnik 1PS','Sputnik-3','Retired','Failure')



--3. Retrieve the names of all rockets used in space missions.
select Rocket
from space_missions
group by Rocket

--4. Display the details of space missions launched by a specific company.

select 	Company,
		Location
from
	space_missions
group by 
	Company , Location

select * from space_missions

--------------------------------------------------------------------

-- 5. Retrieve the top 5 most expensive rockets based on their cost
-- i can't calculate the cost of Rocket... so i need to drop all the row which is had null Price value and keep the not null...

--- in the colde below i will craete table from all not null price value..
select * into space_missions_valid from (select * from space_missions_price
where Price is not null ) AS valid

select * from space_missions_valid
-- new i will work with 1265 valid row.
-- >> top 5 most expensive rockets
with rank_table as (select Rocket,
	   Price,
		ROW_NUMBER() over(partition by Price order by Rocket) AS RANK_COST
from
	space_missions_valid)

select top 5 Rocket, Price
from 
	rank_table
where RANK_COST = 1
order by Price desc


---6. Calculate the average cost of all rockets we still working on the valid data..
select  
	AVG(Price) as AVG_cost
from
	space_missions_valid

select * from space_missions_valid

-- 7. Group the missions by launch location and display the total count of missions for each location.
select
	Location,
	count(Mission) as totle_count_mission
	
from
	space_missions_valid
group by 
	Location
order by count(Mission) desc

-- 8. Create a new table for rocket details and join it with the main table to display mission names and their 
-- corresponding rocket names.


select * into rocket_details  from (select
	Rocket,
	Mission,
	RocketStatus,
	Price,
	MissionStatus
from 
	space_missions_valid) as details


--  this is the result of the point 8 join to show the Mission columns..
select 
	R.Rocket,
	R.RocketStatus,
	S.Mission,
	R.Price
from 
	rocket_details01 R
join 
	space_missions_valid S on R.Rocket = S.Rocket
----------------------------------------------------

alter table rocket_details01
drop column Mission 


select *  into rocket_details01 from (
			select 
				Rocket,
				Mission,
				RocketStatus,
				Price,
				ROW_NUMBER() over(partition by Price order by Rocket) as sort_row
			from 
				rocket_details
			) ta_a
where 
	sort_row = 1


-- add new column with seriel and make it primary key.
 alter table rocket_details01
 add primary key (Rocket)

 select * from rocket_details01


-- i need to add also new column and create it as seriel and make it primary key...
alter table space_missions_valid
add _Main_S_No int identity(1,1) primary key

-- drop the table which is hass issue i dont need it i was use it to test data
drop table [dbo].[space_missions_price]
drop table [dbo].[rocket_details]
drop table [dbo].[Rocket_price]



-- craete foreign key to make relationship between the two table...
alter table space_missions_valid
add foreign key (Rocket)
references rocket_details01(Rocket)

select * from space_missions_valid

-------------------------------------------------------------------


--9. Find the company that conducted the most expensive mission.
with number_1 as (
		select 
			S.Company,	
			R.Rocket,
			R.RocketStatus,
			S.Mission,
			R.Price,
			row_number() over(partition by S.Company order by R.Price) as number
		from 
			rocket_details01 R
		join 
			space_missions_valid S on R.Rocket = S.Rocket
			)
select top 1 Company 
from 
	number_1
where 
	number = 1
order by Price desc 

------------------------------------------------------------------------------

---10. Calculate the total cost of successful missions.
select 
	sum(Price) as totle_cost
from
	space_missions_valid 
where 
	MissionStatus = 'Success'

----------------------------------------------------------------------------------

--11. Change the status of rockets to 'Inactive' for those whose mission status is 'Prelaunch Failure'.

select 
	MissionStatus 
from 
	space_missions_valid 
group by
	MissionStatus 



update space_missions_valid 
set MissionStatus  = 'Inactive'
where 
	MissionStatus  = 'Prelaunch Failure'


select 
	MissionStatus 
from 
	space_missions_valid 
where 
	MissionStatus = 'Prelaunch Failure'
-----------------------------------------------------------------------------
--13. Remove all records where the mission status is 'Failure'

delete from space_missions_valid 
where MissionStatus  = 'Failure'

select *
from
	space_missions_valid 
where 
	MissionStatus  = 'Failure'


------------------------------------------------------------------------------------
--14. Create a new column 'Mission_Result' that categorizes missions as 'Successful', 'Partial Success', or 
--'Failed' based on their mission status.

alter table space_missions_valid
add Mission_Result varchar(100)

update space_missions_valid 
set Mission_Result = Case
	when MissionStatus = 'Success' then 'Successful'
	when MissionStatus = 'Partial Failure' then 'Partial Success'
	when MissionStatus = 'Inactive' then 'Failed'
End;


select * from space_missions_valid
















--- trying and error to test the data...

---------------------------------------------------------------------------

select * from space_missions_valid 

alter table space_missions_valid 
alter column Price decimal(12,2);

select * into Rocket_price from (
select Rocket ,cast(AVG(Price) as decimal(12,2)) as Rocket_price
from
	space_missions_valid 
group by 
	Rocket 
	) as price_R


select * from Rocket_price

-- i have to remove the primary key and add it after create the primary key of the fact table.
alter table Rocket_price
drop constraint [PK__Rocket_p__566E86BD6F138831]

alter table Rocket_price
add primary key (Rocket)

-- create new column in the table "space_missions" and set it as primary key and and make it identity teh row start by 1 and add 1 to the row.
alter table space_missions
add  s_no int identity(1,1) primary key


alter table space_missions
add constraint FK__space_mi__2F36BC5B0DB486FB foreign key (Rocket)
references Rocket_price(Rocket);


select * from space_missions