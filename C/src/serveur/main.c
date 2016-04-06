#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <signal.h>

#include "../../include/serveur/serveur.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int main(int argc, char **argv)
{
  int sock,               /* descripteur de la socket locale */
      err,                /* code d'erreur */
      sockJoueur1,        /* descripteur de la socket client J1 */
      sockJoueur2;        /* descripteur de la socket client J2 */
      

  /* CREATION DE SOCKET SERVEUR */

  // check argv[2]
  if(argc!=2) {
    perror("Mauvais arguments");
  } 

  sock = socketServeur(atoi(argv[1]));
  if (sock < 0)
  { 
    printf("serveur : erreur socketServeur\n");
    exit(2);
  }

  
  /* CONNEXION DES DEUX JOUEURS */
  
  if(connexionJoueur(sock, &sockJoueur1))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(3);
  }

  if(connexionJoueur(sock, &sockJoueur2))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(3);
  }
  
  /* RECEPTION DES REQUETES PARTIE */
  
  const int sumSock = sockJoueur1 + sockJoueur2;
  int joueurQuiDoitJouer;
  if(receptionDemandesPartie(sock, sockJoueur1, sockJoueur2, &joueurQuiDoitJouer))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(4);
  }

  /* DEROULEMENT DE LA  PARTIE */

  while(1)
  {
    TypCoupReq coup;
    int autreJoueur = sumSock - joueurQuiDoitJouer;
    
    if(transmissionCoup(joueurQuiDoitJouer, autreJoueur, &coup))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(5);
    }

    // TODO
    // TIMEOUT
    if(envoieReponseCoup(joueurQuiDoitJouer, autreJoueur, &coup))
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(6);
    }

    if(coup.validCoup != VALID)
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(0);
    }

    joueurQuiDoitJouer = autreJoueur;
  }
  
  return 0;
}
