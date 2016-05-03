(* Romain EPIARD

   Programmation Fonctionnelle (IPRF)
   Projet : Analyse d'un fichier texte en OCaml.

   === PARTIE 1 : ÉCHAUFFEMENT ===
   Type word, donné dans le sujet : 
*)
type word = char list;;

let hello = (['H'; 'e'; 'l'; 'l'; 'o'] : word);;
let car1 = 'h';;
let car2 = '-';;
let car3 = '\'';;
let car4 = '4';;
let car5 = 'L';;

(* Question 1 : Fonction is_a_letter

   Cette fonction permet de savoir si le caractère donné en entrée est bien une lettre valide (lettre majuscule, minuscule, tiret et apostrophe)

   is_a_letter : char -> bool = <fun>

   @param  c        Le caractère à analyser.
   @return booléen  True si le caractère est une lettre valide, sinon false.
*)
let is_a_letter = fun c ->
  match c with
  | 'a'..'z' | 'A'..'Z' | '-' | '\''    -> true
  | _                                   -> false		 
;;

(* Tests de la fonction is_a_letter : *)
is_a_letter car1;;
is_a_letter car2;;
is_a_letter car3;;
is_a_letter car4;;
is_a_letter car5;;

(* Question 2 : Fonction is_valid

   La fonction is_valid w permet de connaitre la validité d'un mot, par rapport à l'alphabet que nous avons constitué grâce à la fonction is_a_letter.

   is_valid : word -> bool = <fun>

   @param  w        Le mot contenant les caractères à évaluer.
   @return booléen  True si le mot est non vide et constitué de lettres valides, sinon false.
*)
let rec is_valid = fun (w : word) ->
  match w with
  | []                             -> false
  | [c]                            -> is_a_letter c
  | h::t                           -> if is_a_letter h then is_valid t else false
;;

(* Test de la fonction is_valid : *)
is_valid hello;;

(* Question 3 : Fonction to_lower

   Cette fonction permet de passer toutes les lettres d'un mot en minuscule. Celles qui étaient en majuscule, passeront en minuscule. Celles déjà en minuscule, le resteront.

   to_lower : word -> word = <fun>

   @param  w     Le mot à rendre en minuscule.
   @return word  Le mot passé en minuscule.
*)
let rec to_lower = fun (w : word) ->
  match w with
  | []                                  -> ([] : word)
  | h::t                                -> (Char.lowercase h::to_lower t : word)
;;

(* Test de la fonction to_lower : *)
to_lower hello;;

(* Question 4 : Fonction first_valid_char (Partie 1/2)

   La fonction first_valid_char parcourt un mot w. Elle s'arrête et retourne le mot w, dès qu'elle trouve une lettre valide.

   first_valid_char : word -> word = <fun>

   @param  w     Le mot à parcourir.
   @return word  Retourne un mot contenant la première lettre valide trouvée, ainsi que la suite du mot.
*)
let rec first_valid_char = fun w ->
  match w with
  | []       -> ([] : word)
  | [h]      -> if is_a_letter h then ([h] : word) else ([] : word)
  | h::t     -> if is_a_letter h then (w : word) else (first_valid_char t : word)
;;

(* Question 4 : Fonction trim (Partie 2/2)

   La fonction trim utilise la fonction first_valid_char. Comme la fonction first_valid_char retourne la première lettre valide, avec la suite du mot, on lui passe notre mot à l'envers, afin de partir de la fin, pour s'arrêter dès que l'on croise une lettre valide, et ainsi supprimer toutes les lettres du mot, après la dernière lettre valide. Le retour de first_valid_char est de nouveau inversé, pour remettre le mot à l'endroit.

   trim : word -> word = <fun>

   @param  w     Le mot à traiter.
   @return word  Retourne le mot avec les caractères, suivant la dernière lettre valide, supprimés.
*)
let trim = fun (w : word) -> (List.rev (first_valid_char (List.rev w)) : word);;

