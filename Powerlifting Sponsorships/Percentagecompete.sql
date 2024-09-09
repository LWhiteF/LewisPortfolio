WITH datediff AS(SELECT name, 
				MAX(date) - MIN(date) AS dayscompeting
				FROM ipfrecords
				GROUP BY name)

SELECT dayscompeting, 
		COUNT(*) AS total,
 		COUNT(*)/SUM(COUNT(*)) OVER() AS percentage
FROM datediff
Group By dayscompeting
ORDER BY dayscompeting
