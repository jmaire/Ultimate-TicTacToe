/*
 **********************************************************
 *
 *  Programme : fonctionsSocket.c
 *
 *  ecrit par : LP.
 *
 *  resume :    fonction d'initialisation des sockets en mode 
 *              connecte
 *
 *  date :      25 / 01 / 06
 *
 ***********************************************************
 */

/* include generaux */
#include <sys/types.h>
#include <string.h>
#include <stdio.h>

/* include socket */
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>


/*
 **********************************************************
 *
 *  fonction  : fonctionsSocket.c
 *
 *  resume :    creer la socket du serveur et la retourne
 *              socketServeur(numero de port)
 *
 ***********************************************************
 */
int socketServeur(ushort port) {          
  int sock,      /* descripteur de la socket */
      err;	     /* code d'erreur */

  struct sockaddr_in nom;	   /* adresse de la socket */
  
  socklen_t      size_addr;  	/* taille de l'adresse d'une socket */
  
  
  size_addr = sizeof(struct sockaddr_in);
  
  /* creation de la socket, protocole TCP */
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    perror("socketServeur : erreur de socket\n");
    return -1;
  }
  
  /* 
   * initialisation de l'adresse de la socket 
   */
  nom.sin_family = AF_INET;
  nom.sin_port = htons(port);
  nom.sin_addr.s_addr = INADDR_ANY;
  bzero(nom.sin_zero, 8);
  
  /*
   * mode SO_REUSEADDR pour eviter les: "address already in use"
   */
  int on = 1;
  err = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
  if (err < 0) 
    perror("socketServeur : erreur setsockopt");   
  
  /* 
   * attribution de l'adresse a la socket
   */
  err = bind(sock, (struct sockaddr *)&nom, size_addr);
  if (err < 0) {
    perror("socketServeur : erreur sur le bind");
    return -2;
  }
  
  /* 
   * utilisation en socket de controle, puis attente de demandes de 
   * connexion.
   */
  err = listen(sock, 1);
  if (err < 0) {
    perror("socketServeur : erreur dans listen");
    return -3;
  }
  
  /*
   * retourne le descripteur de socket
   */
  return sock;
}

/*
 **********************************************************
 *
 *  fonction : socketClient
 *
 *  resume :    fonction de connexion d'une socket au serveur
 *              socketClient(nom de machine serveur, numero de port)
 *
 ***********************************************************
 */

int socketClient(char *nomMachine, ushort port) {
  int sock,               /* descripteur de la socket */
      err;                /* code d'erreur */

  struct hostent*    host; /* description de la machine serveur */
  struct sockaddr_in nom;  /* adresse de la socket du serveur */

  socklen_t size_addr_in = sizeof(struct sockaddr_in);


  /* 
   * creation d'une socket, domaine AF_INET, protocole TCP 
   */
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock<0) {
      perror("socketClient : erreur sur la creation de socket");
      return -1;
  }

  /* initialisation de l'adresse de la socket */
  nom.sin_family = AF_INET;
  bzero(nom.sin_zero, 8);
  nom.sin_port = htons(port);

  /* 
   * recherche de l'adresse de la machine
   */
  host = gethostbyname (nomMachine);
  if (host == NULL) {
    perror("socketClient :  erreur gethostbyname");
    return -2;
  }

  /*
   * recopie de l'adresse IP
   */
  nom.sin_addr.s_addr = ((struct in_addr *) (host->h_addr_list[0]))->s_addr;
					     
  /* 
   * connection au serveur 
   */
  err = connect(sock, (struct sockaddr *)&nom, size_addr_in);
  if (err < 0) {
      perror("socketClient :  erreur a la connection de socket");
      return -3;
  }
 
  /*
   * on retourne le descripteur de socket
   */
  return sock;

}
 

