# [Graphly.org](http://www.graphly.org/) - European general mortality during 2000-2020
This site shows the mortality within EU during the period 2000-2020. The mortality shown is called general mortality, i.e. all deaths per poplation per time. In Graphly the mortality shown is per 1000 individuals/year.

## [Haskell](https://www.haskell.org/)/[elm](https://elm-lang.org/)
This website is built with [Eurostat open-data](https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=demo_r_mweek3&lang=en) and open-source code using pure functional programming; Haskell and elm. Haskell is used in the data preprocessing pipeline, and elm is used as the frontend language generating the website. The website is static to make it faster to use and easier to share (The whole website is contained in the index.html file). This is possible since the data-set is fairly small.

The preprocessing reads the data from Eurostat and transforms it into an elm-file that is compiled into the frontend app.

Using pure functional languages such as Haskell and elm lets me focus on the logic and features, instead of searching for bugs. This saves a lot of motivation, brain power and time.

## The Power of Open-Source
This website took around 40 hours to create, which would not have been possible without the power of open-source. First of all, both programming languages used in this project is fully open-source. The Haskell preprocessing stage depends directly on five open-source libraries and indirectly on 30 more libraries. The elm frontend app depends directly on nine libraries and indirectly on 17 more libraries, including Bootstrap. Using open-source let's me utilize, leverage and reuse probably hundreds of thousands of hours of work.

## Results
The graphs show that the mortality in EU has not been affected by the Corona pandemic, at least in most countries. Some countries show a higher mortality temporarily during a couple of weeks, but put in the bigger perspective of 20 years, 2020 does not stick out in but a few countries. The following list is compiled with data from the graphs of "Year with highest mortality compared to 2020".

Countries **with** an unusual high mortality:
- Belgium
- France (only 8 years of data)
- Italy (only 6 years of data)
- Netherlands
- Spain (The deadliest country. A five week peak with an average increase of mortality by 80%, i.e. contributes 10% in total to 2020)
- United Kingdom (only 6 years of data)

Countries **without** an unusual high mortality:
- Albania (only 6 years of data)
- Austria
- Bulgaria
- Croatia
- Cyprus (only 6 years of data)
- Czechia
- Denmark
- Estonia
- Finland
- Germany (only 5 years of data)
- Greece (only 6 years of data)
- Hungary
- Iceland
- Latvia
- Liechtenstein
- Lithuania
- Luxembourg
- Malta
- Montenegro
- Norway (No week in 2020 has a higher mortality than 2002)
- Poland (May get a higher mortality in the fall, new data will decide if it should be moved)
- Portugal
- Romania (only 6 years of data)
- Serbia
- Slovakia
- Slovenia
- Sweden (Close to the deadliest year of 2002)
- Switzerland

The pandemic of 2020, was there really one? Pan, from Greek meaning "all". In hindsight it seems that only some countries were affected.

## Different graphs
There are currently five types of graphs available for each country:

- Year with highest mortality rate compared to 2020
  This graph compares 2020 with the previous year of the current country that showed the highest total yearly mortality.
- Year with highest weekly mortality rate compared to 2020
  This graph compares 2020 with the previous year of the current country that showed the highest mortality during one week.
- Show data for all available years 2000-2020
  This graph shows all the data available for the current country.
- Show data for all available weeks 2000-2020
  This graph shows how mortality has changed on a weekly basis for the current country.
- Show how mortality has changed from 2000-2020
  This graph shows how mortality has changed on a yearly basis for the current country.
