:-set_prolog_flag(toplevel_print_options,[max_depth(0)]).
:-use_module(library(lists)).

% range(L,H,R) retourne dans R une valeur entre L compris et H compris
range(Low,_,Low).
range(Low,High,Sol):-
	NewLow is Low+1,
	NewLow=<High,
	range(NewLow,High,Sol).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vide('_'):-!.
nul(0):-!.
joueur(1).
joueur(2).
joueurSuivant(1,2):-!.
joueurSuivant(2,1):-!.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Le joueur J joue dans la case I (si libre) du morpion Morp, le résultat est stocké en Morpf
jouerALaCaseI(Morp,J,ICase,Morpf):-
	vide(V),
	length(BeforeI,ICase),
	append(BeforeI,[V|PastI],Morp),
	append(BeforeI,[J|PastI],Morpf).

% Le joueur J joue dans une case du morpion Morp, le résultat est stocké en Morpf
jouerDansLeMorpion(Morp,J,ICase,Morpf):-
	range(0,8,ICase),
	jouerALaCaseI(Morp,J,ICase,Morpf).

%
jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf):-
	length(BeforeIl,IMorp),
	append(BeforeIl,[Morp|PastIl],Pl),
	jouerDansLeMorpion(Morp,J,ICase,Morpf),
	verifierMorpionGagnant(Pm,Morpf,IMorp,Pmf),
	append(BeforeIl,[Morpf|PastIl],Plf).

% Debut
jouerIci(IMorp0,Pm,Pl,J,ICase,Pmf,Plf):-
	IMorp0 is -1,!,
	vide(V),
	range(0,8,IMorp),
	length(BeforeIm,IMorp),
	append(BeforeIm,[V|_],Pm), % morpion non termine
	jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf).
jouerIci(IMorp0,Pm,Pl,J,ICase,Pmf,Plf):-
	vide(V),
	length(BeforeIm0,IMorp0),
	append(BeforeIm0,[NV|_],Pm),
	NV \= V,!,
	range(0,8,IMorp), IMorp\=IMorp0,
	length(BeforeIm,IMorp),
	append(BeforeIm,[V|_],Pm), % morpion non termine
	jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf).
jouerIci(IMorp,Pm,Pl,J,ICase,Pmf,Plf):-
	jouer(IMorp,Pm,Pl,J,ICase,Pmf,Plf).

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

deroulement(_,Pm,Pl,_,_,Pm,Pl):-
	morpionTermine(Pm),!.
deroulement(IMorp,Pm,Pl,J,_,Pmf,Plf):-
	joueurSuivant(J,JS),
	jouerIci(IMorp,Pm,Pl,J,ICase2,Pm2,Pl2),
	deroulement(ICase2,Pm2,Pl2,JS,_,Pmf,Plf).

test(Pmf,Plf):-
	morpionVide(Pm),
	plateauVide(Pl),
	deroulement(-1,Pm,Pl,1,_,Pmf,Plf).
