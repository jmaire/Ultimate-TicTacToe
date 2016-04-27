#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#include "../../include/serveur/serveur.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"
#include "../../include/validation.h"

int connexionJoueur(int sock, int* sockJoueur)
{
  struct sockaddr_in nom_transmis;
  socklen_t size_addr_trans = sizeof(struct sockaddr_in);
  
  *sockJoueur = accept(sock, (struct sockaddr *)&nom_transmis, &size_addr_trans);
  if (*sockJoueur < 0)
    return 1;
  return 0;
}

int receptionDemandesPartie(int sock, int sockJoueur1, int sockJoueur2, int* joueurCroix)
{
  fd_set joueurSet;
  
  FD_ZERO(&joueurSet);
  FD_SET(sockJoueur1,&joueurSet);
  FD_SET(sockJoueur2,&joueurSet);
  
  int nfsd = sockJoueur1 > sockJoueur2 ? sockJoueur1 : sockJoueur2;
  int joueurEnAttente;
  char nomJ1[MAX_CH], nomJ2[MAX_CH];
  TypPartieReq demandeJ1, demandeJ2;
  TypPartieRep repJoueurJ1, repJoueurJ2, repEnAttente;

  int err = select(nfsd,&joueurSet,NULL,NULL,NULL);
  if(err<0)
    return 1;
  if(FD_ISSET(sockJoueur1,&joueurSet))
  {
    repJoueurJ1.symb = CROIX;
    repJoueurJ2.symb = ROND;
    *joueurCroix = sockJoueur1;
    if(traitementDemandePartie(sockJoueur1,&repJoueurJ1,nomJ1))
      return 1;
    joueurEnAttente = 2;
  }
  if(FD_ISSET(sockJoueur2,&joueurSet))
  {
    repJoueurJ2.symb = CROIX;
    repJoueurJ1.symb = ROND;
    *joueurCroix = sockJoueur2;
    if(traitementDemandePartie(sockJoueur2,&repJoueurJ2,nomJ2))
      return 1;
    joueurEnAttente = 1;
  }

  if(joueurEnAttente==1)
    err = traitementDemandePartie(sockJoueur1,&repJoueurJ1,nomJ1);
  else
    err = traitementDemandePartie(sockJoueur2,&repJoueurJ2,nomJ2);

  if(err)
    return 1;
  
  strcpy(repJoueurJ1.nomAdvers,nomJ2);
  strcpy(repJoueurJ2.nomAdvers,nomJ1);

  err = send(sockJoueur1, &repJoueurJ1, sizeof(TypPartieRep), 0);
  if(err != sizeof(TypPartieRep))
    return 1;

  err = send(sockJoueur2, &repJoueurJ2, sizeof(TypPartieRep), 0);
  if(err != sizeof(TypPartieRep))
    return 1;

  return 0;
}

int traitementDemandePartie(int sock, TypPartieRep* repJoueur, char* nomJoueur)
{
  TypPartieReq demandeJoueur;
  int err = recv(sock,&demandeJoueur,sizeof(TypPartieReq),0);
  if(err < 0)
    return 1;
  if(demandeJoueur.idRequest == PARTIE)
    (*repJoueur).err = ERR_OK;
  else
    (*repJoueur).err = ERR_PARTIE;

  strcpy(nomJoueur,demandeJoueur.nomJoueur);
  return 0;
}

int transmissionCoup(int joueurQuiDoitJouer, int autreJoueur, TypCoupReq* coupJoueur)
{
  struct timeval debut, fin, delay;
  
  gettimeofday(&debut, NULL);
  int err = recv(joueurQuiDoitJouer, coupJoueur, sizeof(TypCoupReq),0);
  gettimeofday(&fin, NULL);
  if(err < 0)
    return 1;
  
  timersub(&fin, &debut, &delay);
  // TODO vérifier le delay et renvoyer timeout ou pas

  err = send(autreJoueur, coupJoueur, sizeof(TypCoupReq), 0);
  if(err != sizeof(TypCoupReq))
    return 1;

  return 0; 
}

int envoieReponseCoup(int numJoueurQuiDoitJouer, int joueurQuiDoitJouer, int autreJoueur, TypCoupReq coupReq, TypCoupRep* coupTeste)
{
  int repValid = validationCoup(joueurQuiDoitJouer, coupReq, &(*coupTeste).propCoup);

  (*coupTeste).err = repValid ? ERR_OK : ERR_COUP;
  (*coupTeste).validCoup = repValid ? VALID : TRICHE;

  int err = send(joueurQuiDoitJouer, coupTeste, sizeof(TypCoupRep), 0);
  if(err != sizeof(TypCoupRep))
    return 1;

  err = send(autreJoueur, coupTeste, sizeof(TypCoupRep), 0);
  if(err != sizeof(TypCoupRep))
    return 1;

  return 0;
}