(* Test de la fonction trim : *)
let test1 = (['e'; 't'; 'c'; '.'; '.'; '.'] : word);;
let test2 = (['a'; '.'; 'b'] : word);;
let test3 = (['a'; '.'; 'b'; '.'; '.'; '.'] : word);;
let test4 = (['H'; 'e'; 'l'; 'l'; 'o'; ','; ' '; 'n'; 'i'; 'c'; 'e'; ' '; 't'; 'o'; ' '; 'm'; 'e'; 'e'; 't'; ' '; 'y'; 'o'; 'u'; '.'; '.'; '!'] : word);;
trim test1;;
trim test2;;
trim test3;;
trim test4;;

(* handle_file: (in_channel -> 'a) -> string -> 'a *)
let handle_file = fun f -> fun file ->
  let input = open_in file in
  let res = f input in
  let _ = close_in input in
  res
;;

(* my_input_char: in_channel -> char option *)
let get_char = fun input ->
  try  Some (input_char input)
  with End_of_file -> None
;;

(* update_acc: word -> in_channel -> word *)
let rec update_acc = fun acc -> fun input ->
  match get_char input with
  | None -> acc
  | Some c -> update_acc (c::acc) input
 ;;

(* words: char list -> word -> word list -> word list *)
let rec words = fun l -> fun w -> fun acc ->
  match l, w with
  | [], []    -> acc
  | [], _     -> w :: acc
  | c::cs, [] -> if c=' ' then words cs [] acc
                 else words cs [c] acc
  | c::cs, _  -> if c=' ' then words cs [] (w::acc)
                 else words cs (c::w) acc
;;


(* get_words: string -> word list *)
let get_words = fun file ->
  let lc  = handle_file (update_acc []) file in
  let lw  = words lc [] [] in
  let lw' = List.map (fun w -> to_lower (trim w)) lw in
  List.filter is_valid lw'
;;

(* === PARTIE 2 : RÉCUPÉRATION DE LA LISTE DES MOTS D'UN FICHIER TEXTE ===

   Question 5 : Fonction print_word (Partie 1/2)

   Cette fonction est utilisée pour afficher le mot contenu dans la liste en entrée. 

   print_word : word -> unit = <fun>

   @param  w     Le mot à afficher.
   @return unit  Ne retourne rien.
*)
let print_word = fun (w : word) -> List.iter (Printf.printf "%c") w;;

(* Question 5 : Fonction print_text (Partie 2/2)

   Cette fonction permet d'afficher chaque mot contenu dans une liste de mots. Cela nous permet ainsi de tester le code fourni et la fonction print_word.

   print_text : word list -> unit = <fun>
   
   @param  l     Liste de liste. On a une liste de mots en entrée.
   @return unit  Ne retourne rien.
*)
let print_text = fun l -> List.iter print_word l;;

(* Test de la fonction print_word : *)
print_word hello;;

(* Test de la fonction print_text : 
   On commence par récupérer la liste de mots contenue dans le fichier nommé fichier.txt.
*)
let text = get_words "fichier.txt";;

(* On appelle la fonction print_text, pour afficher chaque mot de la liste. *)
print_text text;;

(* Question 7 : Fonction nub

   La fonction nub prend une liste en entrée, et retourne une liste, avec les doublons en moins. Pour ce faire, on utilise la fonction List.mem, pour vérifier si l'élément sur lequel on est, existe dans la liste. On aurait aussi pu implémenter une fonction de recherche. Mais afin de gagner du temps, on utilise la fonction prévue dans le module List.

   nub : 'a list -> 'a list = <fun>

   @param   l       La liste, dans laquelle il faut retirer les doublons.
   @return 'a list  Retourne la liste donnée en entrée, avec les doublons en moins.
*)
let rec nub = fun l ->
  match l with
  | []     -> []
  | h::t   -> if List.mem h t then nub t else h::nub t
;;

(* Test de la fonction nub : *)
nub hello;;

(* Question 8 : Fonction count_words

   La fonction count_words récupère une liste de mots dans un fichier, sur la donnée d'un chemin vers un fichier texte. On aurait pu utiliser des List.fold_left, ou faire des fonctions auxiliaires pour compter le nombre de mots valides et de mots valides différents. Comme la liste de mots issue de get_words est une liste de mots valides uniquement (il n'y a pas de mots invalides, en sortie de cette fonction), nous pouvons directement utiliser List.length, sans avoir besoin de reparcourir la liste, et de vérifier tous les mots uns par uns.

   Retourne un couple (m, n) où :
           * m est le nombre de mots valides dans le fichier,
           * n est le nombre de mots valides différents dans le fichier.

   count_words : string -> int * int = <fun>

   @param   file   Le chemin vers un fichier contenant du texte.
   @return  tuple  Retourne un couple d'entiers (m, n).
*)
let count_words = fun file ->
  let text = get_words file in
  let m = List.length text in
  let n = List.length (nub text) in
  (m, n)
