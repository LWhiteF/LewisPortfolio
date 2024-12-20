# Deep Diving Crypto Currencies

The aim is to understand the volitilty fo cryptocurrencies and try to find correlationary trends between major currencies in order to create a predictive model.

## The Dataset

```SQL
-- view limited data set, understand fields

SELECT*
FROM CryptoData
LIMIT 10;
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/1.jpeg)

### Volatility
Bitcoin is described as a volatile currency, making it a bad investment choice. <br>
Below we use calculations on 10 years of bitcoin data to find how the price deviates daily and annually.
We find that daily we can expect the price to deviate 4% from its starting position.
annually, we can expect the price to deviate from its starting position by 80%.<br>
The S&P500 Index has a Standard Deviation of approximatly 15% annually. Showing that Bitcoin is 5 times more volatile than traditional investment options.<br> 
<br>
What does this mean<br>
If we held Bitcoin for a year we could expect to see a gain or loss of 80% of our value by the end of that year. Bitcoin should not be considered for a long term investment approach.<br>
However, we are presented with a high risk, high reward trading opportunity.
```SQL
-- understand volatility of bitcoin daily and annually

SELECT stddev(interdaychangepercent) AS dailyvolatility,
		stddev(interdaychangepercent) * SQRT(365) AS annualvolatility
FROM (SELECT crypto_name,
		date,
		close,
		(close / LAG(close, 1) OVER(ORDER BY date)) - 1 AS interdaychangepercent
FROM CryptoData
WHERE crypto_name = 'Bitcoin');
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/2.JPG)

### Weekly Avarage Closing price
Here we use CTE's to create to find average weekly closing price for 4 major crypto currencies. By using CTE's we are able to create a direct comparison between each currency
side by side by joining them on their date bin.<br>
Some values are left as NULL as those currencies did not exist in those date ranges. we do not set these to null as we dont want them to skew later correlation calculations.
```SQL
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
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/3.JPG)

### Weekly Average Closing Price Correlation 
Created a temporary table, based upon the previous data, that compares how the weekly averages correlate<br>
As we can see Bitcoin and Ethereum correlate extremely strongly, Bitcoin and Ethereum Classic correlate fairly strongly and Bitcoin and Bitcoin Cash have no correlation.<br>
Ethereum and Bitcoin Cash have no correlation, where as Ethereum and Ethereum Classic have a strong relationship. <br>
Bitcoin Cash and Ethereum Classic have a weak positive relationship.
```SQL
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
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/4.JPG)

### Weekly Averages Offset
We modify the previous weekly average query to offset the prices of Ethereum, Ethereum Classic and Bitcoin Cash from Bitcoin by one week to see how this affects the relationship between the prices.
we do this by using the CTE's and a window function to Lag them by one position.
```SQL
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
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/5.JPG)

### Weekly Average Offset correlation.
By recreating the correlation table,
we can see that the offset prices do not have a significant change to the price correlation.

```SQL
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
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/6.JPG)

### Daily Prices Exploration
From the weekly explorations into cryptocurrency prices, we should dive deeper into the relationships between Bitcoin, Ethereum and Ethereum Classic.<br>
<br>
While the average close price weekly might have strong realtionships, how do the daily close prices correlate? 
```SQL
SELECT CORR(bitclose, ethclose)
FROM (SELECT c1.crypto_name, c1.date, c1.close AS bitclose, c2.close AS ethclose, c2.date, c2.crypto_name
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date=c2.date
		WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum') AS dailyclose;

SELECT CORR(ec_close, b_close)
FROM (SELECT c1.crypto_name, c1.date, c1.close AS ec_close, c2.close AS b_close, c2.date, c2.crypto_name
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date=c2.date
		WHERE c1.crypto_name = 'Ethereum Classic' AND c2.crypto_name = 'Bitcoin');

SELECT CORR(ec_close, e_close)
FROM (SELECT c1.crypto_name, c1.date, c1.close AS ec_close, c2.close AS e_close, c2.date, c2.crypto_name
		FROM CryptoData AS c1
		INNER JOIN CryptoData AS c2
		ON c1.date=c2.date
		WHERE c1.crypto_name = 'Ethereum Classic' AND c2.crypto_name = 'Ethereum');
```
| Bitcoin/Ethereum | Bitcoin/Ethereum Classic | Ethereum/Ethereum Classic |
| :--------------: | :----------------------: | :-----------------------: |
|0.9335806378080176|    0.7195929252612439    |    0.8440297895831277     |

