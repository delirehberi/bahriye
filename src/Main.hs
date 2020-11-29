{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Data.Text.Lazy
import Data.Aeson
import Data.Maybe (fromMaybe)
import Control.Monad.IO.Class (liftIO)
import System.Directory
import qualified System.IO
import Data.ByteString as BS (readFile,writeFile)
import System.Process (readProcess)
import System.FilePath.Posix ((</>),(<.>))

main :: IO ()
main = do
    putStrLn "Server Started at 0.0.0.0:3000";
    scotty 3000 $ home

home :: ScottyM ()
home = do 
    get "/" $ do
        _data <- param "data"
        case ( (readEither _data)::(Either Text Int) ) of 
                  Right x -> do
                      liftIO $ writeToFile x 
                      liftIO $ sendNotification
                      liftIO $ playSound
                      text "success"
                  Left y -> text "data is wrong"


writeToFile:: Int -> IO ()
writeToFile d = do
    dataFile <- dataStore
    oldData <- BS.readFile dataFile

    let decoded = decodeStrict oldData 
        res     = (fromMaybe [] decoded) ++ [d]
        tmpDataFile = dataFile <.> "tmp"
    
    encodeFile tmpDataFile res
    removeFile dataFile
    renameFile tmpDataFile dataFile

sendNotification :: IO String
sendNotification = readProcess "notify-send" ["-u", "critical", "Ringing..."] []

playSound :: IO String
playSound = readProcess "aplay" ["./siren.wav"] []

dataStore :: IO FilePath
dataStore = do
    dir <- getHomeDirectory
    return $  dir </> ".data.json"
