{-# LANGUAGE OverloadedStrings #-}

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
import Data.Time (getCurrentTime)
import qualified Network.Wreq as W (get) 
import Control.Concurrent (forkIO)
import System.Environment (getEnv)


main :: IO ()
main = do
    putStrLn "Server Started at 0.0.0.0:3000";
    scotty 3000 $ home

home :: ScottyM ()
home = do 
    get "/" $ do
        _data <- param "data"
        case ( (readEither _data)::(Either Text Int) ) of 
          Right sensor_value -> do
              liftIO $ do 
                    (writeToFile sensor_value) 
                    forkIO $ sendNotification 
                    forkIO $ playSound
              text "success"
          Left y -> text "data is wrong"


writeToFile:: Int -> IO ()
writeToFile sensor_value = do
    dataFile <- dataStore
    old_sensor_values <- BS.readFile dataFile
    t <- getCurrentTime
    let new_sensor_values     = (fromMaybe [] $ decodeStrict old_sensor_values) ++ [(sensor_value,t)]
        tmpDataFile = dataFile <.> "tmp" --adding .tmp extension to file name

    encodeFile tmpDataFile new_sensor_values
    removeFile dataFile
    renameFile tmpDataFile dataFile

sendNotification :: IO ()
sendNotification = do
    apiKey <- getEnv "API_KEY"
    readProcess "@@notify-send@@" ["-u", "critical", "Ringing..."] []
    W.get $ "https://api.telegram.org/bot"<>apiKey<>"/sendMessage?chat_id=680386129&text=KapıCaliiiii"
    W.get $ "https://api.telegram.org/bot"<>apiKey<>"/sendMessage?chat_id=471873694&text=KapıCaliiiii"
    return ()


playSound :: IO ()
playSound = do
    readProcess "@@aplay@@" ["@@SIREN@@"] []
    return ()

dataStore :: IO FilePath
dataStore = do
    dir <- getHomeDirectory
    return $  dir </> ".data.json"

