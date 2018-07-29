import           Control.Monad      (void)
import qualified Data.ByteString    as B
import qualified OpenCV             as CV
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
      [] -> help
      file : _ -> do
        img <- CV.imdecode CV.ImreadUnchanged <$> B.readFile file
        CV.withWindow "Example 2-1" $ \window -> do
          CV.imshow window img
          void $ CV.waitKey 0
    where
      help = do
        name <- getProgName
        putStrLn "A simple OpenCV program that loads and displays an image from disk"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/fruits.jpg"
