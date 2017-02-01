#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup as bs
import re
import time
import json

# Scrapes http://dynasties.operationsports.com/team-colors.php?sport=ncaa

with open('ncaa_football_team_names.txt') as myFile:
    url = 'http://dynasties.operationsports.com/team-colors.php?sport=ncaa'

    raw_text = requests.get(url).text
    soup = bs(raw_text, "html.parser")
    table = soup.find('table')

    data = []

    for row in table.find_all('tr'):
        try:
            team_name = row.find('h3').text
            colors = [x.text for x in row.find_all('div', attrs={'class': 'team-color-frame'})]
            team = {}
            team['name'] = team_name
            team['colors'] = colors
            team['league'] = 'ncaa'
            data.append(team)
        except Exception as e:
                print(str(e))
    
    with open('teams-and-colors2.json', 'w') as outFile:
        json.dump(data, outFile, sort_keys=True, indent=4)
