
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