WITH competition AS (SELECT name,
					 weightclasskg,
				sex,
				date,
				best3squatkg,
				best3benchkg,
				best3deadliftkg,
				totalkg,
				ROW_NUMBER() OVER(PARTITION BY name ORDER BY date) AS comps
			FROM ipfrecords
			WHERE date >= '2024-01-01' AND country = 'England' AND event = 'SBD'
			ORDER BY name, date)


SELECT distinct on (name)
name, weightclasskg, sex
FROM competition
WHERE competition IS NOT NULL AND comps>=5
ORDER BY name, date