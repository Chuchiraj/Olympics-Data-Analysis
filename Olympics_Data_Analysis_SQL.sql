select * from athlete
select * from regions

--1) How many olympics games have been held?

select count(*) as tot_games from (
select   distinct Year, Season
from athlete) as a

--2) List down all Olympics games held so far.

select   distinct Year, Season
from athlete

--3) Mention the total no of nations who participated in each olympics game?

select    Year, Season, count(distinct(Team)) as nation_cnt 
from athlete
group by Year, Season
order by 1


--4) Which year saw the highest and lowest no of countries participating in olympics?

with cte_low as (
select   top 1 Year, Season, count(distinct(Team)) as nation_cnt 
from athlete
group by Year, Season
order by 3),

cte_high as (
select   top 1 Year, Season, count(distinct(Team)) as nation_cnt 
from athlete
group by Year, Season
order by 3 desc)
select  cte_low.Year as year_with_lowest_part, cte_high.Year as year_with_highest_part
from cte_high, cte_low


--5) Which nation has participated in all of the olympic games?

select Team, count(Games) as game_cnt
from athlete
group by Team
having count(Games) = ( select count(distinct Games) from athlete)


--6) Identify the sport which was played in all summer olympics

select distinct Sport
from athlete
where Games like '%Summer%'

--7) Which Sports were just played only once in the olympics?

select  Sport, count(distinct (Games)) as count_in_games
from athlete 
group by  Sport
having count( distinct (Games)) = 1


--8) Fetch the total no of sports played in each olympic games.

select  Games, count(distinct (Sport)) as no_of_sports
from athlete 
group by  Games

--9) Fetch details of the oldest athletes to win a gold medal

with cte_gold_age as (
select ID, Name, Sex, Age,
DENSE_RANK() over( order by Age desc) as rnk
from athlete
where Medal = 'Gold' )
select cte_gold_age.ID, cte_gold_age.Name, cte_gold_age.Sex, cte_gold_age.Age 
from cte_gold_age where rnk = 1


--10) Find the Ratio of male and female athletes participated in all olympic games.


with cte_distinct_name as (
select distinct Name, Sex
from athlete)
select round(cast(sum(case when Sex = 'M' then 1 else 0 end) as float)/count(*),3) as male_ratio,
round(cast(sum(case when Sex = 'F' then 1 else 0 end )as float)/count(*),3) as female_ratio,
count(*) as to_cnt
from cte_distinct_name


--11) Fetch the top 5 athletes who have won the most gold medals.

select Top 5 Name, count(Medal) as gold_cnt
from athlete
where Medal = 'Gold'
group by Name
order by 2 desc

--12) Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

select Top 5 Name, count( Medal) as medal_cnt
from athlete
where Medal != 'NA'
group by Name
order by 2 desc

--13) Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select Top 5 Team, count(Medal) as gold_cnt
from athlete
where Medal = 'Gold'
group by Team
order by 2 desc

--14) List down total gold, silver and broze medals won by each country

with cte_gold as (
                  select  Team,  count(Medal) as gold_medal_cnt
                  from athlete where Medal = 'Gold'
                  group by Team   ),

cte_silver as (
               select  Team,  count(Medal) as silver_medal_cnt from athlete
               where Medal = 'Silver'
               group by Team  ),

cte_bronze as (
              select  Team,  count(Medal) as bronze_medal_cnt from athlete
              where Medal = 'Bronze'
              group by Team   )
select a.Team, a.gold_medal_cnt as gold_count, b.silver_medal_cnt as silver_cnt, c.bronze_medal_cnt as bronze_cnt
from cte_gold as a
inner join cte_silver as b
on a.Team = b.Team 
join cte_bronze as c
on a.Team = c.Team
order by 2 desc



--15) List down total gold, silver and broze medals won by each country corresponding to each olympic games.

