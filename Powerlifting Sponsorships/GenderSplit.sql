SELECT *,
	ROUND((competitors/totalyear)*100,1) AS Percentage
FROM(SELECT *,
		SUM(competitors) OVER(PARTITION BY yearly) AS totalyear
	FROM (SELECT CAST(DATE_TRUNC('year', date) AS date) AS yearly,
			sex,
			COUNT(*) AS competitors
		FROM ipfrecords
		GROUP BY yearly, sex
		ORDER BY yearly, sex));