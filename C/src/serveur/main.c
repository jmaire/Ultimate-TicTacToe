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
  
  sock = socketServeur(atoi(argv[2]));
  if (sock < 0)
  { 
    printf("serveur : erreur socketServeur\n");
    exit(2);
  }
  
  /* CONNEXION DES DEUX JOUEURS */
  
  if(connexionJoueur(sock, &sockJoueur1) || connexionJoueur(sock, &sockJoueur2))
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(3);
  }
  
  /* RECEPTION DES REQUETES PARTIE */
  
  fd_set joueurSet;
  
  FD_ZERO(&joueurSet);
  FD_SET(sockJoueur1,&joueurSet);
  FD_SET(sockJoueur2,&joueurSet);
  
  int nfsd = sockJoueur1 > sockJoueur2 ? sockJoueur1 : sockJoueur2;
  int enAttente;
  TypPartieReq demande;
  
  err = select(nfsd,&joueurSet,NULL,NULL,NULL);
  if(err<0)
  {
    shutdown(sock, SHUT_RDWR);
    close(sock);
    exit(4);
  }
  if(FD_ISSET(sockJoueur1,&joueurSet))
  {
    err = recv(sockJoueur1,&demande,sizeof(TypPartieReq),0);
    //TODO envoyer les croix à Joueur 1
    if(err < 0)
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(5);
    }
    enAttente = sockJoueur2;
  }
  if(FD_ISSET(sockJoueur2,&joueurSet))
  {
    err = recv(sockJoueur2,&demande,sizeof(TypPartieReq),0);
    //TODO envoyer les croix à Joueur 2
    if(err < 0)
    {
      shutdown(sock, SHUT_RDWR);
      close(sock);
      exit(6);
    }
    enAttente = sockJoueur1;
  }
  err = recv(enAttente,&demande,sizeof(TypPartieReq),0);
  //TODO envoyer les ronds à l'autre joueur
  
  return 0;
}
