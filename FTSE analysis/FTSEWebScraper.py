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
