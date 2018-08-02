{-# language OverloadedStrings #-}
{-# language DataKinds #-}

import           Control.Monad                  ( when )
import qualified Data.ByteString               as B
import           Data.Foldable                  ( for_ )
import           Data.Function                  ( fix )
import           System.Environment             ( getArgs , getProgName)
import qualified OpenCV                        as CV
import           System.Exit
import qualified OpenCV.VideoIO.Types          as CVT
import qualified OpenCV.VideoIO.VideoWriter    as CVW
import           OpenCV.TypeLevel
import           Data.Word
import           Linear.V2                      ( V2(..) )
import qualified Foreign.C.Types as CT

main :: IO ()
main = do
  args <- getArgs

  case args of
    inFile : outFile : _ -> do
      cap <- CV.newVideoCapture

      fps <- CV.videoCaptureGetD cap CVT.VideoCapPropFps
      w   <- CV.videoCaptureGetI cap CVT.VideoCapPropFrameWidth
      h   <- CV.videoCaptureGetI cap CVT.VideoCapPropFrameHeight
      let center = V2 (toCFloat (fromIntegral w / 2)) (toCFloat (fromIntegral h / 2))

      CV.exceptErrorIO $ CV.videoCaptureOpen cap $ CV.VideoFileSource inFile Nothing

      CV.withWindow "Example 2-11"
        $ \window -> CV.withWindow "Log_Polar" $ \logPolar -> do

            wr <- CVW.videoWriterOpen $ CVW.VideoFileSink' $ CVW.VideoFileSink outFile "avc1" fps (w, h)

            fix $ \continue -> do
              _ok   <- CV.videoCaptureGrab cap
              frame <- CV.videoCaptureRetrieve cap
              for_ frame $ \img -> do
                _ <- CV.imshow window img

                let logPolarImg = CV.exceptError $ CV.logPolar img center 40 CV.InterCubic False True
                _ <- CV.imshow logPolar logPolarImg
                _ <- CV.exceptErrorIO $ CVW.videoWriterWrite wr logPolarImg

                key <- CV.waitKey 33
                when (key == -1) continue

            CV.exceptErrorIO $ CVW.videoWriterRelease wr

    _ -> help
 where
  toCFloat = CT.CFloat
  help = do
    name <- getProgName
    putStrLn "Read in a video, write out a log polar of it"
    putStrLn $ name ++ " <path/video> <path/video_output>"
    putStrLn "For example:"
    putStrLn $ name ++ " ./resources/tree.avi  ./resources/vout.avi"
    putStrLn "Then read it with:\n ./example_02-10 ../vout.avi"
