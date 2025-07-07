-- Combining the seperate months of data into one table

SELECT
	*
INTO
	td_year
FROM(
	SELECT * FROM cyclistic.dbo.td_january
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_february
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_march
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_april
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_may
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_june
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_july
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_august
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_september
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_october
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_november
	UNION ALL
	SELECT * FROM cyclistic.dbo.td_december
	)t;


-- Getting a quick glimpse of the two types of riders.

SELECT
	member_casual AS type,
	COUNT(*) as num_riders,
	CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF_BIG(SECOND, 0, ride_length)), 0)) AS average_duration,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual
ORDER BY
	member_casual;


-- Viewing trends of riders during different days of the week.

SELECT
	member_casual AS type,
	CASE CAST(day_of_week AS INT)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
        ELSE 'Invalid'
    END AS day_name,
	COUNT(*) AS num_riders,
	CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF_BIG(SECOND, 0, ride_length)), 0)) AS average_duration,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual, day_of_week
ORDER BY
	num_riders DESC;


-- Viewing trends of riders during different months.

SELECT
	member_casual AS type,
	month_of_year,
	COUNT(*) AS num_riders,
	CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF_BIG(SECOND, 0, ride_length)), 0)) AS average_duration,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual, month_of_year
ORDER BY
	month_of_year, member_casual;


-- Viewing what type of bike riders of each type use most.

SELECT
	 member_casual,
	 rideable_type,
	 COUNT(*) AS num_riders,
	 CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF_BIG(SECOND, 0, ride_length)), 0)) AS average_duration,
	 ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual, rideable_type
ORDER BY num_riders DESC;

-- Most frequented start station for casual riders.

SELECT 
	start_station_id,
	start_station_name,
	start_lat,
	start_lng,
	member_casual AS type,
	COUNT(*) AS num_riders
FROM
	td_year
WHERE member_casual = 'casual'
GROUP BY start_station_id, start_station_name, start_lat, start_lng, member_casual
ORDER BY num_riders DESC;


-- Most frequented start station for member riders.

SELECT 
	start_station_id,
	start_station_name,
	start_lat,
	start_lng,
	member_casual AS type,
	COUNT(*) AS num_riders
FROM
	td_year
WHERE member_casual = 'member'
GROUP BY start_station_id, start_station_name, start_lat, start_lng, member_casual
ORDER BY num_riders DESC;

-- Geographical data for casual riders

SELECT
	start_lat,
	start_lng,
	member_casual AS rider_type,
	COUNT(*) AS num_riders
FROM 
	td_year
GROUP BY start_lat, start_lng, member_casual
ORDER BY num_riders DESC;


-- Creating a temp table.

DROP TABLE IF EXISTS #long_ride_lengths
CREATE TABLE #long_ride_lengths (
	member_casual nvarchar(255),
	rideable_type nvarchar(255),
	ride_length time(0),
	day_of_week numeric,
	month_of_year numeric
	)
	
INSERT INTO #long_ride_lengths
SELECT
	member_casual,
	rideable_type,
	ride_length,
	day_of_week,
	month_of_year
FROM 
	td_year
WHERE
	ride_length >= '00:30:00';


-- Querying the new temp table.

SELECT
	member_casual,
	COUNT(*) AS num_riders,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM #long_ride_lengths), 2) AS percentage
FROM
	#long_ride_lengths
GROUP BY
	member_casual;


-- Creating Views to store data for visualization.

CREATE VIEW bike_type_stats AS
SELECT
	 member_casual,
	 rideable_type,
	 COUNT(*) AS num_riders,
	 ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual, rideable_type;


CREATE VIEW days_of_week_stats AS
SELECT
	member_casual AS type,
	CASE CAST(day_of_week AS INT)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
        ELSE 'Invalid'
    END AS day_name,
	COUNT(*) AS num_riders,
	CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF_BIG(SECOND, 0, ride_length)), 0)) AS average_duration,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM td_year), 2) AS percentage
FROM
	td_year
GROUP BY
	member_casual, day_of_week


