#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/fonctionsTCP.h"
#include "../../include/protocoleTicTacToe.h"
#include "../../include/constants.h"

main(int argc, char **argv)
{

  int sock,               /* descripteur de la socket locale */
      err;                /* code d'erreur */


  /* CONNEXION AU SERVEUR */

  // check argv[1] et argv[2]
  
  sock = socketClient(argv[1], atoi(argv[2]));
  if (sock < 0)
  { 
    printf("client : erreur socketClient\n");
    exit(2);
  }  
  
  /* DEMANDE DE PARTIE */
  
  TypPartieReq requestGame;
  requestGame.idRequest = PARTIE;
  strcpy(requestGame.nomJoueur, OURNAME);
  err = send(sock, &requestGame, sizeof(TypPartieReq), 0);
  if (err != sizeof(TypPartieReq))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(3);
  }
  
  /* REPONSE DU SERVEUR */
  
  TypPartieRep initialisationData;
  err = recv(sock, &initialisationData, sizeof(TypPartieRep), 0);
  if (err < 0)
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(4);
  }
  if(initialisationData.err != ERR_OK)
  {
    switch(initialisationData.err)
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
    exit(5);
  }
  const TypSymbol symbol = initialisationData.symb;
  const char* opponentName = initialisationData.nomAdvers;
  int tictactoeWon = 0;
  
  /* DEBUT DE LA PARTIE */
  
  TypCoupReq play;
  play.idRequest = COUP;
  play.symbolJ = symbol;
  
  if(symbol == CROIX) // On commence
  {
    TypCase playPosition;     /* RECUPERER LE COUP DEPUIS LE PROLOG */
    playPosition.numPlat;     /* = A, B, C, D, E, F, G, H, I */
    playPosition.numSousPlat; /* = UN, DEUX, TROIS, QUATRE, CINQ, SIX, SEPT, HUIT, NEUF */
    play.pos = playPosition;
    play.nbSousPlatG = tictactoeWon;
    
    err = send(sock, &play, sizeof(TypCoupReq), 0);
    if (err != sizeof(TypCoupReq))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(6);
    }
    
    TypCoupRep playResult;
    err = recv(sock, &playResult, sizeof(TypCoupRep), 0);
    if (err < 0)
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(7);
    }
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
      exit(8);
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
      exit(9);
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
      exit(0);
    }
    TypCoupReq opponentPlay;
    err = recv(sock, &opponentPlay, sizeof(TypCoupReq), 0);
    if (err < 0)
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(10);
    }
  }
  else
  {
  }
  
  shutdown(sock, SHUT_RDWR);
  close(sock);
}
