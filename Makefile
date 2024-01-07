#
# Targets for building the website
#

web: concat

concat: index.html.begin app/elm.min.js index.html.end
	cat index.html.begin app/elm.min.js index.html.end > index.html

APP_FILES=\
  ./app/src/Lines.elm\
  ./app/src/Main.elm\
  ./app/src/Country.elm\
  ./app/src/Gen/Population.elm\
  ./app/src/Gen/Data.elm\
  ./app/src/DataTypes.elm\
  ./app/src/Analysis.elm

app/elm.min.js: $(APP_FILES) preprocess
	(cd app && \
	./build.sh)

#
# Targets for preprocessing data
#

preprocess: app/src/Gen/Data.elm

CONV_FILES=\
  ./ElmDataGenerator/Setup.hs\
  ./ElmDataGenerator/app/Main.hs\
  ./ElmDataGenerator/test/Spec.hs\
  ./ElmDataGenerator/src/Parser.hs\
  ./ElmDataGenerator/src/Lib.hs\
  ./ElmDataGenerator/src/ElmWriter.hs

app/src/Gen/Data.elm: $(CONV_FILES) data/Eurostat/merged-data.csv
	(cd ElmDataGenerator && \
	stack build && \
	stack exec ElmDataGenerator-exe)

mergedata: data/Eurostat/merged-data.csv
data/Eurostat/merged-data.csv: data/Eurostat/new/demo_r_mweek3_1_Data.csv
	(cd ./data/Eurostat && \
	./merge-data.sh)
