:-set_prolog_flag(toplevel_print_options,[max_depth(0)]).
:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plateau
vide('_').
nonvide(NV):-
	vide(V),
	NV\=V.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Joueur
nul(0).
joueur(1).
joueur(2).
%symbole(1,'X').
%symbole(2,'O').
joueurSuivant(1,2).
joueurSuivant(2,1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

morpionVide([V,V,V,V,V,V,V,V,V]):-
	vide(V).

plateauVide([M,M,M,M,M,M,M,M,M]):-
	morpionVide(M).

morpionGagne([A,A,A,_,_,_,_,_,_],A).
morpionGagne([_,_,_,A,A,A,_,_,_],A).
morpionGagne([_,_,_,_,_,_,A,A,A],A).
morpionGagne([A,_,_,A,_,_,A,_,_],A).
morpionGagne([_,A,_,_,A,_,_,A,_],A).
morpionGagne([_,_,A,_,_,A,_,_,A],A).
morpionGagne([A,_,_,_,A,_,_,_,A],A).
morpionGagne([_,_,A,_,A,_,A,_,_],A).

suiteOuverte([C1,C2,C3,_,_,_,_,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,_,C1,C2,C3,_,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,_,_,_,_,C1,C2,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([C1,_,_,C2,_,_,C3,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,C1,_,_,C2,_,_,C3,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,C1,_,_,C2,_,_,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([C1,_,_,_,C2,_,_,_,C3],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).
suiteOuverte([_,_,C1,_,C2,_,C3,_,_],J):- (vide(C1) | C1==J),(vide(C2) | C2==J),(vide(C3) | C3==J).

listeCasesJouables([0,1,2,3,4,5,6,7,8]).

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

selectionnerCaseJouable(Morp,ICase):-
	genererListeCasesJouables(Morp,Lm),
	select(ICase,Lm,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Le joueur J joue dans la case I (si libre) du morpion Morp, le résultat est stocké en Morpf
jouerALaCase(Morp,J,ICase,Morpf):-
	vide(V), % TOREMOVE
	length(BeforeI,ICase),
	append(BeforeI,[V|PastI],Morp),
	append(BeforeI,[J|PastI],Morpf).

jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf):-
	length(BeforeIl,IMorp),
	append(BeforeIl,[Morp|PastIl],Pl),
	selectionnerCaseJouable(Morp,ICase),
	jouerALaCase(Morp,J,ICase,Morpf),
	verifierMorpionGagnant(Pm,Morpf,IMorp,Pmf),
	append(BeforeIl,[Morpf|PastIl],Plf).

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

verifierMorpionGagnant(Pm,Morp,I,Pmf):-
	length(BeforeI,I),
	append(BeforeI,[_|PastI],Pm),
	etatMorpion(Morp,E),
	append(BeforeI,[E|PastI],Pmf).

etatMorpion(M,J):-
	joueur(J),
	morpionGagne(M,J),!.
etatMorpion(M,N):-
	morpionRempli(M),!,
	nul(N).
etatMorpion(_M,V):-
	vide(V).

morpionRempli([]):-!.
morpionRempli([J|M]):-
	joueur(J),
	morpionRempli(M).

morpionTermine(Morp):-
	nonvide(NV),
	\+etatMorpion(Morp,NV).

jouerUnCoup(IMorp0,Pm,Pl,J,[IMorp,ICase],Pmf,Plf):-
	trouverMorpionJouable(Pm,IMorp0,IMorp), % le coup se jouera dans le morpion IMorp
	jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf).

deroulement(_IMorp,Pm,Pl,_J,Pm,Pl):-
	morpionTermine(Pm),!.
deroulement(IMorp0,Pm,Pl,J,Pmf,Plf):-
	jouerUnCoup(IMorp0,Pm,Pl,J,[_,ICase],Pm2,Pl2),
	joueurSuivant(J,JS),
	deroulement(ICase,Pm2,Pl2,JS,Pmf,Plf).

test(Pmf,Plf):-
	morpionVide(Pm),
	plateauVide(Pl),
	deroulement(-1,Pm,Pl,1,Pmf,Plf).

test2(Coup,Pmf,Plf):-
	morpionVide(Pm),
	plateauVide(Pl),
	jouerUnCoup(-1,Pm,Pl,1,Coup,Pmf,Plf).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dependanceJoueur(1,1).
dependanceJoueur(2,-1).

coefficientCases([5,1,5,1,10,1,5,1,5]).

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

valeurConfiguration(Pm,_Pl,_IMorp,_J,1000):-
	morpionGagne(Pm,1).
valeurConfiguration(Pm,_Pl,_IMorp,_J,-1000):-
	morpionGagne(Pm,2).
valeurConfiguration(Pm,_Pl,IMorp,J,E):-
	calculCoef(Pm,E1),
	valeurMorpion(Pm,IMorp,J,E2),
	E is E1+E2.

alphaBeta(0,Pm,Pl,IMorp,J,_Alpha,_Beta,Val,_BestCoup):-
	valeurConfiguration(Pm,Pl,IMorp,J,Val).
alphaBeta(N,Pm,Pl,IMorp0,J,Alpha,Beta,Val,BestCoup):-
	N>0,
	NS is N-1,
	Alpha2 is -Beta, Beta2 is -Alpha,
	findall((Coup,Pm2,Pl2),jouerUnCoup(IMorp0,Pm,Pl,J,Coup,Pm2,Pl2),LCoups),
	%jouerUnCoup(IMorp0,Pm,Pl,J,Coup,Pm2,Pl2),
	evaluerEtChoisir(NS,Pm,Pl,LCoups,J,Alpha2,Beta2,nil,(BestCoup,Val)).

evaluerEtChoisir(N,Pm,Pl,[([IMorp,ICase],Pm2,Pl2)|LCoups],J,Alpha,Beta,Record,BestCoup):-
	joueurSuivant(J,JS),
	%jouer(IMorp,Pm,Pl,J,ICase,Pm2,Pl2),
	alphaBeta(N,Pm2,Pl2,ICase,JS,Alpha,Beta,Val,_Coup),
	Val2 is -Val,
	choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val2,[IMorp,ICase],Record,BestCoup).
evaluerEtChoisir(_N,_Pm,_Pl,[],_J,Alpha,_Beta,Coup,(Coup,Alpha)).

choisir(_N,_Pm,_Pl,_LCoups,_J,_Alpha,Beta,Val,Coup,_Record,(Coup,Val)):-
	Val>=Beta,!.
choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val,Coup,_Record,BestCoup):-
	Alpha<Val,Val<Beta,!,
	evaluerEtChoisir(N,Pm,Pl,LCoups,J,Val,Beta,Coup,BestCoup).
choisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Val,_Coup,Record,BestCoup):-
	Val=<Alpha,!,
	evaluerEtChoisir(N,Pm,Pl,LCoups,J,Alpha,Beta,Record,BestCoup).

morpionPm([],[]):-!.
morpionPm([Morp|Pl],[E|Pm]):-
	etatMorpion(Morp,E),
	morpionPm(Pl,Pm).
	
%TODO déterminer Pm pour le supprimer
prochainCoup(N,Pl,IMorp,J,Coup):-
	morpionPm(Pl,Pm),
	alphaBeta(N,Pm,Pl,IMorp,J,-2000,2000,_Val,Coup).

tAB([IMorp,ICase]):-
	plateauVide(Pl),
	prochainCoup(5,Pl,-1,1,[IMorp,ICase]).








%%%%%
dessinerPlateau([]):-
	!,nl.
dessinerPlateau([[],[],[]|Pl]):-
	write('-----------------------'),nl,
	dessinerPlateau(Pl).
dessinerPlateau([Morp1,Morp2,Morp3|Pl]):-
	Morp1 = [C11,C12,C13|LC1],
	Morp2 = [C21,C22,C23|LC2],
	Morp3 = [C31,C32,C33|LC3],
	write(' '),write(C11),
	write('|'),write(C12),
	write('|'),write(C13),
	write('   '),write(C21),
	write('|'),write(C22),
	write('|'),write(C23),
	write('   '),write(C31),
	write('|'),write(C32),
	write('|'),write(C33),nl,
	write('------- ------- -------'),nl,
	dessinerPlateau([LC1,LC2,LC3|Pl]).

testD(Pl):-
	plateauVide(Pl),
	dessinerPlateau(Pl).
	
testtruc(M,M).
testtruc(M,M2):-
	M2 is -M.
