#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/serveur/serveur.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int connexionJoueur(int sock, int* sockJoueur)
{
  struct sockaddr_in nom_transmis;
  socklen_t size_addr_trans = sizeof(struct sockaddr_in);
  
  *sockJoueur = accept(sock, (struct sockaddr *)&nom_transmis, &size_addr_trans);
  if (*sockJoueur < 0)
    return 1;
  return 0;
}

int receptionDemandesPartie(int sock, int sockJoueur1, int sockJoueur2)
{
  fd_set joueurSet;
  
  FD_ZERO(&joueurSet);
  FD_SET(sockJoueur1,&joueurSet);
  FD_SET(sockJoueur2,&joueurSet);
  
  int nfsd = sockJoueur1 > sockJoueur2 ? sockJoueur1 : sockJoueur2;
  int enAttente;
  TypPartieReq demande;
  
  int err = select(nfsd,&joueurSet,NULL,NULL,NULL);
  if(err<0)
    return 1;
  if(FD_ISSET(sockJoueur1,&joueurSet))
  {
    err = recv(sockJoueur1,&demande,sizeof(TypPartieReq),0);
    //TODO envoyer les croix à Joueur 1
    if(err < 0)
      return 1;
    enAttente = sockJoueur2;
  }
  if(FD_ISSET(sockJoueur2,&joueurSet))
  {
    err = recv(sockJoueur2,&demande,sizeof(TypPartieReq),0);
    //TODO envoyer les croix à Joueur 2
    if(err < 0)
      return 1;
    enAttente = sockJoueur1;
  }
  err = recv(enAttente,&demande,sizeof(TypPartieReq),0);
  if(err < 0)
      return 1;
  //TODO envoyer les ronds à l'autre joueur
  return 0;
}
