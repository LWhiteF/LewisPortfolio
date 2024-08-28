SELECT CORR(ec_close, b_close)
FROM (SELECT c1.crypto_name, c1.date, c1.close AS ec_close, c2.close AS b_close, c2.date, c2.crypto_name
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date=c2.date
		WHERE c1.crypto_name = 'Ethereum Classic' AND c2.crypto_name = 'Bitcoin')
