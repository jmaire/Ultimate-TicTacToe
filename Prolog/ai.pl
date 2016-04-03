:-set_prolog_flag(toplevel_print_options,[max_depth(0)]).
:-use_module(library(lists)).

% range(L,H,R) retourne dans R une valeur entre L compris et H compris
range(Low,_,Low).
range(Low,High,Sol):-
	NewLow is Low+1,
	NewLow=<High,
	range(NewLow,High,Sol).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

taille(9).
vide('_').
nonvide(NV):-
	vide(V),
	NV\=V.
nul(0).
joueur(1).
joueur(2).
joueurSuivant(1,2).
joueurSuivant(2,1).

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

listeCasesJouables([0,1,2,3,4,5,6,7,8]).

genererListeCasesJouables(Pm,Lm):-
	genererListeCasesJouables(0,Pm,Lm).
genererListeCasesJouables(_,[],[]):-!.
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

%
jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf):-
	length(BeforeIl,IMorp),
	append(BeforeIl,[Morp|PastIl],Pl),
	selectionnerCaseJouable(Morp,ICase),
	jouerALaCase(Morp,J,ICase,Morpf),
	verifierMorpionGagnant(Pm,Morpf,IMorp,Pmf),
	append(BeforeIl,[Morpf|PastIl],Plf).

trouverMorpionJouable(_,IMorp0,IMorp):-
	IMorp0 is -1,!, % premier coup des croix
	listeCasesJouables(Lm),
	select(IMorp,Lm,_).
trouverMorpionJouable(Pm,IMorp0,IMorp):-
	nonvide(NV),
	length(BeforeIm0,IMorp0),
	append(BeforeIm0,[NV|_],Pm),!, % morpion IMorp0 terminé
	selectionnerCaseJouable(Pm,IMorp).
trouverMorpionJouable(_,IMorp,IMorp).

%%%%%%

verifierMorpionGagnant(Pm,Morp,_,Pm):-
	\+morpionTermine(Morp),!.
verifierMorpionGagnant(Pm,Morp,I,Pmf):-
	joueur(J),
	morpionGagnePar(Morp,J),
	vide(V),
	length(BeforeI,I),
	append(BeforeI,[V|PastI],Pm),
	append(BeforeI,[J|PastI],Pmf).

morpionGagnePar(M,J):-
	joueur(J),
	morpionGagne(M,J),!.
morpionGagnePar(M,0):-
	morpionTermine(M).

morpionTermine(M):-
	joueur(J),
	morpionGagne(M,J),!.
morpionTermine(M):-
	morpionRempli(M).

morpionRempli([]):-!.
morpionRempli([J|M]):-
	joueur(J),
	morpionRempli(M).

deroulement(_,Pm,Pl,_,Pm,Pl):-
	morpionTermine(Pm),!.
deroulement(IMorp0,Pm,Pl,J,Pmf,Plf):-
	trouverMorpionJouable(Pm,IMorp0,IMorp), % le coup se jouera dans le morpion IMorp
	jouer(IMorp,Pm,Pl,J,ICase,Pm2,Pl2),
	joueurSuivant(J,JS),
	deroulement(ICase,Pm2,Pl2,JS,Pmf,Plf).

test(Pmf,Plf):-
	morpionVide(Pm),
	plateauVide(Pl),
	deroulement(-1,Pm,Pl,1,Pmf,Plf).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%