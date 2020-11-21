#!/usr/bin/env bash

cat <(cat old/demo_r_mweek3_1_Data.csv | grep -v "^\"2020") new/demo_r_mweek3_1_Data.csv > merged-data.csv
