{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances  #-}
{-# LANGUAGE FlexibleContexts   #-}
{-# LANGUAGE ScopedTypeVariables   #-}


module Main where

import           Control.Monad
import           Criterion.Main
import           Database.RethinkDB
import qualified Data.HashMap.Strict as HMS


db :: Exp Database
db = Database "test"

table :: Exp Table
table = Table Nothing "benchmark"


main :: IO ()
main = do
    h <- prepare

    let test name = bench name . nfIO . void . run h

    defaultMain
        [ test "roundtrip" $ lift (0 :: Double)
        , test "point-get" $ Get table "id"
        ]


prepare :: IO Handle
prepare = do
    h <- newHandle "localhost" defaultPort Nothing (Database "test")

    void $ run h (CreateTable db "benchmark")
    void $ run h (InsertObject CRError table (HMS.singleton "id" (String "id")))

    return h