As we can see the correlation relationships are strong between these three currencies, indicating that their markets are linked

```SQL
-- explore daily price changes of Bitcoin, Ethereum and Ethereum classic 

SELECT c1.date,
		(c1.close-c1.open) AS bit_change,
		(c2.close-c2.open) AS eth_change,
		(c3.close-c3.open) AS ecla_change
FROM CryptoData AS c1
INNER JOIN CryptoData AS c2
ON c1.date = c2.date
INNER JOIN CryptoData AS c3
ON c1.date = c3.date
WHERE c1.crypto_name = 'Bitcoin' AND c2.crypto_name = 'Ethereum' AND c3.crypto_name = 'Ethereum Classic'
ORDER BY c1.date;
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/7.JPG)

Use a subquery to pull this data into a correlation table. As we can see the price changes between Ethereum and Bitcoin have a strong positive relationship, we can leverage this to make day trades.
Should we see a significant dips or gains in Ethereum or Bitcoin, we can sell and buy the other coin with relative security that the prices trend together.

```SQL
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
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/2ac21a817198c30b12d76b02f0c2ec3f2018a855/Crypto%20project/Results/8.JPG)<br>

### Visualisations
To help visualise how closely these prices correlate, I took the data into R to generate graphs for Bitcoin and Ethereum for one year. As we can see, the shape of the closing price graphs for Bitcoin and Ethereum are extremely close, rising and falling in price in approximatly the same place.

```python
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# Read the Bitcoin CSV file
bitcoin_data = pd.read_csv('bitcoin.csv')

# Display the first few rows of the dataframe
bitcoin_data.head()

# Convert 'date' columns to datetime if they are not already
bitcoin_data['date'] = pd.to_datetime(bitcoin_data['date'])

# Define 50 day and 200 day moving averages
bitcoin_data['MA_7'] = bitcoin_data['close'].rolling(window=7).mean()
bitcoin_data['MA_50'] = bitcoin_data['close'].rolling(window=50).mean()
bitcoin_data['MA_200'] = bitcoin_data['close'].rolling(window=200).mean()


# Plot lin graph comparing close, MA_50 and MA_200
plt.figure(figsize=(10, 6))
plt.plot(bitcoin_data['date'], bitcoin_data['close'], label='Closing Price', color='blue')
plt.plot(bitcoin_data['date'], bitcoin_data['MA_50'], label='50-Day Moving Average', color='orange')
plt.plot(bitcoin_data['date'], bitcoin_data['MA_200'], label='200-Day Moving Average', color='red')

plt.title('Bitcoin Price with Moving Averages')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend()
plt.show()
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/0079234168ef451927b91ff48e7caac0d5d2b226/Crypto%20project/Results/BMA.png)
```python
# Read the Ethereum CSV file
ethereum_data = pd.read_csv('ethereum.csv')

# Convert 'date' columns to datetime if they are not already
ethereum_data['date'] = pd.to_datetime(ethereum_data['date'])
bitcoin_data['date'] = pd.to_datetime(bitcoin_data['date'])

# Display the first few rows of the dataframe
ethereum_data.head()

# Define 50 day and 200 day moving averages
ethereum_data['MA_7'] = ethereum_data['close'].rolling(window=7).mean()
ethereum_data['MA_50'] = ethereum_data['close'].rolling(window=50).mean()
ethereum_data['MA_200'] = ethereum_data['close'].rolling(window=200).mean()

