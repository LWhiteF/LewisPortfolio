WITH eu AS (SELECT DISTINCT country
				FROM ipfrecords
				WHERE country IN('Belgium', 'England', 'France', 'Germany',
								'Ireland', 'Italy', 'Netherlands', 'Norway',
								 'Scotland', 'UK', 'Wales')),
								 
shortlist AS (SELECT name,
				sex,
				date,
				ipfrecords.country,
				weightclasskg,
				totalkg,
				RANK() OVER(PARTITION BY weightclasskg, sex ORDER BY totalkg DESC),
				ROW_NUMBER() OVER(PARTITION BY name) AS competitions
			FROM ipfrecords
			INNER JOIN eu
			ON ipfrecords.country = eu.country
			WHERE date >= '2019-01-01' AND totalkg IS NOT NULL AND weightclasskg IS NOT NULL)
					
SELECT distinct on (name) 
	name, sex, country
FROM shortlist
WHERE competitions >= 3 AND rank <=25
ORDER BY name, country;
