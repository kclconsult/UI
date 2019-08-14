import requests
import datetime
def observation_url(code = "8867-4", start="2016-02-26T00:00:00Z", end="2020-02-28T00:00:00Z"):
    _url = "http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/%s/%s/%s"
    return _url % (code, start, end)

format   = "%Y-%m-%dT%H:%M:%SZ"
start_dt = datetime.datetime.strptime("2016-02-26T00:00:00Z", format)
end_dt   = datetime.datetime.strptime("2020-02-28T00:00:00Z", format)

####
# HR
#  8867-4    | Heart rate          | "c40443h4" "c8867h4" "c82290h8" "datem" "date.month" "time" "weekday"
# start: 2019-04-04 23:19:39
# end: 2019-04-09 13:56:13
#
# WORKS: http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/8867-4/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z
# BAD REQUEST: http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/8867-4/2019-04-03T00:00:00Z/2019-04-10T00:00:00Z

#r = requests.get(observation_url("8867-4", start=start_dt.strftime(format), end=end_dt.strftime(format)))
#print(r.status_code)

# stepping down by 1 day
# dt = end_dt

#while((dt > start_dt) and (r.status_code == 200)):
#   dt = dt + datetime.timedelta(days=-1)
#   print(dt.strftime(format))
#   r = requests.get(observation_url("8867-4", start=start_dt.strftime(format), end=dt.strftime(format)))
#   print(r.status_code)

# Results:
# 2019-08-07T00:00:00Z
# 200
# 2019-08-06T00:00:00Z
# 400

# stepping up by 1 day
# dt = start_dt

# while((dt < end_dt) and (r.status_code == 200)):
#    dt = dt + datetime.timedelta(days=1)
#    print(dt.strftime(format))
#    r = requests.get(observation_url("8867-4", start=dt.strftime(format), end=end_dt.strftime(format)))
#    print(r.status_code)

# Results:
# 2019-08-06T00:00:00Z
# 200
# 2019-08-07T00:00:00Z
# 400

####
# BP
#  85354-9    | Blood pressure      | "c271649006" "c271650006" "c8867h4" "datem" "date.month" "time" "weekday"
# start: 2017-01-01 00:00:00
# end:   2017-06-19 00:00:00
#
# WORKS: http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z
# BAD REQUEST: http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/85354-9/2017-01-01T00:00:00Z/2017-02-01T00:00:00Z

r = requests.get(observation_url("85354-9", start=start_dt.strftime(format), end=end_dt.strftime(format)))
print(r.status_code)

# stepping down by 1 day
dt = end_dt

while((dt > start_dt) and (r.status_code == 200)):
  dt = dt + datetime.timedelta(days=-1)
  print(dt.strftime(format))
  r = requests.get(observation_url("85354-9", start=start_dt.strftime(format), end=dt.strftime(format)))
  print(r.status_code)

# Results:
# 2019-08-07T00:00:00Z
# 200
# 2019-08-06T00:00:00Z
# 400

# stepping up by 1 day
dt = start_dt

while((dt < end_dt) and (r.status_code == 200)):
   dt = dt + datetime.timedelta(days=1)
   print(dt.strftime(format))
   r = requests.get(observation_url("8867-4", start=dt.strftime(format), end=end_dt.strftime(format)))
   print(r.status_code)

# Results:
# 2019-08-06T00:00:00Z
# 200
# 2019-08-07T00:00:00Z
# 400

####
# ECG
# http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/131328/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z
#  131328    | ECG                 | wtf (see below)???
# only one data point: 2019-08-06 17:27:25

# Mood
#  285854004 | Recorded emotion    | ???
