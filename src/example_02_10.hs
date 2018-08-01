import           Control.Monad      (when)
import qualified Data.ByteString    as B
import           Data.Foldable      (for_)
import           Data.Function      (fix)
import qualified OpenCV             as CV
import           System.Environment (getArgs, getProgName)
import           System.Exit

main :: IO ()
main = do
    args <- getArgs
    help

    cap <- CV.newVideoCapture
    let openSource src = CV.exceptErrorIO $ CV.videoCaptureOpen cap src

    case args of
      [] -> openSource $ CV.VideoDeviceSource 0 Nothing
      file : _ -> openSource $ CV.VideoFileSource file Nothing

    isOpened <- CV.videoCaptureIsOpened cap
    _ <- if isOpened
           then return ()
           else exitWith $ ExitFailure $ negate 1

    CV.withWindow "Example 2-10" $ \window ->
      fix $ \continue -> do
        _ok <- CV.videoCaptureGrab cap
        frame <- CV.videoCaptureRetrieve cap
        for_ frame $ \img -> do
          CV.imshow window img
          key <- CV.waitKey 33
          when (key == -1) continue

    where
      help = do
        name <- getProgName
        putStrLn "xample 2-10. The same object can load videos from a camera or a file"
        putStrLn "Call:"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "or, read from camera:"
        putStrLn name
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/fruits.jpg"
