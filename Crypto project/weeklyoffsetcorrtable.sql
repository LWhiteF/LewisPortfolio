
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