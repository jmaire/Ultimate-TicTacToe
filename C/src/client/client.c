#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/client/client.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int demandePartie(int sock)
{
  TypPartieReq requestGame;
  requestGame.idRequest = PARTIE;
  strcpy(requestGame.nomJoueur, OURNAME);
  int err = send(sock, &requestGame, sizeof(TypPartieReq), 0);
  if(err != sizeof(TypPartieReq))
    return 1;
  return 0;
}

int reponsePartie(int sock, TypPartieRep* initialisationData)
{
  int err = recv(sock, initialisationData, sizeof(TypPartieRep), 0);
  if(err < 0)
    return 1;

  if((*initialisationData).err != ERR_OK)
  {
    switch((*initialisationData).err)
    {
    case ERR_PARTIE :
      perror("Erreur sur la demande de partie");
      break;
	  case ERR_COUP :
      perror("Erreur sur le coup joue");
      break;
	  case ERR_TYP :
      perror("Erreur sur le type de requete");
      break;
    default :
      break;
    }
    return 1;
  }
  return 0;
}

int demandeCoup(int sock, TypCoupReq* coup, int tictactoeWon)
{
  //TODO
  TypCase playPosition;     /* RECUPERER LE COUP DEPUIS LE PROLOG */
  playPosition.numPlat;     /* = A, B, C, D, E, F, G, H, I */
  playPosition.numSousPlat; /* = UN, DEUX, TROIS, QUATRE, CINQ, SIX, SEPT, HUIT, NEUF */
  (*coup).pos = playPosition;
  (*coup).nbSousPlatG = tictactoeWon;
    
  int err = send(sock, coup, sizeof(TypCoupReq), 0);
  if(err != sizeof(TypCoupReq))
    return 1;
  return 0;
}

int reponseCoup(int sock)
{
  TypCoupRep playResult;
  int err = recv(sock, &playResult, sizeof(TypCoupRep), 0);
  if (err < 0)
    return 1;
  if(playResult.err != ERR_OK)
  {
    switch(playResult.err)
    {
    case ERR_PARTIE :
      perror("Erreur sur la demande de partie");
      break;
    case ERR_COUP :
      perror("Erreur sur le coup joue");
      break;
	  case ERR_TYP :
      perror("Erreur sur le type de requete");
      break;
    default :
      break;
    }
    return 1;
  }

  if(playResult.validCoup != VALID)
  {
    switch(playResult.validCoup)
    {
    case TIMEOUT :
      perror("Erreur le cout a été timeout");
      break;
   case TRICHE :
      perror("Erreur le coup est de la triche");
      break;
    default :
      break;
    }
    return 1;
  }

  if(playResult.propCoup != CONT)
  {
    switch(playResult.propCoup)
    {
    case GAGNANT :
      printf("Hourra gagné !");
      break;
    case NULLE :
      printf("Egalité");
      break;
	  case PERDU :
      printf("Bouuh perdu ! (c'est la faute de l'IA de Julien)");
      break;
    default :
      break;
    }
    return 1;
  }
  return 0;
}


int aNousDeJouer(int sock, TypCoupReq* coup, int tictactoeWon)
{
  if(demandeCoup(sock,coup,tictactoeWon))
    return 1;
  if(reponseCoup(sock))
    return 1;
  return 0;
}
