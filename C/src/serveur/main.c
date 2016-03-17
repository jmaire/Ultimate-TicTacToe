#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../../include/serveur/serveur.h"
#include "../../include/fonctionsTCP.h"
#include "../../include/constants.h"

int main(int argc, char **argv)
{
  int sock,               /* descripteur de la socket locale */
      err,                /* code d'erreur */
      sockJoueur1,        /* descripteur de la socket client J1 */
      sockJoueur2;        /* descripteur de la socket client J2 */
      
  struct sockaddr_in nom_transmis;
  socklen_t size_addr_trans = sizeof(struct sockaddr_in);

  /* CREATION DE SOCKET SERVEUR */

  // check argv[2]
  
  sock = socketServeur(atoi(argv[2]));
  if (sock < 0)
  { 
    printf("serveur : erreur socketServeur\n");
    exit(2);
  }
  
  /* CONNEXION DES DEUX JOUEURS */
  
  sockJoueur1 = accept(sock, (struct sockaddr *)&nom_transmis, &size_addr_trans);
  if (sockJoueur1 < 0)
  {
    perror("serveur :  erreur sur accept");
    close(sock);
    exit(3);
  }
  
  sockJoueur2 = accept(sock, (struct sockaddr *)&nom_transmis, &size_addr_trans);
  if (sockJoueur2 < 0)
  {
    perror("serveur :  erreur sur accept");
    close(sock);
    exit(3);
  }
  
  /* RECEPTION DES REQUETES PARTIE */
  
  
  return 0;
}
