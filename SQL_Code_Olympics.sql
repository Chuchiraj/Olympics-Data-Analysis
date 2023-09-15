select * from athlete
order by 1

-- 1. How many olympics games have been held?


select   count(distinct(Games)) as tot_games
from athlete


-- 2. List down all Olympics games held so far.

select distinct(Year) as [year], Season, City
from athlete
order by 1


-- 3. Mention the total no of nations who participated in each olympics game?


select distinct a.Games, count(distinct(b.region)) as no_of_nations
from athlete as a
left join regions as b
on a.NOC = b.NOC
group by a.Games
order by 1


--4. Which year saw the highest and lowest no of countries participating in olympics















--5. Which nation has participated in all of the olympic games


select * from (
select a.Team, count(distinct(a.Games)) as parti_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
group by a.Team ) as c
where c.parti_count =  (select count(distinct(Games)) as tot_game
                         from athlete)


--6. Identify the sport which was played in all summer olympics.


select * from (
select Sport,  count(distinct(Games)) as tot_game
from athlete
where Season = 'Summer'
group by Sport 
--  ) as a
--where a.tot_game = ( select count(distinct(Games)) from athlete )
order by 2 desc


select Sport,  count(Games) as tot_game
from athlete
where Season = 'Summer'
group by Sport 
order by 2 desc

select distinct Sport, Games 
from athlete

--7. Which Sports were just played only once in the olympics.

with cte as 
(
select distinct Sport, Games
from athlete )
select Sport, count(Games) as game_cnt
from cte
group by Sport
having count(Games) = 1


--8. Fetch the total no of sports played in each olympic games.

select Games, count(distinct(Sport)) as num_count
from athlete
group by Games
order by 2 desc


--9. Fetch oldest athletes to win a gold medal


select  Name, Age , Games, City, Sport, Event, Medal
from athlete
where Medal = 'Gold' and Age = (select max(Age) from athlete where Medal = 'Gold')


--10. Find the Ratio of male and female athletes participated in all olympic games.

with t1 as (
           select Sex, count(1) as cnt
           from athlete
           group by Sex),
t2 as (
           select * , ROW_NUMBER () over(order by cnt) as rn
		   from t1 ),

min_cnt as
        	(select cnt from t2	where rn = 1),
max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(cast(max_cnt.cnt as float )/min_cnt.cnt , 2)) as ratio
    from min_cnt, max_cnt



-- 11. Fetch the top 5 athletes who have won the most gold medals.

select Top 5 a.Name, b.region,  count(Medal) as gold_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Gold'
group by a.Name, b.region
order by 3 desc


--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select Top 5 a.Name, b.region,  count(Medal) as medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal in ('Gold','Silver','Bronze')
group by a.Name, b.region
order by 3 desc


--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select  Top 5 b.region,  count(Medal) as medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal in ('Gold','Silver','Bronze')
group by  b.region
order by 2 desc


--14. List down total gold, silver and bronze medals won by each country.

with gold as (
select  b.region,  count(Medal) as gold_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Gold'
group by  b.region ) ,

silver as (
select  b.region,  count(Medal) as silver_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Silver'
group by  b.region ) ,

bronze as (
select  b.region,  count(Medal) as bronze_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Bronze'
group by  b.region )
                  select a.region , a.gold_medal_count, b.silver_medal_count, c.bronze_medal_count
                  from gold as a
                  join silver as b
                  on a.region = b.region
                  join bronze as c
                  on a.region = c.region
				  order by 2 desc


--15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with gold as (
select  a.Games, b.region,  count(Medal) as gold_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Gold'
group by  a.Games, b.region ) ,

silver as (
select  a.Games, b.region,  count(Medal) as silver_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Silver'
group by  a.Games, b.region ) ,

bronze as (
select a.Games, b.region,  count(Medal) as bronze_medal_count
from athlete as a
left join regions as b
on a.NOC = b.NOC
where a.Medal = 'Bronze'
group by  a.Games, b.region )
                  select a.Games, a.region , a.gold_medal_count, b.silver_medal_count, c.bronze_medal_count
                  from gold as a
                  join silver as b
                  on a.region = b.region and a.Games = b.Games
                  join bronze as c
                  on a.region = c.region and a.Games = c.Games
				  order by 1,2




















































