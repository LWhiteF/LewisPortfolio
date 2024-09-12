WITH datediff AS (SELECT name, sex,
					MAX(date) - MIN(date) AS dayscompeting
					FROM ipfrecords
					GROUP BY name, sex),
					
sexcount AS (SELECT sex,
				COUNT(*) AS total
				FROM datediff
				GROUP BY sex),
				
countmulti AS (SELECT sex,
				COUNT(*) AS multicomp
				FROM datediff
				WHERE dayscompeting != 0
				GROUP BY sex),

countone AS (SELECT sex,
				COUNT(*) AS onecomp
				FROM datediff
				WHERE dayscompeting = 0
				GROUP BY sex)
				
SELECT sexcount.sex, total, multicomp, onecomp
FROM sexcount
LEFT JOIN countmulti
ON sexcount.sex = countmulti.sex
LEFT JOIN countone
ON sexcount.sex = countone.sex