with cte_gold as (
                  select  Games, Team,  count(Medal) as gold_medal_cnt
                  from athlete where Medal = 'Gold'
                  group by Games, Team   ),

cte_silver as (
               select Games, Team,  count(Medal) as silver_medal_cnt from athlete
               where Medal = 'Silver'
               group by Games, Team  ),

cte_bronze as (
              select Games, Team,  count(Medal) as bronze_medal_cnt from athlete
              where Medal = 'Bronze'
              group by Games, Team   )
select a.Games, a.Team,  a.gold_medal_cnt as gold_count, b.silver_medal_cnt as silver_cnt, c.bronze_medal_cnt as bronze_cnt
from cte_gold as a
inner join cte_silver as b
on a.Team = b.Team and a.Games = b.Games
join cte_bronze as c
on a.Team = c.Team and a.Games = c.Games
order by 1 asc , 3 desc



--16) Identify which country won the most gold, most silver and most bronze medals in each olympic games.

with cte_gold as (
                  select *, ROW_NUMBER() over (  partition by Games order by gold_medal_cnt desc   ) as r_n_gold 
				  from (
				  select  Games, Team,  count(Medal) as gold_medal_cnt				  
                  from athlete where Medal = 'Gold'
                  group by Games, Team) as a     ) ,

cte_silver as (
                  select *, ROW_NUMBER() over (  partition by Games order by silver_medal_cnt desc   ) as r_n_silver 
				  from (
				  select  Games, Team,  count(Medal) as silver_medal_cnt				  
                  from athlete where Medal = 'Silver'
                  group by Games, Team) as b     ) ,

cte_bronze as (
                  select *, ROW_NUMBER() over (  partition by Games order by bronze_medal_cnt desc   ) as r_n_bronze 
				  from (
				  select  Games, Team,  count(Medal) as bronze_medal_cnt				  
                  from athlete where Medal = 'Bronze'
                  group by Games, Team) as c    )

select p.Games,  CONCAT( p.Team, ' - ', p.gold_medal_cnt) as max_gold, 
CONCAT( q.Team,' - ', q.silver_medal_cnt) as max_silver, CONCAT( r.Team,' - ', r.bronze_medal_cnt) as max_bronze
from cte_gold as p
join cte_silver as q
on p.Games = q.Games and p.Team = q.Team
join cte_bronze as r
on p.Games = r.Games and p.Team = r.Team
where p.r_n_gold = 1 and q.r_n_silver = 1  and r.r_n_bronze = 1


--17) Which countries have never won gold medal but have won silver/bronze medals?

select * into olympic_data from(
select a.*, b.region
from athlete as a
left join regions as b
on a.NOC = b.NOC) p

select * from olympic_data

with cte_gold as ( select distinct region   from olympic_data except
                  select  region
                  from olympic_data where Medal = 'Gold'
                  group by region having count(Medal) >0 ) ,

cte_silver as (
               select  region,  count(Medal) as silver_medal_cnt from olympic_data
               where Medal = 'Silver'
               group by region  ),

cte_bronze as (
              select  region,  count(Medal) as bronze_medal_cnt from olympic_data
              where Medal = 'Bronze'
              group by region )
select a.region,  0 as gold_count, b.silver_medal_cnt as silver_cnt, c.bronze_medal_cnt as bronze_cnt
from cte_gold as a
left join cte_silver as b
on a.region = b.region
left join cte_bronze as c
on a.region = c.region
where b.silver_medal_cnt >=1 
or c.bronze_medal_cnt >=1

--18) In which Sport/event, India has won highest medals.

select Top 1 Sport, count(Medal) as medal_cnt 
from olympic_data
where region = 'India' and Medal != 'NA'
group by Sport order by 2 desc

--19) Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

select region, Games, Sport, count(Medal) as medal_cnt 
from olympic_data
where region = 'India' and Medal != 'NA' and Sport = 'Hockey'
group by region, Games, Sport 
order by 4 desc

















































