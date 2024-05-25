SET datestyle = DMY; /* set datestyle is a command used to set the date display style to day-month-year format */

/* Q1: Create a table named ‘matches’ with appropriate data types for columns */

CREATE table matches(
match_id int,
city varchar,
date date,
player_of_match varchar,
venue varchar,
neutral_venue int,
team1 varchar,
team2 varchar,
toss_winner varchar,
toss_decision varchar,
winner varchar,
result_mode varchar,
result_margin int,
eliminator varchar,
method_dl varchar,
umpire1 varchar,
umpire2 varchar);


/* Q2: Create a table named ‘deliveries’ with appropriate data types for columns */	

CREATE table deliveries(
match_id int,
inning int,
over int,
ball int,
batsman varchar,
non_striker varchar,
bowler varchar,
batsman_runs int,
extra_runs int,
total_runs int,
wicket_ball int,
dismissal_kind varchar,
player_dismissed varchar,
fielder varchar,
extras_type varchar,
batting_team varchar,
bowling_team varchar);


/* Q3: Import data from csv file ’IPL_matches.csv’ attached in resources to the table ‘matches’ which was created in Q1 */	

COPY matches 
FROM 'C:\Program Files\PostgreSQL\15\data\Data_Copy\IPL_matches.CSV'csv header; 


/* Q4: Import data from csv file ’IPL_Ball.csv’ attached in resources to the table ‘deliveries’ which was created in Q2 */

COPY deliveries 
FROM 'C:\Program Files\PostgreSQL\15\data\Data_Copy\IPL_ball.csv'csv header; 


/* Q5: Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order. */

SELECT * 
FROM deliveries
LIMIT 20;


/* Q6: Select the top 20 rows of the matches table. */
SEELCT *
FROM matches
LIMIT 20;


/* Q7:  Fetch data of all the matches played on 2nd May 2013 from the matches table. */

SELECT * 
FROM matches
WHERE date  = '02-05-2013';


/* Q8:  Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs. */

SELECT * 
FROM matches
WHERE result_mode='runs'
AND result_margin >100;

/* Q9:  Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date. */

SELECT *
FROM matches
WHERE result_mode='tie'
ORDER BY date DESC;


/* Q10:  Get the count of cities that have hosted an IPL match. */

SELECT COUNT (DISTINCT city)
FROM matches;


/* Q11:  Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending 
on the total_run (boundary for >= 4, dot for 0 and other for any other number)
(Hint 1 : CASE WHEN statement is used to get condition based results)
(Hint 2: To convert the output data of select statement into a table, you can use a subquery. Create table table_name as [entire select statement]. */

CREATE TABLE deliveries_v02 AS SELECT *,
CASE WHEN total_run >=4 THEN 'boundary'
WHEN total_run =0 THEN 'dot'
ELSE 'other'
END AS ball_result
FROM deliveries;

SELECT *
FROM deliveries_v02;


/* Q12:  Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table. */

SELECT ball_result,
COUNT(*)
FROM deliveries_v02
GROUP BY ball_result;


/* Q13:  Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of 
boundaries scored. */

SELECT batting_team,
COUNT(*)
FROM deliveries_v02
WHERE ball_result='boundary'
GROUP BY batting_team
ORDER BY count DESC;


/* Q14:  Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled. */

SELECT bowling_team,
COUNT(*) FROM deliveries_v02
WHERE ball_result='dot'
GROUP BY bowling_team
ORDER BY count DESC;


/* Q15:  Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA. */

SELECT dismissal_kind,
COUNT(*) FROM deliveries
WHERE dismissal_kind <> 'NA'
GROUP BY dismissal_kind 
ORDER BY count DESC;


/* Q16:  Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table. */

SELECT bowler,
SUM(extra_runs) AS total_extra_runs 
FROM deliveries 
GROUP BY bowler
ORDER BY total_extra_runs DESC 
LIMIT 5;



/* Q17:  Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) 
of venue and date from table matches. */

CREATE TABLE deliveries_v03 as SELECT a.*,
								b.venue,
								b.match_date 
FROM
deliveries_v02 AS a
left join (SELECT MAX(venue) AS venue,MAX(date) AS match_date,match_id 
FROM matches GROUP BY match_id) AS b
ON a.match_id=b.match_id;

select * from deliveries_v03;


/* Q18:  Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored. */

SELECT venue,
SUM(total_run) AS run 
FROM deliveries_v03
GROUP BY venue
ORDER BY run DESC;


/* Q19:  Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored. */

SELECT EXTRACT (YEAR FROM match_date) AS IPL_year,
SUM(total_run) AS runs 
FROM deliveries_v03
WHERE venue='Eden Gardens'
GROUP BY IPL_year 
ORDER BY runs desc;



/* Q20:  Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another
 one with Rising Pune Supergiants.  Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with 
replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns. */

SELECT DISTINCT team1 
FROM matches;

CREATE TABLE matches_corrected AS SELECT *,
REPLACE (team1,'Rising Pune Supergiants','Rising Pune Supergiant') AS team1_corr,
REPLACE (team2,'Rising Pune Supergiants','Rising Pune Supergiant') AS team2_corr 
FROM matches;



/* Q21:  Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ 
(For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03). */

CREATE TABLE deliveries_v04 AS SELECT *
CONCAT (match_id,'_',inning,'_',over,'_',ball)
as ball_id, * 
FROM deliveries_v03;

SELECT * 
FROM deliveries_v04;


/* Q22:  Compare the total count of rows and total count of distinct ball_id in deliveries_v04; */

SELECT * 
FROM deliveries_v04 
LIMIT 20;

SELECT COUNT (distinct ball_id)
FROM deliveries_v04;

SELECT count(*)
FROM deliveries_v04;


/* Q23:  Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. 
(HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num). */

CREATE TABLE deliveries_v05 AS SELECT *,
row_number() over (partition by ball_id) AS r_num 
FROM deliveries_v04;

SELECT * 
FROM deliveries_v05;


/* Q24:  Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating.
 (HINT : select * from deliveries_v05 WHERE r_num=2;). */

SELECT COUNT(*) 
FROM deliveries_v05;

SELECT SUM(r_num) 
FROM deliveries_v05;

SELECT * 
FROM deliveries_v05 
ORDER BY r_num 
LIMIT 20;

SELECT * 
FROM deliveries_v05 
WHERE r_num=2;


/* Q25:  Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05
 WHERE r_num=2); */

SELECT * 
FROM deliveries_v05
WHERE ball_id IN (SELECT BALL_ID FROM deliveries_v05 WHERE r_num=2);