;;

count_words "fichier.txt";;
count_words "test.txt";;
count_words "lorem.txt";;

(* === PARTIE 3 : LA STRUCTURE DE TRIE === *)
module CharMap = Map.Make (Char) ;;
type trie = T of int * trie CharMap.t ;;

(* Déclaration d'un Trie vide : *)
let empty_trie = T (0, CharMap.empty) ;;

(* Construction du Trie de la figure 1, de façon non efficace : *)
let ns = T (1, CharMap.empty);;
let ne = T (2, CharMap.add 's' ns CharMap.empty);;
let na = T (1, CharMap.empty);;
let nl = T (0, CharMap.add 'a' na (CharMap.add 'e' ne CharMap.empty));; 
let nn = T (1, CharMap.empty);;
let nu = T (0, CharMap.add 'n' nn CharMap.empty);;
let example = T (0, CharMap.add 'l' nl (CharMap.add 'u' nu CharMap.empty));;

(* Question 10 : Fonction trie_get 
   
   La fonction trie_get prend un mot w et un trie t en entrée, pour renvoyer la valeur associée à w, dans t. Si le mot w ne peut pas être retrouvé dans l'arbre (aucun fils ne correspond à la lettre que l'on cherche à lire), alors on renvoie la valeur 0.

   trie_get : word -> trie -> int = <fun>

   @param  w    Le mot à chercher dans l'arbre.
   @param  t    L'arbre t dans lequel chercher le mot w.
   @return int  La valeur associée au mot w, dans l'arbre t.
*)
let rec trie_get = fun (w : word) -> fun t ->
  match t with
  | T (x, y)      -> if (List.length w) < 1 then x
                     else
                         if (CharMap.mem (List.hd w) y) then
	                   trie_get (List.tl w) (CharMap.find (List.hd w) y)
                         else
                             0
;;

(* Test de la fonction trie_get : *)
trie_get ['l'; 'e'; 's'] example;;
trie_get ['l'; 'e'] example;;

