#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/client/client.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int main(int argc, char **argv)
{
  int sock,               /* descripteur de la socket locale */
      sockJava;

  // check argv[1]
  if(argc!=2) {
    perror("Mauvais arguments");
  }

  /* CONNEXION AU JAVA */

  if(connexionJava(&sockJava))
  {
    printf("client : erreur socket Java\n");
    exit(1);
  }

  /* CONNEXION AU SERVEUR */
  
  sock = socketClient(NOM_MACHINE, atoi(argv[1]));
  if (sock < 0)
  { 
    printf("client : erreur socketClient\n");
    exit(2);
  }  
  
  /* DEMANDE DE PARTIE */
  if(demandePartie(sock))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(3);
  }

  /* REPONSE DU SERVEUR */
  TypPartieRep initialisationData;
  if(reponsePartie(sock,&initialisationData))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(4);
  }
  const TypSymbol symbol = initialisationData.symb;
  const char* opponentName = initialisationData.nomAdvers;
  int tictactoeWon = 0;
  
  /* DEBUT DE LA PARTIE */
  
  TypCoupReq coup;
  coup.idRequest = COUP;
  coup.symbolJ = symbol;

  if(symbol == CROIX) // On commence
  {
    if(aNousDeJouer(sock,sockJava,&coup))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(6);
    }
  }

  while(1)
  {
    if(aToiDeJouer(sock, sockJava))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(7);
    }

    if(aNousDeJouer(sock,sockJava,&coup))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(6);
    }
  }
  
  shutdown(sock, SHUT_RDWR);
  close(sock);

  return 0;
}
