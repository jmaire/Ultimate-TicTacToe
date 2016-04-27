#ifndef SERVEUR_H
#define SERVEUR_H

#include "../../include/protocoleTicTacToe.h"

int connexionJoueur(int sock, int* sockJoueur);

int receptionDemandesPartie(int sock, int sockJoueur1, int sockJoueur2, int* joueurCroix);

int traitementDemandePartie(int sock, TypPartieRep* repJoueur, char* nomJoueur);

int transmissionCoup(int joueurQuiDoitJouer, int autreJoueur, TypCoupReq* coupJoueur);

int envoieReponseCoup(int numJoueurQuiDoitJouer, int joueurQuiDoitJouer, int autreJoueur, TypCoupReq coupReq, TypCoupRep* coupTeste);

#endif //SERVEUR_H
