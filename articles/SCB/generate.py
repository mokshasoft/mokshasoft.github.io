import json
import matplotlib.pyplot as plt; plt.rcdefaults()
import matplotlib.pyplot as plt
import numpy as np
import requests

#
# Generates a graph of sorted mortality rates in Sweden from 1990 to 2020.
# The data is sourced from SCB.
#

# Get population from 1990 to 2020
data = {
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:RegionRiket99",
        "values": []
      }
    },
    {
      "code": "ContentsCode",
      "selection": {
        "filter": "item",
        "values": [
          "BE0101N1"
        ]
      }
    },
    {
      "code": "Tid",
      "selection": {
        "filter": "item",
        "values": [
          "1990",
          "1991",
          "1992",
          "1993",
          "1994",
          "1995",
          "1996",
          "1997",
          "1998",
          "1999",
          "2000",
          "2001",
          "2002",
          "2003",
          "2004",
          "2005",
          "2006",
          "2007",
          "2008",
          "2009",
          "2010",
          "2011",
          "2012",
          "2013",
          "2014",
          "2015",
          "2016",
          "2017",
          "2018",
          "2019",
          "2020"
        ]
      }
    }
  ],
  "response": {
    "format": "json"
  }
}

url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkningNy"
r = requests.post(url, json=data)
pop = json.loads(r.text)
pop = np.array(pop['data'])

## Get no of dead
data = {
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:RegionRiket99",
        "values": [
          "00"
        ]
      }
    },
    {
      "code": "Alder",
      "selection": {
        "filter": "vs:ÅlderTotA",
        "values": []
      }
    },
    {
      "code": "Tid",
      "selection": {
        "filter": "item",
        "values": [
          "1990",
          "1991",
          "1992",
          "1993",
          "1994",
          "1995",
          "1996",
          "1997",
          "1998",
          "1999",
          "2000",
          "2001",
          "2002",
          "2003",
          "2004",
          "2005",
          "2006",
          "2007",
          "2008",
          "2009",
          "2010",
          "2011",
          "2012",
          "2013",
          "2014",
          "2015",
          "2016",
          "2017",
          "2018",
          "2019",
          "2020"
        ]
      }
    }
  ],
  "response": {
    "format": "json"
  }
}

url = "http://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101I/DodaHandelseK"
r = requests.post(url, json=data)
dead = json.loads(r.text)
dead = dead['data']

## Aggregate

deadL = np.array([int(i['values'][0]) for i in dead])
popL = np.array([int(i['values'][0]) for i in pop])
mort = 1000*deadL/popL

res = [x for x in zip(range(1990, 2021, 1), mort)]
resSorted = sorted(res, key=lambda t: t[1])

## Plot

objects = [t[0] for t in resSorted]
y_pos = np.arange(len(objects))
performance = [t[1] for t in resSorted]
colors = ['r' if x == 2020 else 'b' for x in objects]

plt.bar(y_pos, performance, align='center', alpha=0.5, color=colors)
plt.xticks(y_pos, objects, rotation='vertical')
plt.ylabel('Mortality')
plt.title('Nbr. Deaths/1000/year (mortality) from 1990-2020 (Source SCB)')

plt.show()
