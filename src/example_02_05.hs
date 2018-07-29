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

        CV.withWindow "Example 2-5-in" $ \windowIn -> do
          CV.withWindow "Example 2-5-out" $ \windowOut -> do

            CV.imshow windowIn img

            -- Assert that the retrieved frame is 2-dimensional.
            let img' :: CV.Mat ('S ['D, 'D]) ('S 3) ('S Word8)
                img' = CV.exceptError $ CV.coerceMat img

                imgOut = CV.exceptError $ CV.gaussianBlur (V2 5 5 :: V2 Int32) 3 3 img'
                imgOut' = CV.exceptError $ CV.gaussianBlur (V2 5 5 :: V2 Int32) 3 3 imgOut

            CV.imshow windowOut imgOut'

            void $ CV.waitKey 0
    where
      help = do
        name <- getProgName
        putStrLn "2-05: load and smooth an image before displaying"
        putStrLn $ name ++ " <path/filename>"
        putStrLn "For example:"
        putStrLn $ name ++ " ./resources/fruits.jpg"