# Plot line graph comparing close, MA_50 and MA_200
plt.figure(figsize=(10, 6))
plt.plot(ethereum_data['date'], ethereum_data['close'], label='Closing Price', color='blue')
plt.plot(ethereum_data['date'], ethereum_data['MA_50'], label='50-Day Moving Average', color='orange')
plt.plot(ethereum_data['date'], ethereum_data['MA_200'], label='200-Day Moving Average', color='red')

plt.title('Ethereum Price with Moving Averages')
plt.xlabel('Date')
plt.ylabel('Price')
plt.legend()
plt.show()
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/0079234168ef451927b91ff48e7caac0d5d2b226/Crypto%20project/Results/EMA.png)
```python
# Convert 'date' columns to datetime if they are not already
ethereum_data['date'] = pd.to_datetime(ethereum_data['date'])
bitcoin_data['date'] = pd.to_datetime(bitcoin_data['date'])

fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot Ethereum 200-Day Moving Average
ax1.plot(ethereum_data['date'], ethereum_data['MA_200'], label='Ethereum 200-Day Moving Average', color='red')
ax1.set_xlabel('Date')
ax1.set_ylabel('Ethereum Price', color='red')
ax1.tick_params(axis='y', labelcolor='red')

# Format x-axis to show only the year
ax1.xaxis.set_major_locator(mdates.YearLocator())
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))

# Create a second y-axis for Bitcoin
ax2 = ax1.twinx()
ax2.plot(bitcoin_data['date'], bitcoin_data['MA_200'], label='Bitcoin 200-Day Moving Average', color='blue')
ax2.set_ylabel('Bitcoin Price', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')

plt.title('Bitcoin vs Ethereum 200-Day Moving Averages')
fig.tight_layout()
plt.show()
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/0079234168ef451927b91ff48e7caac0d5d2b226/Crypto%20project/Results/BE200.png)
```python
# Convert 'date' columns to datetime if they are not already
ethereum_data['date'] = pd.to_datetime(ethereum_data['date'])
bitcoin_data['date'] = pd.to_datetime(bitcoin_data['date'])

fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot Ethereum 50-Day Moving Average
ax1.plot(ethereum_data['date'], ethereum_data['MA_50'], label='Ethereum 50-Day Moving Average', color='red')
ax1.set_xlabel('Date')
ax1.set_ylabel('Ethereum Price', color='red')
ax1.tick_params(axis='y', labelcolor='red')

# Format x-axis to show only the year
ax1.xaxis.set_major_locator(mdates.YearLocator())
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))

