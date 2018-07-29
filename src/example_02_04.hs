import           Control.Monad        (void, when)
import qualified Data.ByteString      as B
import           Data.Foldable        (for_)
import           Data.Function        (fix)
import qualified OpenCV               as CV
import qualified OpenCV.VideoIO.Types as CVT
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
      [] -> help
      file : _ -> do
        cap <- CV.newVideoCapture
        _ <- CV.exceptErrorIO $ CV.videoCaptureOpen cap $ CV.VideoFileSource file Nothing

        frames <- CV.videoCaptureGetI cap CVT.VideoCapPropFrameCount
        width <- CV.videoCaptureGetI cap CVT.VideoCapPropFrameWidth
        height <- CV.videoCaptureGetI cap CVT.VideoCapPropFrameHeight
        putStrLn $ "Video has " ++ show(frames) ++ " frames of dimension("
                   ++ show(width) ++ ", " ++ show(height) ++ ")."

        CV.withWindow "Example 2-4" $ \window -> do
          CV.createTrackbar window "Position" 0 frames (void <$> CV.videoCaptureSetI cap CVT.VideoCapPropPosFrames)
          fix $ \continue -> do
            _ok <- CV.videoCaptureGrab cap
            frame <- CV.videoCaptureRetrieve cap
            currentPos <- CV.videoCaptureGetI cap CVT.VideoCapPropPosFrames
            --TODO missing binding to set trackbar position
            for_ frame $ \img -> do
              CV.imshow window img
              key <- CV.waitKey 33
              when (key == -1) continue

    where
      help = do
        name <- getProgName
        putStrLn "2-04: Adding a trackbar to a basic viewer for moving w/in the video file"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/tree.avi"
