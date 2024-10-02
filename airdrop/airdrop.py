import csv
import json

# Read the CSV file and extract addresses
addresses = []
with open('holders_plant.csv', 'r') as csvfile:
    csvreader = csv.DictReader(csvfile)
    for row in csvreader:
        addresses.append(row['HolderAddress'])

# Write addresses to a JSON file
with open('airdrop.json', 'w') as jsonfile:
    json.dump(addresses, jsonfile, indent=2)

print("JSON file 'airdrop.json' has been created with the list of addresses.")