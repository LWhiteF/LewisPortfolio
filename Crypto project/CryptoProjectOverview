-- view limited data set, understand fields

SELECT*
FROM CryptoData
LIMIT 10;

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/1.jpeg)

-- understand volatility of bitcoin daily and annually

SELECT stddev(interdaychangepercent) AS dailyvolatility,
		stddev(interdaychangepercent) * SQRT(365) AS annualvolatility
FROM (SELECT crypto_name,
		date,
		close,
		(close / LAG(close, 1) OVER(ORDER BY date)) - 1 AS interdaychangepercent
FROM CryptoData
WHERE crypto_name = 'Bitcoin');

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/2.JPG)

-- Create CTE with weekly average close prices for Eth, Eth Classic, Bitcoin and Bitcoin cash
-- Join CTEs for easier comparison

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
		ew.ethereum_close,
		bcw.bit_cash_close,
		ecw.eth_cla_close
FROM bw
FULL JOIN ew
ON bw.b_weekly = ew.e_weekly
FULL JOIN bcw
ON bw.b_weekly = bcw.bcw_weekly
FULL JOIN ecw
ON bw.b_weekly = ecw.ecw_weekly
ORDER BY bw.b_weekly;

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/3.JPG)

-- build a temp correlation table

CREATE TEMP TABLE correlation AS
SELECT 'bitcoin'::varchar AS crypto,
		CORR(bitcoin_close, bitcoin_close) AS bitcoin,
		CORR(bitcoin_close, ethereum_close) AS ethereum,
		CORR(bitcoin_close, bit_cash_close) AS bitcoin_cash,
		CORR(bitcoin_close, eth_cla_close) AS ethereum_classic
FROM weekly_result;

INSERT INTO correlation
SELECT 'ethereum'::varchar AS crypto,
		CORR(ethereum_close, bitcoin_close) AS bitcoin,
		CORR(ethereum_close, ethereum_close) AS ethereum,
		CORR(ethereum_close, bit_cash_close) AS bitcoin_cash,
		CORR(ethereum_close, eth_cla_close) AS ethereum_classic
FROM weekly_result;

INSERT INTO correlation
SELECT 'bitcoin_cash'::varchar AS crypto,
		CORR(bit_cash_close, bitcoin_close) AS bitcoin,
		CORR(bit_cash_close, ethereum_close) AS ethereum,
		CORR(bit_cash_close, bit_cash_close) AS bitcoin_cash,
		CORR(bit_cash_close, eth_cla_close) AS ethereum_classic
FROM weekly_result;

INSERT INTO correlation
SELECT 'ethereum_classic'::varchar AS crypto,
		CORR(eth_cla_close, bitcoin_close) AS bitcoin,
		CORR(eth_cla_close, ethereum_close) AS ethereum,
		CORR(eth_cla_close, bit_cash_close) AS bitcoin_cash,
		CORR(eth_cla_close, eth_cla_close) AS ethereum_classic
FROM weekly_result;

SELECT crypto, 
       ROUND(bitcoin::numeric, 2) AS bitcoin,
       ROUND(ethereum::numeric, 2) AS ethereum,
       ROUND(bitcoin_cash::numeric, 2) AS bitcoin_cash,
	   ROUND(ethereum_classic::numeric, 2) AS ethereum_classic
  FROM correlation;

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/4.JPG)

-- build offset table based on previos CTE template

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
ORDER BY bw.b_weekly;

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/5.JPG)

-- Create temp correlation table for weekly offset prices

CREATE TEMP TABLE correlation_offset AS
SELECT 'bitcoin'::varchar AS crypto,
		CORR(bitcoin_close, bitcoin_close) AS bitcoin,
		CORR(bitcoin_close, eth_offset) AS ethereum_o,
		CORR(bitcoin_close, b_cash_offset) AS bitcoin_cash_o,
		CORR(bitcoin_close, e_cla_offset) AS ethereum_classic_o
FROM weeklyoffset;

INSERT INTO correlation_offset
SELECT 'ethereum_o'::varchar AS crypto,
		CORR(eth_offset, bitcoin_close) AS bitcoin,
		CORR(eth_offset, eth_offset) AS ethereum_o,
		CORR(eth_offset, b_cash_offset) AS bitcoin_cash_o,
		CORR(eth_offset, e_cla_offset) AS ethereum_classic_o
FROM weeklyoffset;

INSERT INTO correlation_offset
SELECT 'bitcoin_cash_o'::varchar AS crypto,
		CORR(b_cash_offset, bitcoin_close) AS bitcoin,
		CORR(b_cash_offset, eth_offset) AS ethereum_o,
		CORR(b_cash_offset, b_cash_offset) AS bitcoin_cash_o,
		CORR(b_cash_offset, e_cla_offset) AS ethereum_classic_o
FROM weeklyoffset;

INSERT INTO correlation_offset
SELECT 'ethereum_classic_o'::varchar AS crypto,
		CORR(e_cla_offset, bitcoin_close) AS bitcoin,
		CORR(e_cla_offset, eth_offset) AS ethereum_o,
		CORR(e_cla_offset, b_cash_offset) AS bitcoin_cash_o,
		CORR(e_cla_offset, e_cla_offset) AS ethereum_classic_o
FROM weeklyoffset;

SELECT crypto, 
       ROUND(bitcoin::numeric, 2) AS bitcoin,
       ROUND(ethereum_o::numeric, 2) AS ethereum_o,
       ROUND(bitcoin_cash_o::numeric, 2) AS bitcoin_cash_o,
	   ROUND(ethereum_classic_o::numeric, 2) AS ethereum_classic_o
  FROM correlation_offset;

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/6.JPG)

-- explore daily close price correlation for bitcoin and eth

SELECT CORR(bitclose, ethclose)
FROM (SELECT c1.crypto_name, c1.date, c1.close AS bitclose, c2.close AS ethclose, c2.date, c2.crypto_name
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date=c2.date
		WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum');

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/7.JPG)

-- Explore correlation for daily price change

SELECT CORR(bit_change, eth_change) AS bit_eth,
		CORR(bit_change, ecla_change) AS bit_ecla,
		CORR(eth_change, ecla_change) AS eth_ecla
FROM (SELECT (c1.close-c1.open) AS bit_change,
	  		 (c2.close-c2.open) AS eth_change,
	  		 (c3.close-c3.open) AS ecla_change
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date = c2.date
	    INNER JOIN CryptoData AS c3
	    ON c1.date = c3.date
		WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum' AND c3.crypto_name = 'Ethereum Classic';

![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/8.JPG)
