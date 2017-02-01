#!/usr/bin/env python3

import requests
import re
from bs4 import BeautifulSoup as bs

html_page = requests.get('http://www.databasefootball.com/College/teams/teamlist.htm')

soup = bs(html_page.text, "html.parser")

regex = re.compile(r'teampage.htm\?TeamID=.*?')

names = [x.text for x in soup.find_all('a', href=regex)]

with open('ncaa_football_team_names.txt', mode='wt', encoding='utf-8') as myFile:
    myFile.write('\n'.join(names))

