# Powerlifting Sponsorship Candidates
A fictional Powerlifting Equipment company, based in England, is looking for atheletes to sponsor to get visibility on their brand.<br>
They want a list of potential candidates that will boost the brands profile and associate the brand with strength. We can use the International Powerlifting Federation Records, which date back to February 1966 and are regularly updated. 

### Strongest Worldwide Lifters
The company first asks for a list of the strongest lifters from the countries in which powerlifting already has a significant audience. <br>
<br>
First, we can assess where powerlifting is a popular sport by creating a list of countries and counting the number of records from that country. We only want to see the 10 most popular countries
to find candidates

```SQL
SELECT country,
       count(*)
FROM ipfrecords
WHERE country IS NOT NULL
GROUP BY country
ORDER BY COUNT(*) DESC
LIMIT 10
```
We can use this as a subqueary to limit our potential candidates. Next we want to create a ranking for the strongest athletes in each weightclass and gender based upon their competition totals.
We want to ignore candidates who have had a reported total as this indicates that they failed to achieve a succesful lift within on of the catergories (Squat, Bench Or Deadlift) and this wouldn't
provide a good image of strength for the brand. We also want to ensure that the individuals we approach have competed recently, so we limit our search to after January 1, 2019.
```SQL
SELECT name,
  country,
  sex,
  weightclasskg,
  totalkg,
  RANK() OVER(PARTITION BY weightclasskg, sex ORDER BY totalkg DESC)
FROM ipfrecords
WHERE date >= '2019-01-01' AND totalkg IS NOT NULL AND country IN (SELECT country
                                                                  FROM (SELECT country,
                                                                    count(*)
                                                                    FROM ipfrecords
                                                                    WHERE country IS NOT NULL
                                                                    GROUP BY country
                                                                    ORDER BY COUNT(*) DESC
                                                                    LIMIT 10))
```

Finally we only want to see the 10 strongest lifters in each weightclass, for both genders. we see that a number of entries do not report a weightclass, and upon further investigation, it is found that 
some smaller local competitons do not divide competitors by weightclass, so it is not likely that these entries would not provide a good guage of these lifters relative strength. <br>
We find that some individuals competed succesfully within a number of different weightclasses and countries so we need to create a list with no athlete redundencies.
```SQL
SELECT distinct on (name) 
name, country, weightclasskg
FROM (SELECT name,
	country,
	sex,
	weightclasskg,
	totalkg,
	RANK() OVER(PARTITION BY weightclasskg, sex ORDER BY totalkg DESC)
	FROM ipfrecords
	WHERE date >= '2019-01-01' AND totalkg IS NOT NULL AND country IN (SELECT country
										FROM (SELECT country,
											count(*)
											FROM ipfrecords
											WHERE country IS NOT NULL
											GROUP BY country
											ORDER BY COUNT(*) DESC
											LIMIT 10)))
WHERE rank <= 10 AND weightclasskg IS NOT NULL
ORDER BY name
```

This Presents us with a list of 174 athletes, ranked top ten by weightclass and gender, in the ten most popular powerlifting countries.

