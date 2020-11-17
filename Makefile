#
# Targets for building the website
#

web: app/elm.min.js

APP_FILES=\
  ./app/src/Lines.elm\
  ./app/src/Main.elm\
  ./app/src/Country.elm\
  ./app/src/Gen/Population.elm\
  ./app/src/Gen/Data.elm\
  ./app/src/DataTypes.elm\
  ./app/src/Analysis.elm

app/elm.min.js: $(APP_FILES) index.html.begin index.html.end
	(cd app && \
	./optimize.sh src/Main.elm && \
	cat ../index.html.begin elm.min.js ../index.html.end > ../index.html)


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

app/src/Gen/Data.elm: $(CONV_FILES)
	(cd ElmDataGenerator && \
	stack build && \
	stack exec ElmDataGenerator-exe)
