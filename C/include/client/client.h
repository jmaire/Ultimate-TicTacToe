#ifndef CLIENT_H
#define CLIENT_H

#include "../../include/protocoleTicTacToe.h"

int demandePartie(int sock);
int reponsePartie(int sock, TypPartieRep* initialisationData);

int demandeCoup(int sock, TypCoupReq* coup, int tictactoeWon);
int reponseCoup(int sock);

int aNousDeJouer(int sock, TypCoupReq* coup, int tictactoeWon);

int receptionCoupAdversaire(int sock, TypCoupReq* coup);

int aToiDeJouer(int sock);

#endif //CLIENT_H
