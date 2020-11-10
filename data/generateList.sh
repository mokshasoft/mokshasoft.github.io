#!/bin/sh

#getCountryData : String -> D.Dict Int Int
#getCountryData country =
#    case country of
#        "Sweden" ->
#            popSweden
#
#        _ ->
#            D.empty

cat ../app/src/Gen/Population.elm |
	grep -E "pop.*=" |
	sed 's/^pop//g ; s/\ \=//g' |
	awk 'BEGIN {print "getCountryData : String -> D.Dict Int Int\ngetCountryData country =\n    case country of\n"} {print "        \"" $1 "\" ->\n            pop" $1 "\n"} END {print "        _ ->\n            D.empty"}' >> ../app/src/Gen/Population.elm
