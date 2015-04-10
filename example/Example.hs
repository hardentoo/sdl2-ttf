{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent (threadDelay)
import Data.ByteString    (readFile)
import Data.Text          (Text)
import Data.Text.IO       (putStrLn)
import Linear             (V4(..))
import Prelude     hiding (putStrLn, readFile)
import System.Environment (getArgs)
import System.Exit        (exitFailure)

import qualified SDL
import qualified SDL.Font

red :: SDL.Font.Color
red = V4 255 0 0 0

gray :: SDL.Font.Color
gray = V4 128 128 128 255

-- A sequence of example actions to be perfomed and displayed.
examples :: [(Text, SDL.Window -> FilePath -> IO ())]
examples = [

  ("Blitting solid",
    \window path -> do
      font <- SDL.Font.load path 70
      text <- SDL.Font.solid font red "Solid!"
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window),

  ("Blitting shaded",
    \window path -> do
      font <- SDL.Font.load path 70
      text <- SDL.Font.shaded font red gray "Shaded!"
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window),

  ("Blitting blended",
    \window path -> do
      font <- SDL.Font.load path 70
      text <- SDL.Font.blended font red "Blended!"
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window),

  ("Blitting styled",
    \window path -> do
      font <- SDL.Font.load path 65
      let styles = [SDL.Font.Bold, SDL.Font.Underline, SDL.Font.Italic]
      SDL.Font.setStyle font styles
      print =<< SDL.Font.getStyle font
      text <- SDL.Font.blended font red "Styled!"
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window),

  ("Blitting outlined",
    \window path -> do
      font <- SDL.Font.load path 65
      SDL.Font.setOutline font 3
      print =<< SDL.Font.getOutline font
      text <- SDL.Font.blended font red "Outlined!"
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window),

  ("Decoding from bytestring",
    \window path -> do
      bytes <- readFile path
      font <- SDL.Font.decode bytes 40
      text <- SDL.Font.blended font gray "Decoded~~~!"
      print =<< SDL.Font.styleName font
      print =<< SDL.Font.familyName font
      SDL.Font.free font
      screen <- SDL.getWindowSurface window
      SDL.blitSurface text Nothing screen Nothing
      SDL.freeSurface text
      SDL.updateWindowSurface window)

  ]

main :: IO ()
main = do

  SDL.initialize [SDL.InitVideo]
  SDL.Font.initialize

  getArgs >>= \case

    [] -> do
      putStrLn "Usage: cabal run path/to/font.(ttf|fon)"
      exitFailure

    -- Run each of the examples within a newly-created window.
    (path:_) -> do
      flip mapM_ examples $ \(name, action) -> do
        putStrLn name
        window <- SDL.createWindow name SDL.defaultWindow
        SDL.showWindow window
        action window path
        threadDelay 1000000
        SDL.destroyWindow window

  SDL.Font.quit
  SDL.quit
