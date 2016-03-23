#ifndef SERVEUR_H
#define SERVEUR_H

#include "../../include/protocoleTicTacToe.h"

int connexionJoueur(int sock, int* sockJoueur);

int receptionDemandesPartie(int sock, int sockJoueur1, int sockJoueur2);

int traitementDemandePartie(int sock, TypPartieRep* repJoueur, char* nomJoueur);

#endif //SERVEUR_H
