#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/client/client.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int demandePartie(int sock, char* name)
{
  TypPartieReq requestGame;
  requestGame.idRequest = PARTIE;
  strcpy(requestGame.nomJoueur, name);
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

int demandeCoup(int sock, int sockJava, TypCoupReq* coup)
{
  if(recevoirDeJava(sockJava, coup))
    return 1;
    
  int err = send(sock, coup, sizeof(TypCoupReq), 0);
  if(err != sizeof(TypCoupReq))
    return 1;
  return 0;
}

int reponseCoup(int sock)
{
  TypCoupRep playResult;
  int err = recv(sock, &playResult, sizeof(TypCoupRep), 0);printf("recu %d\n",err);
  if (err < 0)
    return 1;
  if(playResult.err != ERR_OK)
  {
    switch(playResult.err)
    {
    case ERR_PARTIE :
      printf("Erreur sur la demande de partie\n");
      break;
    case ERR_COUP :
      printf("Erreur sur le coup joue\n");
      break;
	  case ERR_TYP :
      printf("Erreur sur le type de requete\n");
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
      printf("Erreur le cout a été timeout\n");
      break;
   case TRICHE :
      printf("Erreur le coup est de la triche\n");
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
      printf("Hourra gagné !\n");
      break;
    case NULLE :
      printf("Egalité\n");
      break;
	  case PERDU :
      printf("Bouuh perdu ! (c'est la faute de l'IA de Julien)\n");
      break;
    default :
      break;
    }
    return 1;
  }
  return 0;
}

int aNousDeJouer(int sock, int sockJava, TypCoupReq* coup)
{
  printf("C'est à nous\n");
  if(demandeCoup(sock,sockJava,coup))
    return 1;
  if(reponseCoup(sock))
    return 1;
  return 0;
}

int receptionCoupAdversaire(int sock, TypCoupReq* coup)
{
  int err = recv(sock, coup, sizeof(TypCoupReq), 0);
  if (err < 0)
    return 1;
  return 0;
}

int aToiDeJouer(int sock, int sockJava)
{
  printf("C'est à lui\n");
  TypCoupReq opponentPlay;
  
  if(receptionCoupAdversaire(sock, &opponentPlay))
    return 1;
  
  if(envoyerAJava(sockJava, &opponentPlay))
    return 1;
  
  if(reponseCoup(sock)) //TODO peut etre besoin d'utiliser une autre fonction 
    return 1;           //si on ne veut pas gerer la validation du coup adverse
    
  if(departTimerJava(sockJava))
    return 1;
  return 0;
}

/******************** JAVA ********************/

int connexionJava(char* nomMachine, int* sock)
{
  *sock = socketClient(nomMachine, PORT_JAVA_SOCKET);
  if (*sock < 0)
    return 1;
  return 0;
}

int informerJava(int sockJava, char onCommence)
{
  int err = send(sockJava, &onCommence, sizeof(char), 0);
  if(err != sizeof(char))
    return 1;
  return 0;
}

int departTimerJava(int sockJava)
{
  char g = 'g';

  int err = send(sockJava, &g, sizeof(char), 0);
  if(err != sizeof(char))
    return 1;
  return 0;
}

int envoyerAJava(int sock, TypCoupReq* coup)
{
  int coupFormat = (*coup).pos.numPlat*10+(*coup).pos.numSousPlat;

  int err = send(sock, &coupFormat, sizeof(int), 0);
  if(err != sizeof(int))
    return 1;
  return 0;
}

int recevoirDeJava(int sock, TypCoupReq* coup)
{
  int coupRep;
  int err = recv(sock, &coupRep, sizeof(int), 0);
  if (err < 0)
    return 1;
  
  coupRep = htonl(coupRep);
  
  (*coup).pos.numPlat = (int)(coupRep/100);
  (*coup).pos.numSousPlat = (int)((coupRep%100)/10);
  (*coup).nbSousPlatG = coupRep%10;
  
  return 0;
}

