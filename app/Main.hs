{-# LANGUAGE OverloadedStrings, TypeFamilies, DeriveDataTypeable, TemplateHaskell, DeriveGeneric, OverloadedLabels #-}

module Main where

import Lib

import Web.Scotty as HTTP

import Data.Default (def)
import Data.Typeable

-- Network
import Network.Wai.Handler.Warp (setPort)
import Network.HTTP.Types  (status404, status200, status409)

-- Database
import Control.Monad.IO.Class (liftIO)

import User as User
import User ()

import Database.Selda
import Database.Selda.SQLite

import Data.Aeson (decode)

config :: Options
config = Data.Default.def { verbose = 0, settings = setPort 8080 (settings Data.Default.def)}

main :: IO ()
main = do
  createUsers
  
  scottyOpts config $ do

    get "/hello" $ do
      HTTP.text "Hello, Haskell!"

    get "/echo" $ do
      msg <- param "msg"
      HTTP.text msg

    get "/users" $ do
      retrievedUsers <- liftIO $ withSQLite "database.sqlite" $ query $ select users
      json retrievedUsers
      
    post "/users" $ do 
      b <- body
      case (decode b :: (Maybe User)) of 
        Nothing -> status status409
        Just user -> do 
          liftIO $ User.insertUsers [user]
          status status200
         
        