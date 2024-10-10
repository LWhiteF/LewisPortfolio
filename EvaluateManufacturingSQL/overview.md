# Scenario:
https://www.datacamp.com/datalab/w/7747652b-a299-4b2c-a598-d4df44a76aab/edit

Manufacturing processes for any product is like putting together a puzzle. Products are pieced together step by step, and keeping a close eye on the process is important.<br>
<br>
For this project, you're supporting a team that wants to improve how they monitor and control a manufacturing process. The goal is to implement a more methodical approach known as statistical process control (SPC). SPC is an established strategy that uses data to determine whether the process works well. Processes are only adjusted if measurements fall outside of an acceptable range.<br>
<br>
This acceptable range is defined by an upper control limit (UCL) and a lower control limit (LCL), the formulas for which are:<br><br>
$ucl = avgheight + 3 * \frac{stddevheight}{\sqrt{5}}$

$lcl = avgheight - 3 * \frac{stddevheight}{\sqrt{5}}$
<br><br>
The UCL defines the highest acceptable height for the parts, while the LCL defines the lowest acceptable height for the parts. Ideally, parts should fall between the two limits.<br>
<br>
Using SQL window functions and nested queries, you'll analyze historical manufacturing data to define this acceptable range and identify any points in the process that fall outside of the range and therefore require adjustments. This will ensure a smooth running manufacturing process consistently making high-quality products.<br>
<br>
The data<br>
The data is available in the manufacturing_parts table which has the following fields:<br>
<br>
item_no: the item number<br>
length: the length of the item made<br>
width: the width of the item made<br>
height: the height of the item made<br>
operator: the operating machine<br>
<br>
## Solution; CTE
```SQL
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
```
## Solution; Subquery
```SQL
SELECT sub_cl.*,
		CASE WHEN sub_cl.height NOT BETWEEN sub_cl.lcl AND  sub_cl.ucl
		THEN TRUE
		ELSE FALSE
		END AS alert
FROM	(SELECT sub.*,
				sub.avg_height + 3*sub.stddev_height/SQRT(5) AS ucl,
				sub.avg_height - 3*sub.stddev_height/SQRT(5) AS lcl
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
```
