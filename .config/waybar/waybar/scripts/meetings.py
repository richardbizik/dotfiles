#!/usr/bin/env python
import urllib.request
import urllib.error
import urllib.parse
import json
from datetime import datetime, timedelta, timezone
import pytz
from os.path import expanduser

home = expanduser('~')
cookies_location = home+'/.var/app/com.microsoft.Teams/config/Microsoft/Microsoft Teams/Cookies'
auth_token = ""
with open(cookies_location, mode='rb') as f:
    cookie = str(f.read())

    auth_header_start = cookie.index("teams.microsoft.comauthtokenBearer")
    auth_header_end = cookie.index("Origin", auth_header_start)
    # get token from the end of authtoken to the next &
    auth_token =  urllib.parse.unquote(cookie[auth_header_start+37:auth_header_end-3])


utc = pytz.UTC
local_tz = datetime.now(timezone.utc).astimezone().tzinfo
# date = "2022-09-23"
# now = datetime.fromisoformat("2022-09-23T08:40:00+02:00")
now = datetime.now().astimezone(local_tz)
date = datetime.strftime(now.astimezone(local_tz), "%Y-%m-%d")

try:
    # read calendar for user
    calendar_url = f"https://teams.microsoft.com/api/mt/emea/v2.0/me/calendars/default/calendarView?StartDate={date}" 
    hdr = {'Authorization':'Bearer '+auth_token}
    req = urllib.request.Request(calendar_url, headers=hdr)
    try:
        body = urllib.request.urlopen(req).read().decode()
    except urllib.error.HTTPError as e:
        if e.code == 401:
            print("")
        exit(1)
    _body = json.loads(body)

    #find closest meeting
    closest_meeting = {}
    closest_start = now + timedelta(days=100)

    for i in _body["value"]:
        meeting_start = datetime.fromisoformat(i["startTime"])
        meeting_end = datetime.fromisoformat(i["endTime"])
        if meeting_end < now:
            continue
        if meeting_start < now and meeting_end > now:
            closest_start = datetime.fromisoformat(i["startTime"])
            closest_meeting = i
        if meeting_start > now and meeting_start < closest_start:
            closest_start = datetime.fromisoformat(i["startTime"])
            closest_meeting = i
        if meeting_start >= now and meeting_start - timedelta(minutes=10) <= now:
            closest_start = datetime.fromisoformat(i["startTime"])
            closest_meeting = i

    if closest_meeting == {}:
        exit(1)

    closest_end = datetime.fromisoformat(closest_meeting["endTime"])

    # show current meeting, next meeting or when the meeting ends depending on time
    result = "Meeting "
    color = ""
    if closest_start < now: 
        result += "ends at: "+datetime.strftime(closest_end.astimezone(local_tz), "%H:%M")
    if closest_start > now: 
        if closest_start.timetuple().tm_yday == now.timetuple().tm_yday:
            if closest_start < now + timedelta(minutes=10):
                color = "%{F#fe8019}%{B#fbf1c7}"

            result += "starts at: "+datetime.strftime(closest_start.astimezone(local_tz), "%H:%M")
        else:
            result = "No more meetings today"
            # result += "start at: "+datetime.strftime(closest_start.astimezone(local_tz), "%Y-%m-%d %H:%M")

    print(color+"    "+result+" ")
except:
    print("")
