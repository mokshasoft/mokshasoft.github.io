{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Lib
    ( elmDataGenerator
    ) where

import           ElmWriter
import           Parser

folder :: String
folder = "../data/Eurostat/"

elmDataGenerator :: IO ()
elmDataGenerator = do
  putStrLn "Start parsing..."
  csvData <- readFile $ folder ++ "merged-data.csv"
  let recs = lines2Records (drop 1 $ lines csvData)
  putStrLn "Parsing done."
  putStrLn "Writing Data.elm file..."
  record2ElmData "../app/src/Gen/Data.elm" recs
  putStrLn "Writing done."
