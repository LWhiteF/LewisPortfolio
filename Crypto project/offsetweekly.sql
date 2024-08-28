--set avg weekly close for 'Ethereum Classic', 'Bitcoin', 'Bitcoin Cash' and 'Ethereum' as cte using date bin

WITH bw AS
	(SELECT 
		date_bin('1 week', timestamp, '2013-05-05 23:59:59.999') AS b_weekly,
		crypto_name,
	   	ROUND(AVG(close), 2) AS bitcoin_close
	FROM CryptoData
	WHERE crypto_name = 'Bitcoin'
	GROUP BY crypto_name, b_weekly
	ORDER BY b_weekly),
	
ew AS 
	(SELECT 
	   date_bin('1 week', timestamp, '2013-05-05 23:59:59.999') AS e_weekly,
	   crypto_name,
	   ROUND(AVG(close), 2) AS ethereum_close
	FROM CryptoData
	WHERE crypto_name = 'Ethereum'
	GROUP BY crypto_name, e_weekly
	ORDER BY e_weekly),

bcw AS
	(SELECT 
	   date_bin('1 week', timestamp, '2013-05-05 23:59:59.999') AS bcw_weekly,
	   crypto_name,
	   ROUND(AVG(close), 2) AS bit_cash_close
	FROM CryptoData
	WHERE crypto_name = 'Bitcoin Cash'
	GROUP BY crypto_name, bcw_weekly
	ORDER BY bcw_weekly),
	
ecw AS
	(SELECT 
	   date_bin('1 week', timestamp, '2013-05-05 23:59:59.999') AS ecw_weekly,
	   crypto_name,
	   ROUND(AVG(close), 2) AS eth_cla_close
	FROM CryptoData
	WHERE crypto_name = 'Ethereum Classic'
	GROUP BY crypto_name, ecw_weekly
	ORDER BY ecw_weekly)

SELECT bw.b_weekly,
		bw.bitcoin_close,
		LAG(ew.ethereum_close, 1) OVER(ORDER BY bw.b_weekly) AS eth_offset,
		LAG(bcw.bit_cash_close, 1) OVER(ORDER BY bw.b_weekly) AS b_cash_offset,
		LAG(ecw.eth_cla_close, 1) OVER(ORDER BY bw.b_weekly) AS e_cla_offset
FROM bw
FULL JOIN ew
ON bw.b_weekly = ew.e_weekly
FULL JOIN bcw
ON bw.b_weekly = bcw.bcw_weekly
FULL JOIN ecw
ON bw.b_weekly = ecw.ecw_weekly
ORDER BY bw.b_weekly