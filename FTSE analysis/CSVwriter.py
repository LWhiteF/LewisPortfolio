import csv
from datetime import datetime

# Define the CSV file name with a timestamp
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_file = f"ftse_100_data_{timestamp}.csv"

# Open the CSV file in write mode
with open(csv_file, mode='w', newline='') as file:
    writer = csv.writer(file)
    
    # Write the header row
    writer.writerow(["Timestamp", "Short Name", "Long Name", "Price", "Change"])
    
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
