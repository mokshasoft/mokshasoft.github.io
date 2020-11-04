{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lib
    ( elmDataGenerator
    ) where

import Parser

elmDataGenerator :: IO ()
elmDataGenerator = do
  putStrLn "Start parsing"
  csvData <- readFile "demo_r_mweek3_1_Data.csv"
  let recs = lines2Records (drop 1 $ lines csvData)
  putStrLn $ "parsing done.\n" ++ show recs
