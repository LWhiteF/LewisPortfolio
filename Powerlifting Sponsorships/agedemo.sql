WITH athletes AS(SELECT distinct on (name)
				 name, sex, ageclass
				FROM ipfrecords)

SELECT sex, ageclass, COUNT(*)
FROM athletes
WHERE ageclass IS NOT NULL
GROUP BY sex, ageclass
ORDER BY ageclass, sex