{-# LANGUAGE DataKinds #-}

import           Control.Monad      (void)
import qualified Data.ByteString    as B
import           Data.Int
import           GHC.TypeLits       ()
import           GHC.Word           (Word8)
import           Linear.V2
import qualified OpenCV             as CV
import           OpenCV.TypeLevel
import           System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
      [] -> help
      file : _ -> do

        img <- CV.imdecode CV.ImreadUnchanged <$> B.readFile file

        CV.withWindow "Example Gray" $ \windowGray ->
          CV.withWindow "Example Canny" $ \windowCanny -> do

            let imgGray = CV.exceptError $ CV.cvtColor CV.bgr CV.gray img
            CV.imshow windowGray imgGray

            let imgGray' :: CV.Mat ('S ['D, 'D]) ('S 1) ('S Word8)
                imgGray' = CV.exceptError $ CV.coerceMat imgGray

            let imgCanny = CV.exceptError $ CV.canny 10 100 (Just 3) CV.CannyNormL2 imgGray'
            CV.imshow windowCanny imgCanny

            void $ CV.waitKey 0
    where
      help = do
        name <- getProgName
        putStrLn "Example 2-7. The Canny edge detector writes its output to a single-channel (grayscale) image"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/fruits.jpg"
