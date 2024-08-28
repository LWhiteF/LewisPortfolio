SELECT c1.crypto_name, c1.date, c1.close, c2.close, c2.date, c2.crypto_name
FROM CryptoData AS c1
INNER JOIN CryptoData AS c2
ON c1.date=c2.date
WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum'
