import           Control.Monad      (when)
import qualified Data.ByteString    as B
import           Data.Foldable      (for_)
import           Data.Function      (fix)
import qualified OpenCV             as CV
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
      [] -> help
      file : _ -> do
        cap <- CV.newVideoCapture
        _ <- CV.exceptErrorIO $ CV.videoCaptureOpen cap $ CV.VideoFileSource file Nothing
        putStrLn $ "Opened file: " ++ file
        CV.withWindow "Example 2-3" $ \window ->
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
        putStrLn "2-03: play video from disk"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/tree.avi"
