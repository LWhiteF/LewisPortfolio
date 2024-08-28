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
		WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum' AND c3.crypto_name = 'Ethereum Classic')