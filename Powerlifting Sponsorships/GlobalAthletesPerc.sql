SELECT country, COUNT(*) AS total, COUNT(*)/SUM(COUNT(*)) OVER() AS percentage
FROM(SELECT distinct on (name) 
name, country, weightclasskg
FROM (SELECT name,
			country,
			sex,
		  	weightclasskg,
			totalkg,
		  	RANK() OVER(PARTITION BY weightclasskg, sex ORDER BY totalkg DESC)
		FROM ipfrecords
		WHERE date >= '2019-01-01' AND totalkg IS NOT NULL AND country IN (SELECT country
																		   FROM (SELECT country,
																				count(*)
																				FROM ipfrecords
																				WHERE country IS NOT NULL
																				GROUP BY country
																				ORDER BY COUNT(*) DESC
																				LIMIT 10)))
WHERE rank <= 10 AND weightclasskg IS NOT NULL
ORDER BY name)
GROUP BY country