[Global Athletes to Sponsor](https://github.com/LWhiteF/LewisPortfolio/blob/61320d758adcc2e095cbcd3b09f1d8089c2272bd/Powerlifting%20Sponsorships/GlobalAtheletestoSponsor.csv)

Seeing a lot of American and Russian athletes on the list, the company asks for a breakdown of the location of the athletes.

[Distrubution of Athletes:](https://github.com/LWhiteF/LewisPortfolio/blob/6fb96132ff61392d19adbec8136d7c79bb4b1a6d/Powerlifting%20Sponsorships/GlobalAthletesPerc.csv)
|Country|Total|Percentage(rounded)|
|:---:|:---:|:---:|
|Finland|1|0.6|
|Ukraine|16|9.2|
|USA|64|36.8|
|Germany|17|9.8|
|Canada|8|4.6|
|England|2|1.1|
|Russia|50|28.7|
|Norway|5|2.9|
|Czechia|11|6.3|

### European Sponsorship Candidates
Unhappy that so few candidates are local to the English country, they have asked that we focus our search to Western Europe.<br>
They also wish to change tact, and find candidates that have competed at least 3 times in the last 5 years, are ranked at least 25th for strength in their respective weightclass for their gender.<br>
<br>
We start by creating a list of european countries, which is crossreferenced against countries that have competition records. Set it up as a CTE to be used as a filter<br>
<br>
Next we pull relevant fields, create a ranking of lift total within weightclass and gender using a RANK() window fuction, as before.<br>
We also use the ROW_NUMBER() window function partitioned by name to count how many times an athlete has competed.<br>
We filter our records using an innerjoin of our 'eu' CTE and limit the records to no earlier than January 1, 2019, while eliminating NULL weightclass and Total records.<br>
we then set this up as another CTE called 'shortlist' from which we can create a distinct list of names, who have competed at least 3 times and are ranked at least 25th by total in their respective categories.

```SQL
WITH eu AS (SELECT DISTINCT country
            FROM ipfrecords
            WHERE country IN('Belgium', 'England', 'France', 'Germany',
                              'Ireland', 'Italy', 'Netherlands', 'Norway',
                              'Scotland', 'UK', 'Wales')),
								 
shortlist AS (SELECT name,
              sex,
              date,
              ipfrecords.country,
              weightclasskg,
              totalkg,
              RANK() OVER(PARTITION BY weightclasskg, sex ORDER BY totalkg DESC),
              ROW_NUMBER() OVER(PARTITION BY name) AS competitions
              FROM ipfrecords
              INNER JOIN eu
              ON ipfrecords.country = eu.country
              WHERE date >= '2019-01-01' AND totalkg IS NOT NULL AND weightclasskg IS NOT NULL)
					
SELECT distinct on (name) 
  name, sex, country
FROM shortlist
WHERE competitions >= 3 AND rank <=25
ORDER BY name, country;
```
This presents a list of 132 sponsorship candidates that fit within the companies new criteria, ranking at least 25th for strength in their respective weightclass and genders, while also having competed successfully at least 3 times within the past 5 years.

[European Athletes to Sponsor](https://github.com/LWhiteF/LewisPortfolio/blob/ce81c616f3df73b4196862c34e2457158d32ba9d/Powerlifting%20Sponsorships/EuropeanAthletestoSponsor.csv)

To ensure the company is happy with the location of these athletes we again find the proportional representation.

[Distrubution of Athletes in Europe:](https://github.com/LWhiteF/LewisPortfolio/blob/ce81c616f3df73b4196862c34e2457158d32ba9d/Powerlifting%20Sponsorships/EuropeanAthletesPerc.csv)
|Country|Count|Percentage(Rounded)|
|:---:|:---:|:---:|
|Ireland|10|7.6|
|France|19|14.4|
|Netherlands|5|3.8|
|UK|1|0.8|
|Belgium|4|3|
|Italy|19|14.4|
|Germany|28|21.2|
|England|22|16.7|
|Norway|24|18.2|

## Further Analysis
### Future English Prospects
Further analysis shows some hopeful prospects for sponsorship. we have looked at individuals who have competed in England more than 5 times in 2024, successfully completing all three events and having a total recorded.
```SQL
WITH competition AS (SELECT name,
				weightclasskg,
				sex,
				date,
				best3squatkg,
				best3benchkg,
				best3deadliftkg,
				totalkg,
				ROW_NUMBER() OVER(PARTITION BY name ORDER BY date) AS comps
			FROM ipfrecords
			WHERE date >= '2024-01-01' AND country = 'England' AND event = 'SBD'
			ORDER BY name, date)


SELECT distinct on (name)
name, weightclasskg, sex
FROM competition
WHERE competition IS NOT NULL AND comps>=5
ORDER BY name, date
```
[Outcome](https://github.com/LWhiteF/LewisPortfolio/blob/72ec39625be86d1414560f919502b07aa8137ff3/Powerlifting%20Sponsorships/2024SBDEng.csv)<br>
As Shown, there are 10 names that fit our criteria, when crossreferenced with our athletes in europe, 1 is already in the shortlist to be sponsored. However that still leaves 9 future prospects to be monitored for sponsorship. Successfully competing 5 times in one year shows a high drive, and passion for powerlifting.

### Growth and Target Audience
It is important that we consider how powerlifting has grown, and the ratio of athletes by gender, as this may have an effect on who we sponsor and how we market out products.
```SQL
SELECT *,
	ROUND((competitors/totalyear)*100,1) AS Percentage
FROM(SELECT *,
		SUM(competitors) OVER(PARTITION BY yearly) AS totalyear
	FROM (SELECT CAST(DATE_TRUNC('year', date) AS date) AS yearly,
			sex,
			COUNT(*) AS competitors
		FROM ipfrecords
		GROUP BY yearly, sex
		ORDER BY yearly, sex));
```
[Outcome](https://github.com/LWhiteF/LewisPortfolio/blob/ed0b8735624eeaf7e73c2fc3a01e14d66c2f8829/Powerlifting%20Sponsorships/GenderSplit.csv)<br>

![alttext](https://github.com/LWhiteF/LewisPortfolio/blob/ed0b8735624eeaf7e73c2fc3a01e14d66c2f8829/Powerlifting%20Sponsorships/graphs.JPG)<br>

We can see through this visualisation that powerlifting has grown from a male dominated sport to an approximatly 66/33% male/female split. we are also begining to see gender neutral competitors, though currently
accounting for <1% of yearly competitors.<br>
Powerlifting has also been growing exponentially. The dip seen in 1986 is caused by the formation of new powerlifting federations, whose data is not included in IPF records. The dip in 2020 was caused
by shutdowns due to covid, and finally 2024 is incomplete.

### Career Length
It is important to consider how long individuals spend competing in powerlifing, by looking at when an athlete first competed and comparing it with when they most recently competed, and disregarding individuals who only competed once we can take an average. This is important as it gives a rough metric of how often we need to be contracting new talent.

```SQL
WITH datediff AS(SELECT name, 
		MAX(date) - MIN(date) AS dayscompeting
		FROM ipfrecords
		GROUP BY name)
				
SELECT ROUND(AVG(dayscompeting),2) AS averagecareer
FROM datediff
WHERE dayscompeting != 0
```
|Average Career|
|:---:|
|1338.82|

looking at all 58 years of records, we find that the average is 1338.82 days, or approximatly 3 Years 7 Months.<br>
We should take this into consideration when setting up contracts for sponsorship, as we may contract individuals that are coming to an end of their competiton life.<br>
<br>
By modifying the previous query, we can find the percentage of competitors that only compete once

```SQL
WITH datediff AS(SELECT name, 
				MAX(date) - MIN(date) AS dayscompeting
				FROM ipfrecords
				GROUP BY name)

SELECT dayscompeting, 
		COUNT(*) AS total,
 		COUNT(*)/SUM(COUNT(*)) OVER() AS percentage
FROM datediff
Group By dayscompeting
ORDER BY dayscompeting
```
[Outcome](https://github.com/LWhiteF/LewisPortfolio/blob/30a48599b3ab6d9c252e37f0f5e308a194caefe3/Powerlifting%20Sponsorships/Percentagecompete.csv)<br>

As we can see from the first row in the results, 52% of competitors globally, across 58 years of records, only compete once.<br>

Further breaking this down, we can look if gender affects whether an athlete competes more than once, and if this has an effect on who we consider for sponsorhip.
```SQL
WITH datediff AS (SELECT name, sex,
					MAX(date) - MIN(date) AS dayscompeting
					FROM ipfrecords
					GROUP BY name, sex),
					
sexcount AS (SELECT sex,
				COUNT(*) AS total
				FROM datediff
				GROUP BY sex),
				
countmulti AS (SELECT sex,
				COUNT(*) AS multicomp
				FROM datediff
				WHERE dayscompeting != 0
				GROUP BY sex),

countone AS (SELECT sex,
				COUNT(*) AS onecomp
				FROM datediff
				WHERE dayscompeting = 0
				GROUP BY sex)
				
SELECT sexcount.sex, total, multicomp, onecomp
FROM sexcount
LEFT JOIN countmulti
ON sexcount.sex = countmulti.sex
LEFT JOIN countone
ON sexcount.sex = countone.sex
```
[Outcome](https://github.com/LWhiteF/LewisPortfolio/blob/24faf1dce486341287a937368b2a1945ef2c87ca/Powerlifting%20Sponsorships/gendermulticomp.csv)<br>
|sex|total|multicomp|onecomp|
|:---:|:---:|:---:|:---:|
|F|91833|46097|45736|
|M|286352|135744|150608|
|Mx|5|3|2|

This aligns with the global statistics, that roughly 50% of competitors of any gender only once.
