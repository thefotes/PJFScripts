#!/usr/bin/env python
import mechanize
from bs4 import BeautifulSoup
import smtplib
from email.mime.text import MIMEText

URL = 'https://www.lendingclub.com/account/gotoLogin.action'
LENDING_CLUB_EMAIL = ''
LENDING_CLUB_PASSWORD = ''
GMAIL_ADDRESS = ''
GMAIL_PASSWORD = ''
EMAIL_TO_SEND_TO = ''
FROM_NAME = ''
TO_NAME = ''

def html_from_lending_club():
    br = mechanize.Browser()
    br.open(URL)
    br.select_form(nr=0)
    br.form['login_email'] = LENDING_CLUB_EMAIL
    br.form['login_password'] = LENDING_CLUB_PASSWORD
    br.set_handle_robots(False)
    br.submit()
    return br.response().read()

def available_cash():
    soup = BeautifulSoup(html_from_lending_club())
    labels = soup.find('label', {"class": "available-cash-link"})
    if labels is not None:
        the_string = labels.string.strip().replace('Available Cash $', '')
    else:
        labels = soup.find('span', {"id": "available-cash"})
        the_string = labels.string.strip().replace('$', '')
    return the_string

def more_than_twenty_five():
    available_funds = float(available_cash())
    if available_funds >= 25.0:
        email_me()

def cash_from_string():
    return '$' + available_cash()

def compose_message():
    msg = MIMEText("%s available" % cash_from_string())
    msg['Subject'] = 'Lending Club Cash Available!'
    msg['From'] = FROM_NAME
    msg['To'] = TO_NAME
    return msg.as_string()

def email_me():
    server = smtplib.SMTP()
    server.connect("smtp.gmail.com", 587)
    server.starttls()
    server.ehlo()
    server.login(GMAIL_ADDRESS, GMAIL_PASSWORD)
    server.sendmail(GMAIL_ADDRESS, EMAIL_TO_SEND_TO, compose_message())

more_than_twenty_five()
