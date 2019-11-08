{-# LANGUAGE DeriveGeneric, OverloadedStrings, OverloadedLabels #-}
module User where

import Database.Selda
import Database.Selda.SQLite

import Data.Aeson (FromJSON, ToJSON)

type T = User

data User = User {
  id :: Int,
  name :: Text,
  surname :: Text,
  age :: Maybe Int
} deriving Generic

instance SqlRow User

instance FromJSON User

instance ToJSON User

users :: Table User

users = table "users" [#id :- primary]

createUsers :: IO () 
createUsers = withSQLite "database.sqlite" $ do
                tryCreateTable users
                
insertUsers :: [User] -> IO ()
insertUsers usersToInsert = withSQLite "database.sqlite" $ do 
                insert_ users usersToInsert 
 