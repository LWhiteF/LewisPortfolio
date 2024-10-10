SELECT sub_cl.*,
		CASE WHEN sub_cl.height NOT BETWEEN sub_cl.lcl AND  sub_cl.ucl
		THEN TRUE
		ELSE FALSE
		END AS alert
FROM	(SELECT sub.*,
				sub.avg_height + 3*sub.stddev_height AS ucl,
				sub.avg_height - 3*sub.stddev_height AS lcl
		FROM (SELECT operator,
				ROW_NUMBER() OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS row_number, 
				height, 
				AVG(height) OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_height, 
				STDDEV(height) OVER (PARTITION BY operator ORDER BY item_no 
				ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS stddev_height
			FROM manufacturing_parts) AS sub
		WHERE sub.row_number >= 5) AS sub_cl