# Create a second y-axis for Bitcoin
ax2 = ax1.twinx()
ax2.plot(bitcoin_data['date'], bitcoin_data['MA_50'], label='Bitcoin 50-Day Moving Average', color='blue')
ax2.set_ylabel('Bitcoin Price', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')

plt.title('Bitcoin vs Ethereum 50-Day Moving Averages')
fig.tight_layout()
plt.show()
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/0079234168ef451927b91ff48e7caac0d5d2b226/Crypto%20project/Results/BE50.png)
```pyton
# Convert 'date' columns to datetime if they are not already
ethereum_data['date'] = pd.to_datetime(ethereum_data['date'])
bitcoin_data['date'] = pd.to_datetime(bitcoin_data['date'])

fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot Ethereum 7-Day Moving Average
ax1.plot(ethereum_data['date'], ethereum_data['MA_7'], label='Ethereum 7-Day Moving Average', color='red')
ax1.set_xlabel('Date')
ax1.set_ylabel('Ethereum Price', color='red')
ax1.tick_params(axis='y', labelcolor='red')

# Format x-axis to show only the year
ax1.xaxis.set_major_locator(mdates.YearLocator())
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))

# Create a second y-axis for Bitcoin
ax2 = ax1.twinx()
ax2.plot(bitcoin_data['date'], bitcoin_data['MA_7'], label='Bitcoin 7-Day Moving Average', color='blue')
ax2.set_ylabel('Bitcoin Price', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')

plt.title('Bitcoin vs Ethereum 7-Day Moving Averages')
fig.tight_layout()
plt.show()
```
![alt text](https://github.com/LWhiteF/LewisPortfolio/blob/0079234168ef451927b91ff48e7caac0d5d2b226/Crypto%20project/Results/BE7.png)

### Prediction
While Bitcoin, and cryptocurrencies generally, are a significantly volatile market, we can use the price changes in Bitcoin to predict changes in Ethereum. These currencies are extremely closely correlated in their price changes, especially on a 7 day moving average. Ethereums price changes mirror that of Bitcoin, though offset by a few days. We can use this infomation to manipulate our Ethereum holdings. if we see the price of bitcoin jump significantly, we should make a large Ethereum buy, expecting Ethereum to mirror Bitcoin's large price jump shortly after. Equally, if we see a significant downturn in Bitcoin prices, we should sell our Ethereum holdings.<br>
<br>
Below we bulit a model to test this hypothesis.

```python
# Initialize variables
initial_investment = 100
ethereum_investment = initial_investment
ethereum_holdings = 0

# Find the starting index for 30 July 2015
start_date = '2015-07-30'
start_index = bitcoin_data[bitcoin_data['date'] == start_date].index[0]

# Initialize the previous Bitcoin price
bitcoin_price_prev = bitcoin_data['MA_7'].iloc[start_index]

# Initialize a list to store weekly investment values
weekly_investment_values = []

# Iterate through the data starting from the start_index
for i in range(start_index + 1, min(len(bitcoin_data), len(ethereum_data))):
    bitcoin_price_current = bitcoin_data['MA_7'].iloc[i]
    ethereum_price_current = ethereum_data['MA_7'].iloc[i]
    
    # Calculate the percentage change in Bitcoin price
    price_change = (bitcoin_price_current - bitcoin_price_prev) / bitcoin_price_prev * 100
    
    # Buy Ethereum if Bitcoin price increases by 5%
    if price_change >= 5 and ethereum_investment > 0:
        ethereum_holdings += ethereum_investment / ethereum_price_current
        ethereum_investment = 0
    
    # Sell Ethereum if Bitcoin price drops by 10%
    elif price_change <= -10 and ethereum_holdings > 0:
        ethereum_investment += ethereum_holdings * ethereum_price_current
        ethereum_holdings = 0
    
    # Update the previous Bitcoin price
    bitcoin_price_prev = bitcoin_price_current
    
    # Check if the current date is the end of a week (i.e., Sunday)
    if bitcoin_data['date'].iloc[i].weekday() == 6:
        # Calculate the current value of the investment
        current_value = ethereum_investment + (ethereum_holdings * ethereum_price_current)
        weekly_investment_values.append((bitcoin_data['date'].iloc[i], current_value))

# Convert the list to a DataFrame for better visualization
weekly_investment_df = pd.DataFrame(weekly_investment_values, columns=['Date', 'Investment Value'])

weekly_investment_df
```
|Date                   |Investment Value|
|-----------------------|----------------|
|2015-08-02T00:00:00.000|100             |
|2015-08-09T00:00:00.000|100             |
|2015-08-16T00:00:00.000|100             |
|2015-08-23T00:00:00.000|100             |
|2015-08-30T00:00:00.000|100             |
|2015-09-06T00:00:00.000|100             |
|2015-09-13T00:00:00.000|100             |
|2015-09-20T00:00:00.000|100             |
|2015-09-27T00:00:00.000|100             |
|2015-10-04T00:00:00.000|100             |
|2015-10-11T00:00:00.000|100             |
|2015-10-18T00:00:00.000|100             |
|2015-10-25T00:00:00.000|100             |
|2015-11-01T00:00:00.000|100             |
|2015-11-08T00:00:00.000|100             |
|2015-11-15T00:00:00.000|100             |
|2015-11-22T00:00:00.000|100             |
|2015-11-29T00:00:00.000|100             |
|2015-12-06T00:00:00.000|100             |
|2015-12-13T00:00:00.000|100             |
|2015-12-20T00:00:00.000|100             |
|2015-12-27T00:00:00.000|100             |
|2016-01-03T00:00:00.000|100             |
|2016-01-10T00:00:00.000|100             |
|2016-01-17T00:00:00.000|100             |
|2016-01-24T00:00:00.000|100             |
|2016-01-31T00:00:00.000|100             |
|2016-02-07T00:00:00.000|100             |
|2016-02-14T00:00:00.000|100             |
|2016-02-21T00:00:00.000|100             |
|2016-02-28T00:00:00.000|100             |
|2016-03-06T00:00:00.000|100             |
|2016-03-13T00:00:00.000|100             |
|2016-03-20T00:00:00.000|100             |
|2016-03-27T00:00:00.000|100             |
|2016-04-03T00:00:00.000|100             |
|2016-04-10T00:00:00.000|100             |
|2016-04-17T00:00:00.000|100             |
|2016-04-24T00:00:00.000|100             |
|2016-05-01T00:00:00.000|100             |
|2016-05-08T00:00:00.000|100             |
|2016-05-15T00:00:00.000|100             |
|2016-05-22T00:00:00.000|100             |
|2016-05-29T00:00:00.000|100             |
|2016-06-05T00:00:00.000|100             |
|2016-06-12T00:00:00.000|100             |
|2016-06-19T00:00:00.000|100             |
|2016-06-26T00:00:00.000|100             |
|2016-07-03T00:00:00.000|100             |
|2016-07-10T00:00:00.000|100             |
|2016-07-17T00:00:00.000|100             |
|2016-07-24T00:00:00.000|100             |
|2016-07-31T00:00:00.000|100             |
|2016-08-07T00:00:00.000|100             |
|2016-08-14T00:00:00.000|100             |
|2016-08-21T00:00:00.000|100             |
|2016-08-28T00:00:00.000|100             |
|2016-09-04T00:00:00.000|100             |
|2016-09-11T00:00:00.000|100             |
|2016-09-18T00:00:00.000|100             |
|2016-09-25T00:00:00.000|100             |
|2016-10-02T00:00:00.000|100             |
|2016-10-09T00:00:00.000|100             |
|2016-10-16T00:00:00.000|100             |
|2016-10-23T00:00:00.000|100             |
|2016-10-30T00:00:00.000|100             |
|2016-11-06T00:00:00.000|100             |
|2016-11-13T00:00:00.000|100             |
|2016-11-20T00:00:00.000|100             |
|2016-11-27T00:00:00.000|100             |
|2016-12-04T00:00:00.000|100             |
|2016-12-11T00:00:00.000|100             |
|2016-12-18T00:00:00.000|100             |
|2016-12-25T00:00:00.000|100             |
|2017-01-01T00:00:00.000|100             |
|2017-01-08T00:00:00.000|100             |
|2017-01-15T00:00:00.000|100             |
|2017-01-22T00:00:00.000|100             |
|2017-01-29T00:00:00.000|100             |
|2017-02-05T00:00:00.000|100             |
|2017-02-12T00:00:00.000|100             |
|2017-02-19T00:00:00.000|100             |
|2017-02-26T00:00:00.000|100             |
|2017-03-05T00:00:00.000|100             |
|2017-03-12T00:00:00.000|100             |
|2017-03-19T00:00:00.000|100             |
|2017-03-26T00:00:00.000|100             |
|2017-04-02T00:00:00.000|100             |
|2017-04-09T00:00:00.000|100             |
|2017-04-16T00:00:00.000|100             |
|2017-04-23T00:00:00.000|100             |
|2017-04-30T00:00:00.000|100             |
|2017-05-07T00:00:00.000|100             |
|2017-05-14T00:00:00.000|100             |
|2017-05-21T00:00:00.000|100             |
|2017-05-28T00:00:00.000|100             |
|2017-06-04T00:00:00.000|100             |
|2017-06-11T00:00:00.000|100             |
|2017-06-18T00:00:00.000|100             |
|2017-06-25T00:00:00.000|100             |
|2017-07-02T00:00:00.000|100             |
|2017-07-09T00:00:00.000|100             |
|2017-07-16T00:00:00.000|100             |
|2017-07-23T00:00:00.000|100             |
|2017-07-30T00:00:00.000|100             |
|2017-08-06T00:00:00.000|100             |
|2017-08-13T00:00:00.000|100             |
|2017-08-20T00:00:00.000|100             |
|2017-08-27T00:00:00.000|100             |
|2017-09-03T00:00:00.000|100             |
|2017-09-10T00:00:00.000|100             |
|2017-09-17T00:00:00.000|100             |
|2017-09-24T00:00:00.000|100             |
|2017-10-01T00:00:00.000|100             |
|2017-10-08T00:00:00.000|100             |
|2017-10-15T00:00:00.000|100             |
|2017-10-22T00:00:00.000|100             |
|2017-10-29T00:00:00.000|100             |
|2017-11-05T00:00:00.000|100             |
|2017-11-12T00:00:00.000|100             |
|2017-11-19T00:00:00.000|100             |
|2017-11-26T00:00:00.000|100             |
|2017-12-03T00:00:00.000|100             |
|2017-12-10T00:00:00.000|72.3473782446   |
|2017-12-17T00:00:00.000|57.3151759401   |
|2017-12-24T00:00:00.000|62.2110645372   |
|2017-12-31T00:00:00.000|64.6154044715   |
|2018-01-07T00:00:00.000|76.5732247525   |
|2018-01-14T00:00:00.000|78.1657257714   |
|2018-01-21T00:00:00.000|85.8031237788   |
|2018-01-28T00:00:00.000|96.8011226439   |
|2018-02-04T00:00:00.000|94.252056679    |
|2018-02-11T00:00:00.000|93.404763872    |
|2018-02-18T00:00:00.000|95.8930202807   |
|2018-02-25T00:00:00.000|104.1509848698  |
|2018-03-04T00:00:00.000|112.6907135237  |
|2018-03-11T00:00:00.000|110.30823953    |
|2018-03-18T00:00:00.000|107.9612825205  |
|2018-03-25T00:00:00.000|106.1130981466  |
|2018-04-01T00:00:00.000|108.7381715056  |
|2018-04-08T00:00:00.000|111.58897216    |
|2018-04-15T00:00:00.000|111.5833668926  |
|2018-04-22T00:00:00.000|140.7572259452  |
|2018-04-29T00:00:00.000|173.2171741421  |
|2018-05-06T00:00:00.000|180.712711347   |
|2018-05-13T00:00:00.000|198.3452177578  |
|2018-05-20T00:00:00.000|183.6630072003  |
|2018-05-27T00:00:00.000|196.0953966355  |
|2018-06-03T00:00:00.000|164.7727402384  |
|2018-06-10T00:00:00.000|173.920596983   |
|2018-06-17T00:00:00.000|165.5263647377  |
|2018-06-24T00:00:00.000|165.2246695967  |
|2018-07-01T00:00:00.000|161.2164071099  |
|2018-07-08T00:00:00.000|174.7927034169  |
|2018-07-15T00:00:00.000|176.8329271685  |
|2018-07-22T00:00:00.000|185.6717548773  |
|2018-07-29T00:00:00.000|185.9107101679  |
|2018-08-05T00:00:00.000|210.8543358525  |
|2018-08-12T00:00:00.000|219.2817137751  |
|2018-08-19T00:00:00.000|260.2384326101  |
|2018-08-26T00:00:00.000|275.6164350497  |
|2018-09-02T00:00:00.000|264.8253358822  |
|2018-09-09T00:00:00.000|288.8212528165  |
|2018-09-16T00:00:00.000|287.650947532   |
|2018-09-23T00:00:00.000|355.3958677698  |
|2018-09-30T00:00:00.000|544.9843652693  |
|2018-10-07T00:00:00.000|571.2096471747  |
|2018-10-14T00:00:00.000|599.3826035982  |
|2018-10-21T00:00:00.000|651.3325022662  |
|2018-10-28T00:00:00.000|786.2634736767  |
|2018-11-04T00:00:00.000|838.7140897978  |
|2018-11-11T00:00:00.000|843.729505544   |
|2018-11-18T00:00:00.000|691.2671394966  |
|2018-11-25T00:00:00.000|809.3165306167  |
|2018-12-02T00:00:00.000|848.3903922625  |
|2018-12-09T00:00:00.000|794.2920654421  |
|2018-12-16T00:00:00.000|889.6446400729  |
|2018-12-23T00:00:00.000|966.699763364   |
|2018-12-30T00:00:00.000|1082.0223921402 |
|2019-01-06T00:00:00.000|1065.4397660441 |
|2019-01-13T00:00:00.000|1241.6360715483 |
|2019-01-20T00:00:00.000|1622.439590048  |
|2019-01-27T00:00:00.000|1755.7766094988 |
|2019-02-03T00:00:00.000|1199.8043996494 |
|2019-02-10T00:00:00.000|1196.4918538012 |
|2019-02-17T00:00:00.000|1225.0982781511 |
|2019-02-24T00:00:00.000|1134.7659206761 |
|2019-03-03T00:00:00.000|954.1809228458  |
|2019-03-10T00:00:00.000|944.3558138704  |
|2019-03-17T00:00:00.000|1037.5591433252 |
|2019-03-24T00:00:00.000|931.0434359454  |
|2019-03-31T00:00:00.000|941.352120004   |
|2019-04-07T00:00:00.000|1126.8322676523 |
|2019-04-14T00:00:00.000|1364.3400480971 |
|2019-04-21T00:00:00.000|1494.0376129552 |
|2019-04-28T00:00:00.000|1494.7903457175 |
|2019-05-05T00:00:00.000|1636.6227600761 |
|2019-05-12T00:00:00.000|1668.3555841331 |
|2019-05-19T00:00:00.000|1593.3003422146 |
|2019-05-26T00:00:00.000|1373.4393768615 |
|2019-06-02T00:00:00.000|1528.1983275328 |
|2019-06-09T00:00:00.000|1678.3114526525 |
|2019-06-16T00:00:00.000|1882.9231059275 |
|2019-06-23T00:00:00.000|1979.6331858941 |
|2019-06-30T00:00:00.000|2141.8792730008 |
|2019-07-07T00:00:00.000|2101.1748748742 |
|2019-07-14T00:00:00.000|1963.2267045962 |
|2019-07-21T00:00:00.000|2009.3038109529 |
|2019-07-28T00:00:00.000|1964.9457607904 |
|2019-08-04T00:00:00.000|1826.7232435651 |
|2019-08-11T00:00:00.000|1793.508493768  |
|2019-08-18T00:00:00.000|1553.6484159946 |
|2019-08-25T00:00:00.000|1518.937951892  |
|2019-09-01T00:00:00.000|1173.9112907502 |
|2019-09-08T00:00:00.000|1347.4501776376 |
|2019-09-15T00:00:00.000|1398.7441638742 |
|2019-09-22T00:00:00.000|1247.3932337395 |
|2019-09-29T00:00:00.000|1251.5336577929 |
|2019-10-06T00:00:00.000|1242.8495839754 |
|2019-10-13T00:00:00.000|1424.7521636729 |
|2019-10-20T00:00:00.000|1551.294680832  |
|2019-10-27T00:00:00.000|1422.0793166025 |
|2019-11-03T00:00:00.000|1333.0995840379 |
|2019-11-10T00:00:00.000|1006.2937542133 |
|2019-11-17T00:00:00.000|875.3277585365  |
|2019-11-24T00:00:00.000|558.6979060711  |
|2019-12-01T00:00:00.000|566.7751217198  |
|2019-12-08T00:00:00.000|780.223448778   |
|2019-12-15T00:00:00.000|750.4824061788  |
|2019-12-22T00:00:00.000|668.1002430825  |

As we can see, historically, we could make some significant gains using this method, however we are still susceptible to market losses. 