(* Question 11 : Fonction trie_incr 

   La fonction trie_incr prend un mot w et un trie tr en entrée, pour renvoyer un nouveau trie tr' dans lequel la valeur associée à w a été augmentée de 1.

   trie_incr : word -> trie -> trie = <fun>

   @param  w    Le mot pour lequel on veut incrémenter de 1 la valeur dans l'arbre.
   @param  t    L'arbre dans lequel on veut incrémenter la valeur de w.
   @return trie L'arbre avec la nouvelle valeur associée à w.
*)
let rec trie_incr = fun (w : word) -> fun tr ->
  match tr with
  | T (v, m)        -> match w with
	               | []           -> T (v+1, m)
                   | h::t         -> let s =
					   if CharMap.mem h m then
			                     CharMap.find h m
					   else T (0, CharMap.empty) in
					 let s' = trie_incr t s in
					 let m' = CharMap.add h s' m in
					 T(v, m')
;;

(* Test de la fonction trie_incr : *)
trie_get ['l'; 'e'; 's'] example;;
let newTrie = trie_incr ['l'; 'e'; 's'] example;;
trie_get ['l'; 'e'; 's'] newTrie;;

(* build_trie : Permet construire un trie au fur et a mesure qu'on lit les mots presents dans input *)
(* build_trie: trie -> word -> in_channel -> word *)
let rec build_trie = fun trie -> fun acc -> fun input ->
  match get_char input with
  | None -> trie
  | Some c -> if (c=' '|| c ='\n' || c ='\t') then let acc2 = to_lower (trim (List.rev acc)) in
                                                                 if is_valid acc2 then let trie2 = trie_incr acc2 trie in build_trie trie2 [] input
                                                                 else build_trie trie [] input
              else build_trie trie (c::acc) input
;;

(* trie_words : Sur la donnee du chemin vers un fichier, renvoie le trie construit a partir des mots de ce fichier. On s'aide du code fourni a section 2 et de la fonction precedente build_trie *)
(* trie_words : string -> trie *)
let trie_words = fun file ->
  let trie_built = handle_file (build_trie empty_trie []) file in
  trie_built
;;
(* Question 12 : Fonction trie_construction

   Cette fonction va nous permettre de parcourir la liste de mots text en entrée, et d'ajouter chaque mots à l'arbre tr.
   
   trie_construction : word list -> trie = <fun>
   
   @param  text La liste de mots à ajouter à l'arbre tr.
   @return trie L'arbre construit à partir de la liste de mots.
*)
let rec trie_construction = fun text -> fun tr ->
  match text with
  | []       -> trie_incr [] tr
  | h::t     -> let tr' = trie_incr h tr in
      		    let final_trie = trie_construction t tr' in
		        final_trie
;;

(* Question 12 : Fonction trie_words

   Fonction qui prend en entrée un chemin vers un fichier, pour renvoyer le trie construit à partir des mots de ce fichier.
   
   trie_words : string -> trie = <fun>
   
   @param  s    La chaîne de caractères correspondant au chemin du fichier à lire.
   @return trie L'arbre construite à partir des mots du fichier donné en entrée.
*)
let trie_words = fun s ->
  let text       = get_words s in
  let empty_trie = T (0, CharMap.empty) in
  let trie_built = trie_construction text empty_trie in
  trie_built
;;

(* Test de la fonction trie_words : *)
let test_trie_words = trie_words "fichier.txt";;
trie_get ['l'; 'e'] test_trie_words;;

(* Question 13 : Fonction trie_card

   Cette fonction compte le nombre de noeuds qui ont une valeur non nulle dans un trie donné.

   trie_card : trie -> int = <fun>
   
   @param   tr   L'arbre pour lequel on doit compter les noeuds avec une valeur non nulle.
   @return  int  Le nombre entier, correspondant au cardinal des noeuds avec une valeur non nulle dans l'arbre tr.
*)
let rec trie_card = fun tr ->
  match tr with
  | T (v, m)        -> if v = 0 then 
                        let acc = 0 in CharMap.fold (fun key -> fun assoc_data -> fun acc -> acc + trie_card assoc_data) m acc
					  else 
                        let acc = 1 in CharMap.fold (fun key -> fun assoc_data -> fun acc -> acc + trie_card assoc_data) m acc
;;

(* Test de la fonction trie_card : *)
trie_card test_trie_words;;
trie_get ['c'; 'o'; 'd'; 'e'] test_trie_words;; 
trie_card example;;

(* Question 14 : Fonction trie_sum

   Cette fonction retourne la somme des valeurs contenues dans les noeuds d'un trie donné.

   trie_sum : trie -> int = <fun>
   
   @param   tr   L'arbre pour lequel on doit faire la somme des valeurs contenues dans le trie.
   @return  int  Le nombre entier, correspondant à la somme des valeurs contenues dans le trie.
*)
let rec trie_sum = fun tr ->
  match tr with
  | T (v, m)       -> CharMap.fold (fun key -> fun assoc_data -> fun acc -> acc + trie_sum assoc_data) m v
;;

(* Test de la fonction trie_sum : *)
trie_sum example;;

(* Question 15 : Fonction count_words_v2 
   
   La fonction count_words_v2 retourne la même chose que count_words mais en utilisant les trie que nous venons d'implémenter, au lieu de listes.

   Retourne un couple (m, n) où :
	   * m est le nombre de mots valides dans le fichier,
	   * n est le nombre de mots valides différents dans le fichier.
   
   count_words_v2 : string -> (int * int) = <fun>
   
   @param   f     Le fichier à lire en entrée.
   @return  tuple Retourne un couple d'entiers (m, n).
*)
let count_words_v2 = fun f ->
  let trie = trie_words f in
  let m = trie_sum trie in
  let n = trie_card trie in
  (m, n)
;;

(* Test de la fonction count_words_v2 : *)
count_words_v2 "lorem.txt";;

(* Question 16 : Fonction trie_longer_word (Question N°3 de l'introduction)

   Cette fonction retourne un couple, le premier élément étant le mot le plus long dans l'arbre. Le deuxième étant sa taille.
   
   trie_longer_word : trie -> (word * int) = <fun>

   @param   tr    Le trie dans lequel chercher le mot le plus long.
   @return  tuple Retourne un couple (word * int), word étant le mot trouvé, et l'entier, sa taille.
*)
let rec trie_longer_word = fun tr ->
  match tr with
  | T (v, m)               -> CharMap.fold (fun key -> fun assoc_data -> fun acc -> 
                              let nextWord = trie_longer_word assoc_data in
                              let size     = match nextWord with (x, y) -> y in
                              let nextKey  = match nextWord with (x, y) -> x in
                              match acc with
                              | (x, y)       -> if y > size then acc else (key::nextKey, size + 1)) m ([], 0)
;;

(* Test de la fonction trie_longer_word : *)
trie_longer_word example;;
let newTrie = trie_incr ['l'; 'e'; 's'; 's'] example;;
trie_get ['l'; 'e'; 's'] newTrie;;
trie_longer_word newTrie;;

(* Question 16 : Fonction trie_most_used_word (Question N°4 de l'introduction)

   Cette fonction permet de connaitre le mot le plus utilisé et son nombre d'occurrences, dans un trie donné.

   trie_most_used_word : trie -> (word * int) = <fun>
   
   @param   tr    Le trie dans lequel chercher le mot le plus utilisé.
   @return  tuple Retourne un couple (word * int), word étant le mot le plus utilisé, et l'entier, son nombre d'occurences.
*)
let rec trie_most_used_word = fun tr ->
	match tr with
	| T (v, m)                -> CharMap.fold (fun key -> fun assoc_data -> fun acc -> 
                                 let nextWord = trie_most_used_word assoc_data in
                                 let nextV    = match nextWord with (x, y) -> y in
                                 let nextKey  = match nextWord with (x, y) -> x in
                                 match acc with
                                 | (x, y)       -> if y > nextV then acc else (key::nextKey, nextV)) m ([], v)
;;

(* Test de la fonction trie_most_used_word : *)
trie_most_used_word example;;
trie_get ['l'; 'e'; 's'] example;;
let newTrie = trie_incr ['l'; 'e'; 's'] example;;
trie_get ['l'; 'e'; 's'] newTrie;;
trie_most_used_word newTrie;;
let trieTest = trie_incr ['u';'n'] example;;
trie_get ['u';'n'] trieTest;;
trie_most_used_word trieTest;;
trie_get ['l'; 'a'] example;;
let newTrie = trie_incr ['l'; 'a'] example;;
let trieLA = trie_incr ['l'; 'a'] newTrie;;
trie_get ['l'; 'a'] trieLA;;
trie_most_used_word trieLA;;

(* Question 16 : Fonction trie_search_words_n_letters (Question N°5 de l'introduction, partie 1/2)

   Cette fonction parcours le trie tr passé en paramètre, et retourne une liste de mots constitués d'au moins n lettres.
   
   trie_search_words_n_letters : trie -> int -> word list -> word -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots d'au moins n lettres.
   @param   n                 Le nombre de lettres que le mot doit compter, pour faire partie de la liste que l'on renvoie.
   @param   wordsAlreadySeen  La liste de mots, qui nous permet d'accumuler les mots d'au moins n lettres, en parcourant l'arbre.
   @param   currentWord       Le mot courrant, incluant toutes les lettres rencontrées depuis la racine, jusqu'au noeud en cours.
   @return  word list         La liste de mots renvoyée à la fin, qui compte tous les mots constitués d'au moins n lettres.
*)
let rec trie_search_words_n_letters = fun tr -> fun n -> fun wordsAlreadySeen -> fun currentWord ->
	match tr with
	| T (v, m)               -> if CharMap.is_empty m then 
                                  if (List.length currentWord) >= n && v > 0 then List.rev (currentWord)::wordsAlreadySeen 
                                  else wordsAlreadySeen 
                                else CharMap.fold (fun key -> fun assoc_data -> fun acc -> let newWord = key::currentWord in 
                                                                                           if (List.length currentWord) >= n && v > 0 then trie_search_words_n_letters assoc_data n (List.rev (currentWord)::acc) newWord
                                                                                           else trie_search_words_n_letters assoc_data n acc newWord) m wordsAlreadySeen
;;

(* Question 16 : Fonction trie_words_more_n_letters (Question N°5 de l'introduction, partie 2/2)

   Cette fonction fait appel à la fonction définie juste avant, pour parcourir l'arbre, et récupérer les mots constitués d'au moins n lettres.
   
   trie_words_more_n_letters : trie -> int -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots d'au moins n lettres.
   @param   k                 Le nombre de lettres que le mot doit compter, pour faire partie de la liste que l'on renvoie.
   @return  word list         La liste de mots renvoyée à la fin, qui compte tous les mots constitués d'au moins n lettres.
*)
let trie_words_more_n_letters = fun tr -> fun n -> trie_search_words_n_letters tr n [] [];;

(* Test de la fonction trie_words_more_n_letters : *)
trie_words_more_n_letters trieLA 2;;

(* Question 16 : Fonction trie_search_words_k_repeat (Question N°6 de l'introduction, partie 1/2)

   Cette fonction parcours le trie tr passé en paramètre, et retourne une liste de mots répétés au moins k fois.
   
   trie_search_words_k_repeat : trie -> int -> word list -> word -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots répétés au moins k fois.
   @param   k                 Le nombre de fois que le mot doit être répété, pour faire partie de la liste que l'on renvoie.
   @param   wordsAlreadySeen  La liste de mots, qui nous permet d'accumuler les mots répétés plus de k fois, en parcourant l'arbre.
   @param   currentWord       Le mot courrant, incluant toutes les lettres rencontrées depuis la racine, jusqu'au noeud en cours.
   @return  word list         La liste de mots renvoyée à la fin, qui compte tous les mots répétés au moins k fois.
*)
let rec trie_search_words_k_repeat = fun tr -> fun k -> fun wordsAlreadySeen -> fun currentWord ->
	match tr with
	| T (v, m)               -> if CharMap.is_empty m then 
                                  if v >= k && v > 0 then (List.rev currentWord)::wordsAlreadySeen 
                                  else wordsAlreadySeen 
                                else CharMap.fold (fun key -> fun assoc_data -> fun acc -> let newWord = key::currentWord in 
                                                                                           if v >= k && v > 0 then trie_search_words_k_repeat assoc_data k ((List.rev currentWord)::acc) newWord
                                                                                           else trie_search_words_k_repeat assoc_data k acc newWord) m wordsAlreadySeen
;;

(* Question 16 : Fonction trie_words_k_repeat (Question N°6 de l'introduction, partie 2/2)

   Cette fonction fait appel à la fonction définie juste avant, pour parcourir l'arbre, et récupérer les mots répétés plus de k fois.
   
   trie_words_k_repeat : trie -> int -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots répétés au moins k fois.
   @param   k                 Le nombre de fois que le mot doit être répété, pour faire partie de la liste que l'on renvoie.
   @return  word list         Une liste de mots qui sont répétés au moins k fois.
*)
let trie_words_k_repeat = fun tr -> fun k -> trie_search_words_k_repeat tr k [] [];;

(* Test de la fonction trie_words_k_repeat : *)
trie_words_k_repeat trieLA 2;;

(* Question 16 : Fonction trie_search_words_with_prefix (Question N°7 de l'introduction, partie 1/2)

   Cette fonction parcours le trie tr passé en paramètre, et retourne une liste de mots dont le préfixe correspond à celui donné en paramètre.
   
   trie_search_words_with_prefix : trie -> word -> word list -> word -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots dont le préfixe est le paramètre prefix.
   @param   prefix            Le préfixe qui doit composer le mot, pour que le mot fasse partie de la liste que l'on renvoie.
   @param   wordsAlreadySeen  La liste de mots, qui nous permet d'accumuler les mots composés du préfixe donné, en parcourant l'arbre.
   @param   currentWord       Le mot courrant, incluant toutes les lettres rencontrées depuis la racine, jusqu'au noeud en cours.
   @return  word list         La liste de mots renvoyée à la fin, qui compte tous les mots composés du préfixe donné en paramètre.
*)
let rec trie_search_words_with_prefix = fun tr -> fun prefix -> fun wordsAlreadySeen -> fun currentWord ->
	match tr with
	| T (v, m)               -> if CharMap.is_empty m then 
                                  if ((List.length prefix) = 0 && v > 0) then (List.rev currentWord)::wordsAlreadySeen 
                                  else wordsAlreadySeen 
                                else CharMap.fold (fun key -> fun assoc_data -> fun acc -> let newWord = key::currentWord in 
                                                                                           if (List.length prefix = 0) then 
                                                                                             if (v > 0) then trie_search_words_with_prefix assoc_data [] ((List.rev currentWord)::acc) newWord
                                                                                             else trie_search_words_with_prefix assoc_data [] acc newWord
                                                                                           else
                                                                                             if (key = List.hd prefix) then trie_search_words_with_prefix assoc_data (List.tl prefix) acc newWord
                                                                                             else trie_search_words_with_prefix assoc_data prefix acc newWord) m wordsAlreadySeen
;;

(* Question 16 : Fonction trie_words_with_prefix (Question N°7 de l'introduction, partie 2/2)

   Cette fonction fait appel à la fonction définie juste avant, pour parcourir l'arbre, et récupérer les mots commençant pas le préfixe donné.
   
   trie_words_with_prefix : trie -> word -> word list = <fun>
   
   @param   tr                Le trie dans lequel chercher les mots dont le préfixe est le paramètre prefix.
   @param   prefix            Le préfixe qui doit composer le mot, pour que le mot fasse partie de la liste que l'on renvoie.
   @return  word list         La liste de mots renvoyée à la fin, qui compte tous les mots composés du préfixe donné en paramètre.
*)
let trie_words_with_prefix = fun tr -> fun prefix -> trie_search_words_with_prefix tr prefix [] [];;

(* Test de la fonction trie_words_with_prefix : *)
trie_words_with_prefix trieLA ['l'; 'e'];;
