#
# Targets for building the website
#

web: gen/elm.min.js

APP_FILES=\
  ./app/src/Lines.elm\
  ./app/src/Main.elm\
  ./app/src/Country.elm\
  ./app/src/Gen/Population.elm\
  ./app/src/Gen/Data.elm\
  ./app/src/DataTypes.elm\
  ./app/src/Analysis.elm

gen/elm.min.js: $(APP_FILES)
	(cd app && \
	./optimize.sh src/Main.elm && \
	cp elm.min.js ../gen)


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
	(cd ElmWriter && \
	stack build && \
	stack exec ElmDataGenerator-exe)