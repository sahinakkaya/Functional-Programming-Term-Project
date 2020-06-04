import Data.List
import Data.Char
import System.IO
import System.Environment (getArgs)
import Data.Typeable




data Ninja = Ninja {name :: String, 
                    country :: Char,
                    status :: String, 
                    exam1 :: Float,
                    exam2 :: Float, 
                    ability1 :: String,
                    ability2 :: String,
                    r :: Int,
                    score :: Float}
                    deriving (Ord, Eq)

instance Show Ninja where
        show (Ninja name _ status _ _ _ _ round score ) = show name ++ ", Score: " ++ show score ++ ", Status: "
         ++ show status ++ ", Round: " ++ show round ++ "\n"


abilityScore :: String -> Float
abilityScore ability = case ability of 
                "Clone"     -> 20.0
                "Hit"       -> 10.0
                "Lightning" -> 50.0
                "Vision"    -> 30.0
                "Sand"      -> 50.0
                "Fire"      -> 40.0
                "Water"     -> 30.0
                "Blade"     -> 20.0
                "Summon"    -> 50.0
                "Storm"     -> 10.0
                "Rock"      -> 20.0
                _           -> error "No such ability"


calculateScore :: Float -> Float -> String -> String -> Float
calculateScore e1 e2 a1 a2 =  0.5 * e1 + 0.3 * e2 + abi1 + abi2
    where 
        abi1 = abilityScore a1
        abi2 = abilityScore a2


initNinja :: [String] -> Float -> Float -> Ninja
initNinja params s1 s2 = Ninja (params !! 0) countryChar "Junior" s1 s2 (params !! 4) (params !! 5) 0 scr
    where
        scr = calculateScore s1 s2  (params !! 4) (params !! 5)
        countryChar = case (params !! 1) of
                "Fire"      -> 'f'
                "Lightning" -> 'l'
                "Water"     -> 'w'
                "Wind"      -> 'n'
                "Earth"     -> 'e'
                _           -> error "No such country"
                


readNinjas :: Handle -> [Ninja] ->  IO [Ninja]
readNinjas file ninjas = do
        end <- hIsEOF file
        if not end then do
                line <- hGetLine file
                let params = words line 
                let score1 = read(params !! 2) :: Float
                let score2 = read(params !! 3) :: Float 
                let ninja = initNinja params score1 score2
                readNinjas file (ninja:ninjas)
        else do
                return ninjas
     
prompt :: Bool -> IO String
prompt valid = do
        putStrLn "a) View a Country's Ninja Information"
        putStrLn "b) View All Countries' Ninja Information"
        putStrLn "c) Make a Round Between Ninjas"
        putStrLn "d) Make a Round Between Countries"
        putStrLn "e) Exit"
        hSetBuffering stdout NoBuffering
        if valid
                then do putStr "Enter the action: "
        else putStr "Action is not on the list. Please enter a valid action: "
        action <- getLine
        return action

        
ninjaInfoPrompt :: IO String
ninjaInfoPrompt = do
        putStrLn "Enter the country code: "
        hSetBuffering stdout NoBuffering
        countryCode <- getLine
        return countryCode


ninjaInfoSort :: [Ninja] -> [Ninja]
ninjaInfoSort array = sortedList
                        where
                                sortedList = (sortBy (\n1 n2 -> compare (r n1) (r n2)) ((sortBy (\n1 n2 -> compare (score n2) (score n1)) array)))
                                


