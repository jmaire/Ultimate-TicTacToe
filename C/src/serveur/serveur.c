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
