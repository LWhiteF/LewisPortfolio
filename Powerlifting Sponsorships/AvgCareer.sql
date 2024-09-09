WITH datediff AS(SELECT name, 
		MAX(date) - MIN(date) AS dayscompeting
		FROM ipfrecords
		GROUP BY name)
				
SELECT ROUND(AVG(dayscompeting),2) AS averagecareer
FROM datediff
WHERE dayscompeting != 0