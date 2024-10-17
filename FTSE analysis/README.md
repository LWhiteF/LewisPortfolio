# Acquiring FTSE100 Daily Closing Price Data
First we write a python web scraper to extract the EPIC short code, the company name, the current price, and the daily price change from the FTSE100.
```python
import requests
from bs4 import BeautifulSoup
from datetime import datetime

URL = "https://www.hl.co.uk/shares/stock-market-summary/ftse-100"
page = requests.get(URL)

soup = BeautifulSoup(page.content, "html.parser")

results = soup.find("table", class_="stockTable")

table_elements = results.find_all("tr", class_=["table-odd", "table-alt"])

for table_element in table_elements:
    short_element = table_element.find("td")
    long_element = table_element.find("td", class_="name-col align-left")
    price_element = table_element.find("td", class_="padding-none align-right align-middle")
    change_element = table_element.find("td", class_=["positive align-right padding-none", "negative align-right padding-none", "nochange align-right padding-none"])
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(timestamp, end =",")
    print(short_element.text, end =",")
    print(long_element.text, end =",")
    print(price_element.text, end =",")
    print(change_element.text)
```
Next, we write a script to convert the above web scraper to write into a CSV.
```python
import csv
from datetime import datetime

# Define the CSV file name with a timestamp
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_file = f"ftse_100_data_{timestamp}.csv"

# Open the CSV file in write mode
with open(csv_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    
    # Write the header row
    writer.writerow(["timestamp", "shortname", "longname", "price", "change"])
    
    # Write the data rows
    for table_element in table_elements:
        short_element = table_element.find("td")
        long_element = table_element.find("td", class_="name-col align-left")
        price_element = table_element.find("td", class_="padding-none align-right align-middle")
        change_element = table_element.find("td", class_=["positive align-right padding-none", "negative align-right padding-none", "nochange align-right padding-none"])
        row_timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        writer.writerow([
            row_timestamp,
            short_element.text.strip(),
            long_element.text.strip(),
            price_element.text.strip(),
            change_element.text.strip()
        ])
```
These are scheduled to run at 16.30 each day, as this is when the FTSE100 closes
