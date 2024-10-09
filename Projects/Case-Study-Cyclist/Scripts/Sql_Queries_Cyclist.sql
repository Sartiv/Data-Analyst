--Check the # of members/casual riders

SELECT member_casual, COUNT(member_casual)
  FROM [Cyclist].[dbo].[bikes_data]
  GROUP BY member_casual;             

-- Is there a difference in bike usage time between casual riders and members?

SELECT member_casual, AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_duration_minutes
FROM [Cyclist].[dbo].[bikes_data]
GROUP BY member_casual;

-- check null cells
 SELECT 
    SUM(CASE WHEN start_station_name = 'NA' THEN 1 ELSE 0 END) AS num_null_start_station,
    SUM(CASE WHEN end_station_name = 'NA' THEN 1 ELSE 0 END) AS num_null_end_station,
    COUNT(*) AS total_rows
FROM [Cyclist].[dbo].[bikes_data];

-- What are the most popular starting locations for casual riders compared to members?

SELECT member_casual, 
       start_station_name, 
       COUNT(*) AS num_of_starts
FROM [Cyclist].[dbo].[bikes_data]
WHERE start_station_name <> 'NA' AND member_casual = 'member'
GROUP BY member_casual, start_station_name
ORDER BY num_of_starts DESC;

SELECT member_casual, 
       start_station_name, 
       COUNT(*) AS num_of_starts
FROM [Cyclist].[dbo].[bikes_data]
WHERE start_station_name <> 'NA' AND member_casual = 'casual'
GROUP BY member_casual, start_station_name
ORDER BY num_of_starts DESC;

-- What are the most popular ending locations for casual riders compared to members?

SELECT member_casual, 
       end_station_name, 
       COUNT(*) AS num_of_ends
FROM [Cyclist].[dbo].[bikes_data]
WHERE end_station_name <> 'NA' AND member_casual = 'member'
GROUP BY member_casual, end_station_name
ORDER BY num_of_ends DESC;


SELECT member_casual, 
       end_station_name, 
       COUNT(*) AS num_of_ends
FROM [Cyclist].[dbo].[bikes_data]
WHERE end_station_name <> 'NA' AND member_casual = 'casual'
GROUP BY member_casual, end_station_name
ORDER BY num_of_ends DESC;

-- How do weekends affect the usage of bikes for casual riders compared to members?

WITH total_rides AS (
    SELECT member_casual, COUNT(*) AS total_rides
    FROM [Cyclist].[dbo].[bikes_data]
    GROUP BY member_casual
)

SELECT b.member_casual, 
       COUNT(*) AS num_of_rides_weekend,
       CAST( (COUNT(*) * 100.0 / t.total_rides) AS DECIMAL(10,2)) AS percentage_rides_weekend
FROM [Cyclist].[dbo].[bikes_data] b
JOIN total_rides t ON b.member_casual = t.member_casual
WHERE DATENAME(WEEKDAY, b.started_at) IN ('Saturday', 'Sunday')
GROUP BY b.member_casual, t.total_rides;


-- Is there a difference in usage patterns at different times of the day between casual riders and members?
SELECT member_casual, 
       DATEPART(HOUR, started_at) AS ride_hour, 
       COUNT(*) AS num_of_rides
FROM [Cyclist].[dbo].[bikes_data]
GROUP BY member_casual, DATEPART(HOUR, started_at)
ORDER BY ride_hour, num_of_rides DESC;

----- save results (with percentage) in a table for visualization

WITH total_rides AS (
    SELECT member_casual, COUNT(*) AS total_rides
    FROM [Cyclist].[dbo].[bikes_data]
    GROUP BY member_casual
)

SELECT b.member_casual, 
       DATEPART(HOUR, b.started_at) AS ride_hour, 
       COUNT(*) AS num_of_rides,
       CAST( (COUNT(*) * 100.0 / t.total_rides) AS DECIMAL(10,2)) AS percentage_rides_hour
INTO usage_times_of_the_day
FROM [Cyclist].[dbo].[bikes_data] b
JOIN total_rides t ON b.member_casual = t.member_casual
GROUP BY b.member_casual, DATEPART(HOUR, b.started_at), t.total_rides
ORDER BY ride_hour, num_of_rides DESC;




-- How many rides do casual riders take on average compared to members over a week or month?

-- month
SELECT member_casual, 
       DATENAME(MONTH, started_at) AS ride_month, 
       COUNT(*) AS num_of_rides
FROM [Cyclist].[dbo].[bikes_data]
GROUP BY member_casual, DATENAME(MONTH, started_at)
ORDER BY ride_month;

----- save results (with percentage) in a table for visualization

WITH total_rides AS (
    SELECT member_casual, COUNT(*) AS total_rides
    FROM [Cyclist].[dbo].[bikes_data]
    GROUP BY member_casual
)

SELECT b.member_casual, 
       DATENAME(MONTH, b.started_at) AS ride_month, 
       COUNT(*) AS num_of_rides,
       CAST( (COUNT(*) * 100.0 / t.total_rides) AS DECIMAL(10,2) ) AS percentage_rides_month
INTO rides_month
FROM [Cyclist].[dbo].[bikes_data] b
JOIN total_rides t ON b.member_casual = t.member_casual
GROUP BY b.member_casual, DATENAME(MONTH, b.started_at), t.total_rides
ORDER BY ride_month;


-- week
SELECT member_casual, 
       DATEPART(WEEK, started_at) AS ride_week, 
       COUNT(*) AS num_of_rides
FROM [Cyclist].[dbo].[bikes_data]
GROUP BY member_casual, DATEPART(WEEK, started_at)
ORDER BY ride_week;

----- save results (with percentage) in a table for visualization


WITH total_rides AS (
    SELECT member_casual, COUNT(*) AS total_rides
    FROM [Cyclist].[dbo].[bikes_data]
    GROUP BY member_casual
)

SELECT b.member_casual, 
       DATEPART(WEEK, b.started_at) AS ride_week, 
       COUNT(*) AS num_of_rides,
       CAST( (COUNT(*) * 100.0 / t.total_rides) AS DECIMAL(10,2) ) AS percentage_rides_week
INTO rides_week
FROM [Cyclist].[dbo].[bikes_data] b
JOIN total_rides t ON b.member_casual = t.member_casual
GROUP BY b.member_casual, DATEPART(WEEK, b.started_at), t.total_rides
ORDER BY ride_week;

----- Calculate distance of every ride

SELECT member_casual,
       AVG(6371 * ACOS(
               LEAST(1, GREATEST(-1, 
               COS(RADIANS(CAST(start_latitude AS FLOAT))) * 
               COS(RADIANS(CAST(end_latitude AS FLOAT))) * 
               COS(RADIANS(CAST(end_longitude AS FLOAT)) - 
                    RADIANS(CAST(start_longitude AS FLOAT))) + 
               SIN(RADIANS(CAST(start_latitude AS FLOAT))) * 
               SIN(RADIANS(CAST(end_latitude AS FLOAT))))))) AS avg_distance_km
FROM [Cyclist].[dbo].[bikes_data]
WHERE ISNUMERIC(start_latitude) = 1 
  AND ISNUMERIC(start_longitude) = 1
  AND ISNUMERIC(end_latitude) = 1
  AND ISNUMERIC(end_longitude) = 1
GROUP BY member_casual;


----------
SELECT * FROM Cyclist.dbo.rides_month

EXEC Cyclist.dbo.rides_month






