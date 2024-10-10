WITH base AS (SELECT operator,
				ROW_NUMBER() OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS row_number, 
				height, 
				AVG(height) OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_height, 
				STDDEV(height) OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS stddev_height
			FROM manufacturing_parts),

	calc AS (SELECT *,
				avg_height + 3*stddev_height/SQRT(5) AS ucl,
				avg_height - 3*stddev_height/SQRT(5) AS lcl
			FROM base
			WHERE row_number >= 5)

SELECT *,
		CASE WHEN height NOT BETWEEN lcl AND ucl
		THEN TRUE
		ELSE FALSE
		END AS alert
FROM calc
