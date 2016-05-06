:-set_prolog_flag(toplevel_print_options,[max_depth(0)]).
:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plateau
vide('_').
% nonvide(+NV).
nonvide(NV):-
	vide(V),
	NV\=V.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Joueur
nul(0).
joueur(1).
joueur(2).
joueurSuivant(1,2).
joueurSuivant(2,1).
soi(1).
adversaire(2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% morpionVide(-Morp).
morpionVide([V,V,V,V,V,V,V,V,V]):-
	vide(V).

% plateauVide(-Pl).
plateauVide([M,M,M,M,M,M,M,M,M]):-
	morpionVide(M).

% morpionGagne(+Morp,+J).
morpionGagne([A,A,A,_,_,_,_,_,_],A).
morpionGagne([_,_,_,A,A,A,_,_,_],A).
morpionGagne([_,_,_,_,_,_,A,A,A],A).
morpionGagne([A,_,_,A,_,_,A,_,_],A).
morpionGagne([_,A,_,_,A,_,_,A,_],A).
morpionGagne([_,_,A,_,_,A,_,_,A],A).
morpionGagne([A,_,_,_,A,_,_,_,A],A).
morpionGagne([_,_,A,_,A,_,A,_,_],A).

% suiteOuverte(+Morp,+J).
suiteOuverte([C1,C2,C3,_,_,_,_,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,_,C1,C2,C3,_,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,_,_,_,_,C1,C2,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([C1,_,_,C2,_,_,C3,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,C1,_,_,C2,_,_,C3,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,C1,_,_,C2,_,_,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([C1,_,_,_,C2,_,_,_,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,C1,_,C2,_,C3,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).

% génère la liste des cases jouables
listeCasesJouables([0,1,2,3,4,5,6,7,8]).

% genererListeCasesJouables(+Pm,-Lm).
% génère la liste des cases jouables en fonction du plateau
genererListeCasesJouables(Pm,Lm):-
	genererListeCasesJouables(0,Pm,Lm).
genererListeCasesJouables(_N,[],[]):-!.
genererListeCasesJouables(N,[V|Pm],[N|Lm]):-
	vide(V),!,
	N1 is N+1,
	genererListeCasesJouables(N1,Pm,Lm).
genererListeCasesJouables(N,[NV|Pm],Lm):-
	nonvide(NV),!,
	N1 is N+1,
	genererListeCasesJouables(N1,Pm,Lm).

% selectionnerCaseJouable(+Morp,-ICase).
% sélectionne une case jouable pour la liste
selectionnerCaseJouable(Morp,ICase):-
	genererListeCasesJouables(Morp,Lm),
	select(ICase,Lm,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% jouerALaCase(+Morp,+J,+ICase,-Morpf).
% Le joueur J joue dans la case ICase (si libre) du morpion Morp, le résultat est stocké en Morpf
jouerALaCase(Morp,J,ICase,Morpf):-
	vide(V),
	length(BeforeI,ICase),
	append(BeforeI,[V|PastI],Morp),
	append(BeforeI,[J|PastI],Morpf).

% jouer(+IMorp,+Pm,+Pl,+J,-ICase,-Pmf,-Plf).
% Le joueur J joue dans la case ICase du morpion Morp, puis vérifie si il gagne le morpion ou pas
jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf):-
	length(BeforeIl,IMorp),
	append(BeforeIl,[Morp|PastIl],Pl),
	selectionnerCaseJouable(Morp,ICase),
	jouerALaCase(Morp,J,ICase,Morpf),
	verifierMorpionGagnant(Pm,Morpf,IMorp,Pmf),
	append(BeforeIl,[Morpf|PastIl],Plf).

% trouverMorpionJouable(+Pm,+IMorp0,-IMorp).
% Si IMorp0 est égal à -1 alors, IMorp peut prendre n'importe quel valeur de morpion non rempli, ce qui correspond au premier coup de la partie
% Sinon si IMorp0 correspond à un morpion déjà rempli, IMorp peut prendre n'importe quel valeur de morpion non rempli
% Sinon IMorp0=IMorp
trouverMorpionJouable(_Pm,IMorp0,IMorp):-
	IMorp0 is -1,!, % premier coup des croix
	listeCasesJouables(Lm),
	select(IMorp,Lm,_).
trouverMorpionJouable(Pm,IMorp0,IMorp):-
	nonvide(NV),
	length(BeforeIm0,IMorp0),
	append(BeforeIm0,[NV|_],Pm),!, % morpion IMorp0 terminé
	selectionnerCaseJouable(Pm,IMorp).
trouverMorpionJouable(_Pm,IMorp,IMorp).

%%%%%%

% verifierMorpionGagnant(+Pm,+Morp,+IMorp,-Pmf).
verifierMorpionGagnant(Pm,Morp,IMorp,Pmf):-
	length(BeforeI,IMorp),
	append(BeforeI,[_|PastI],Pm),
	etatMorpion(Morp,E),
	append(BeforeI,[E|PastI],Pmf).

% etatMorpion(+M,-E).
% Informe de l'état E du morpion M
% morpion gagné par un joueur J
etatMorpion(M,J):-
	joueur(J),
	morpionGagne(M,J),!.
% morpion rempli mais gagné par aucun joueur
etatMorpion(M,N):-
	morpionRempli(M),!,
	nul(N).
% morpion non rempli et gagné par aucune joueur
etatMorpion(_M,V):-
	vide(V).

% morpionRempli(+Morp).
morpionRempli([]):-!.
morpionRempli([J|M]):-
	joueur(J),
	morpionRempli(M).

% morpionTermine(+Morp).
morpionTermine(Morp):-
	nonvide(NV),
	\+etatMorpion(Morp,NV).

% jouerUnCoup(+IMorp0,+Pm,+Pl,+J,-Coup,-Pmf,-Plf).
jouerUnCoup(IMorp0,Pm,Pl,J,[IMorp,ICase],Pmf,Plf):-
	trouverMorpionJouable(Pm,IMorp0,IMorp), % le coup se jouera dans le morpion IMorp
	jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dependanceJoueur(1,1).
dependanceJoueur(2,-1).

coefficientCases([5,1,5,1,10,1,5,1,5]).

% calculCoef(+Morp,-E).
calculCoef(Morp,E):-
	coefficientCases(Coefs),
	calculCoef(Morp,Coefs,E).
calculCoef([],[],0).
calculCoef([1|Morp],[C|CS],E):-!,
	calculCoef(Morp,CS,E2),
	E is E2+C.
calculCoef([2|Morp],[C|CS],E):-!,
	calculCoef(Morp,CS,E2),
	E is E2-C.
calculCoef([_|Morp],[_C|CS],E):-
	calculCoef(Morp,CS,E).

% valeurMorpion(+Pm,+IMorp,+J,-E).
valeurMorpion(Pm,_IMorp,J,E):-
	morpionTermine(Pm),!,
	dependanceJoueur(J,C),
	E is 50*C.
valeurMorpion(_Pm,IMorp,J,E):-
	coefficientCases(Coefs),
	length(BeforeI,IMorp),
	append(BeforeI,[Coef|_],Coefs),
	dependanceJoueur(J,C),
	E is Coef*C.

% nombreLignesDispo(+Pm,-E).
nombreLignesDispo(Pm,E):-
	findall(1,suiteOuverte(Pm,1),MAX),
	findall(2,suiteOuverte(Pm,2),MIN),
	length(MAX,Emax),
	length(MIN,Emin),
	E is Emax - Emin.

% valeurConfiguration(+Pm,+Pl,+IMorp,+J,-E).
% calcul la valeur d'une configuration du plateau
valeurConfiguration(Pm,_Pl,_IMorp,_J,1000):-
	morpionGagne(Pm,1).
valeurConfiguration(Pm,_Pl,_IMorp,_J,-1000):-
	morpionGagne(Pm,2).
valeurConfiguration(Pm,_Pl,IMorp,J,E):-
	calculCoef(Pm,E1),
	valeurMorpion(Pm,IMorp,J,E2),
	nombreLignesDispo(Pm,E3),
	E is E1+E2+E3*5.

% alphaBeta(+N,+Pm,+Pl,+IMorp,+J,+Alpha,+Beta,-Val,-BestCoup).
alphaBeta(0,Pm,Pl,IMorp,J,_Alpha,_Beta,Val,_BestCoup):-!,
	valeurConfiguration(Pm,Pl,IMorp,J,Val).
alphaBeta(_N,Pm,Pl,IMorp,J,_Alpha,_Beta,Val,_BestCoup):-
	nonvide(NV),
	etatMorpion(Pm,NV),!,
	valeurConfiguration(Pm,Pl,IMorp,J,Val).
alphaBeta(N,Pm,Pl,IMorp0,J,Alpha,Beta,Val,BestCoup):-
	N>0,
	NS is N-1,
	Alpha2 is -Beta, Beta2 is -Alpha,
	findall((Coup,Pm2,Pl2),jouerUnCoup(IMorp0,Pm,Pl,J,Coup,Pm2,Pl2),LCoups),
	evaluerEtChoisir(NS,Pm,Pl,LCoups,J,Alpha2,Beta2,nil,(BestCoup,Val)).

% evaluerEtChoisir(+N,+Pm,+Pl,+LCoups,+J,+Alpha,+Beta,+Record,-BestCoup).
evaluerEtChoisir(N,Pm,Pl,[([IMorp,ICase],Pm2,Pl2)|LCoups],J,Alpha,Beta,Record,BestCoup):-
	joueurSuivant(J,JS),
	alphaBeta(N,Pm2,Pl2,ICase,JS,Alpha,Beta,Val,_Coup),
	Val2 is -Val,
	choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val2,[IMorp,ICase],Record,BestCoup).
evaluerEtChoisir(_N,_Pm,_Pl,[],_J,Alpha,_Beta,Coup,(Coup,Alpha)).

% choisir(+N,+Pm,+Pl,+LCoups,+J,+Alpha,+Beta,+Val,+Coup,+Record,-BestCoup).
choisir(_N,_Pm,_Pl,_LCoups,_J,_Alpha,Beta,Val,Coup,_Record,(Coup,Val)):-
	Val>=Beta,!.
choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val,Coup,_Record,BestCoup):-
	Alpha<Val,Val<Beta,!,
	evaluerEtChoisir(N,Pm,Pl,LCoups,J,Val,Beta,Coup,BestCoup).
choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val,_Coup,Record,BestCoup):-
	Val=<Alpha,!,
	evaluerEtChoisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Record,BestCoup).

% morpionPm(+Pl,-Pm).
% creer le morpion en fonction du plateau complet
morpionPm([],[]):-!.
morpionPm([Morp|Pl],[E|Pm]):-
	etatMorpion(Morp,E),
	morpionPm(Pl,Pm).

sousPlateauGagne(Pl,N):-
	morpionPm(Pl,Pm),
	countOccurences(Pm,1,N).
	
countOccurences([],_,0):-!.
countOccurences([X|L],X,N):-!,
	countOccurences(L,X,NS),
	N is NS+1.
countOccurences([_|L],X,N):-
	countOccurences(L,X,N).

% meilleurCoup(+N,+Pl,+IMorp,+J,-Coup).
% trouve le meilleur coup pour le joueur J
meilleurCoup(_N,Pl,-1,_J,[4,8]):-
	plateauVide(Pl),!.
meilleurCoup(N,Pl,IMorp,J,Coup):-
	morpionPm(Pl,Pm),
	alphaBeta(N,Pm,Pl,IMorp,J,-2000,2000,_Val,Coup).

% prochainCoup(+N,+Pl,+IMorp,-Coup).
% trouve le meilleur coup pour soi
prochainCoup(N,Pl,IMorp,Coup):-
	soi(J),
	meilleurCoup(N,Pl,IMorp,J,Coup).