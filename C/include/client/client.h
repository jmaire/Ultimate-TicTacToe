#ifndef CLIENT_H
#define CLIENT_H

#include "../../include/protocoleTicTacToe.h"

int demandePartie(int sock);
int reponsePartie(int sock, TypPartieRep* initialisationData);

int demandeCoup(int sock, int sockJava, TypCoupReq* coup);
int reponseCoup(int sock);

int aNousDeJouer(int sock, int sockJava, TypCoupReq* coup);

int receptionCoupAdversaire(int sock, TypCoupReq* coup);

int aToiDeJouer(int sock, int sockJava);

/******************** JAVA ********************/

int connexionJava(int* sock);

int envoyerAJava(int sock, TypCoupReq* coup);
int recevoirDeJava(int sock, TypCoupReq* coup);

#endif //CLIENT_H
