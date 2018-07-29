import           Control.Monad      (void)
import qualified Data.ByteString    as B
import qualified OpenCV             as CV
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    img <- CV.imdecode CV.ImreadUnchanged <$> B.readFile (head args)
    CV.withWindow "Example 2-1" $ \window -> do
        CV.imshow window img
        void $ CV.waitKey 0