countryNinjaInfo :: [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> IO()
countryNinjaInfo f l w n e = do
        choice <- ninjaInfoPrompt 
        let lowered_choice = map toLower choice
        case lowered_choice of
                "e" -> print (ninjaInfoSort e)
                "f" -> print (ninjaInfoSort f)
                "l" -> print (ninjaInfoSort l)
                "w" -> print (ninjaInfoSort w)
                "n" -> print (ninjaInfoSort n)
                ""  -> error "enter a country"
                _   -> error "No such country"

        showUIList True f l w n e


allNinjaInfo :: [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> IO()
allNinjaInfo f l w n e = do
        print (ninjaInfoSort allList)
        showUIList True f l w n e
                where
                        allList = f ++ l ++ w ++ n ++ e



convertCountry ::  String -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [[Ninja]]
convertCountry countryCode f l w n e  = case countryCode of
        "f" -> return f
        "l" -> return l
        "w" -> return w
        "n" -> return n
        "e" -> return e
        _ -> error " "


listDelete :: Ninja -> [Ninja] -> [Ninja]
listDelete deletedNinja c = updatedList
        where
                updatedList = filter (\ninja -> ninja /= deletedNinja) c

                
listUpdate :: Ninja -> [Ninja] -> [Ninja]
listUpdate updatedNinja c = updatedList
        where
                placeholder = filter (\ninja -> ninja /= updatedNinja) c
                
                stat = if (r updatedNinja) < 2 then "Junior" else "Journeyman"
                updatedList = placeholder ++ [
                        Ninja {name = (name updatedNinja), country = (country updatedNinja), status = stat,
                                        exam1 = (exam1 updatedNinja), exam2 = (exam2 updatedNinja), 
                                        ability1 = (ability1 updatedNinja), ability2 = (ability2 updatedNinja), 
                                        r = (r updatedNinja)+1, score = (score updatedNinja)+10 }]
                

combiningNinjasforUpdate :: Ninja -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [[[Ninja]]]
combiningNinjasforUpdate nin f l w n e = case (country nin) of
        'f' -> return [(listUpdate nin f),l,w,n,e]
        'l' -> return [f,(listUpdate nin l),w,n,e]
        'w' -> return [f,l,(listUpdate nin w),n,e]
        'n' -> return [f,l,w,(listUpdate nin n),e]
        'e' -> return [f,l,w,n,(listUpdate nin e)]
        _   -> error ""

combiningNinjasforDelete :: Ninja -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [[[Ninja]]]
combiningNinjasforDelete nin f l w n e = case (country nin) of
        'f' -> return [(listDelete nin f),l,w,n,e]
        'l' -> return [f,(listDelete nin l),w,n,e]
        'w' -> return [f,l,(listDelete nin w),n,e]
        'n' -> return [f,l,w,(listDelete nin n),e]
        'e' -> return [f,l,w,n,(listDelete nin e)]
        _   -> error ""


ninjaRound :: [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> IO()
ninjaRound f l w n e = do
        putStr "Enter the name of the first ninja: "
        firstName <- getLine
        putStr "Enter the country code of the first ninja: "
        firstCountry <- getLine
        let ninja1 = filter (\ninja -> name ninja == firstName) (head(convertCountry firstCountry f l w n e))
        if null ninja1 then do
                        putStrLn "Please enter a valid name-country pair."
                        ninjaRound f l w n e
                        else do
                                putStr "Enter the name of the second ninja: "
                                secondName <- getLine
                                putStr "Enter the country code of the second ninja: "
                                secondCountry <- getLine
                                let ninja2 = filter (\ninja -> name ninja == secondName) (head(convertCountry secondCountry f l w n e))
                                if null ninja2 then do
                                                putStrLn "Please enter a valid name-country pair."
                                                ninjaRound f l w n e
                                                else do
                                                        putStr "Winner: "
                                                        let winner = sortBy(\n1 n2 -> compare (score n2) (score n1)) (ninja1 ++ ninja2)   
                                                        let uplist1 = combiningNinjasforDelete (winner !! 1) f l w n e                                                                                                              
                                                        let uplist2 = combiningNinjasforUpdate (winner !! 0) (head (head uplist1)) ((head uplist1) !! 1) ((head uplist1) !! 2) ((head uplist1) !! 3) ((head uplist1) !! 4)
                                                        
                                                        print (filter(\ninja -> (name ninja) == (name (head winner))) (head (convertCountry [(country (head winner))] (head (head uplist2)) ((head uplist2) !! 1) ((head uplist2) !! 2) ((head uplist2) !! 3) ((head uplist2) !! 4))))

                                                        showUIList True (head (head uplist2)) ((head uplist2) !! 1) ((head uplist2) !! 2) ((head uplist2) !! 3) ((head uplist2) !! 4)




showUIList :: Bool -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> [Ninja] -> IO()
showUIList state f l w n e = do 
        
        action <- prompt state
        
        let lowered_action = map toLower action
        case lowered_action of
                "a" -> countryNinjaInfo f l w n e 
                "b" -> allNinjaInfo f l w n e
                "c" -> ninjaRound f l w n e
                --"d" -> return--CountryRound
                --"e" -> JourneymanList f l w n e -- fill the func
                _   -> showUIList False f l w n e


main :: IO ()
main = do
        args <- getArgs 
        file <- openFile (head args) ReadMode
        all_ninjas <- readNinjas file []
        let sortedNinjas = sortBy (\n1 n2 -> compare (country n1) (country n2)) all_ninjas
        let [earth, fire, lightning, water, wind] = groupBy (\n1 n2 -> (country n1) == (country n2)) sortedNinjas
        showUIList True fire lightning wind water earth
        --let sasuke =  filter (\ninja -> name ninja =="Sasuke") all_ninjas
        --print sasuke
        --let sorted_fire = sortBy(\n1 n2 -> compare (score n2) (score n1)) fire
        --print sorted_fire
        print "end"
        

        