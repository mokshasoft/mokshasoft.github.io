{-
   Copyright 2020, Mokshasoft AB (mokshasoft.com)

   This software may be distributed and modified according to the terms of
   the GNU General Public License v3.0. Note that NO WARRANTY is provided.
   See "LICENSE" for details.
-}


module Parser
    ( lines2Records
    , Record(..)
    ) where

import           Data.Maybe
import           Data.String.Utils
import           Text.ParserCombinators.Parsec

data Record = Record
  { country :: String
  , year    :: Int
  , week    :: Int
  , nbr     :: Int
  , dbg     :: String
  } deriving Show

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s =
    case dropWhile p s of
        "" -> []
        s' -> w : wordsWhen p s''
            where (w, s'') = break p s'

acc :: [a] -> Maybe a -> [a]
acc b a =
    case a of
        Nothing -> b
        Just r  -> b ++ [r]

lines2Records :: [String] -> [Record]
lines2Records strs = foldl acc [] (map line2Record strs)

cell2Date :: String -> (Int, Int)
cell2Date str =
    let (y, w) = span (/='W') str
    in (read y :: Int, read (drop 1 w) :: Int)

line2Record :: String -> Maybe Record
line2Record str =
    let
        spl = wordsWhen (=='"') str
        (y, w) = cell2Date (spl !! 0)
        country = spl !! 2
        t1 = spl !! 6
        t2 = spl !! 8
        nbr = fromMaybe 0 $ maybeRead (filter (/= ',') $ spl !! 10) :: Int
    in if t1 == "Total" && t2 == "Total"
           then Just Record {country = country, year = y, week = w, nbr = nbr, dbg = ""}
           else Nothing
