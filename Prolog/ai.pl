:-set_prolog_flag(toplevel_print_options,[max_depth(0)]).
:-use_module(library(lists)).

% range(L,H,R) retourne dans R une valeur entre L compris et H compris
range(Low,_,Low).
range(Low,High,Sol):-
	NewLow is Low+1,
	NewLow=<High,
	range(NewLow,High,Sol).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

joueur(1).
joueur(2).
joueurSuivant(1,2).
joueurSuivant(2,1).

morpionVide([0,0,0,0,0,0,0,0,0]).

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

jouerALaCaseI(Morp,J,I,Morpf):-
	length(BeforeI,I),
	append(BeforeI,[AtI|PastI],Morp),
	AtI is 0,
	append(BeforeI,[J|PastI],Morpf).

jouerDansLeMorpion(Morp,J,Morpf):-
	\+morpionTermine(Morp),
	range(0,8,I),
	jouerALaCaseI(Morp,J,I,Morpf).

jouer(Pm,Pl,J,Pmf,Plf):-
	range(0,8,I),
	length(BeforeI,I),
	append(BeforeI,[Morp|PastI],Pl),
	jouerDansLeMorpion(Morp,J,Morpf),
	verifierMorpionGagnant(Pm,Morpf,I,Pmf),
	append(BeforeI,[Morpf|PastI],Plf).

verifierMorpionGagnant(Pm,Morp,_,Pm):-
	\+morpionTermine(Morp),!.
verifierMorpionGagnant(Pm,Morp,I,Pmf):-
	morpionGagnePar(Morp,J),
	length(BeforeI,I),
	append(BeforeI,[AtI|PastI],Pm),
	AtI is 0,
	append(BeforeI,[J|PastI],Pmf).

morpionGagnePar(M,J):-
	joueur(J),
	morpionGagne(M,J),!.
morpionGagnePar(M,0):-
	morpionTermine(M).

morpionTermine([]).
morpionTermine(M):-
	joueur(J),
	morpionGagne(M,J).
morpionTermine([J|M]):-
	joueur(J),
	morpionTermine(M).

deroulement(Pm,Pl,_,Pm,Pl):-
	morpionTermine(Pm),!.
deroulement(Pm,Pl,J,Pmf,Plf):-
	jouer(Pm,Pl,J,Pm2,Pl2),
	joueurSuivant(J,JS),
	deroulement(Pm2,Pl2,JS,Pmf,Plf).

test(Pmf,Plf):-
	morpionVide(Pm),
	plateauVide(Pl),
	deroulement(Pm,Pl,1,Pmf,Plf).
	