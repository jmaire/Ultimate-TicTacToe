/*
 **********************************************************
 *
 *  Programme : fonctionsSocket.h
 *
 *  ecrit par : LP.
 *
 *  resume :    entete des fonctions d'initialisation des sockets en mode 
 *              connecte
 *
 *  date :      25 / 01 / 06
 *
 ***********************************************************
 */

/* include generaux */
#include <sys/types.h>

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
 *              socketServeur ( numero de port )
 *
 ***********************************************************
 */
int socketServeur(ushort port);

/*
 **********************************************************
 *
 *  fonction : socketClient
 *
 *  resume :    fonction de connexion d'une socket au serveur
 *              socketClient( nom de machine serveur, numero de port )
 *
 ***********************************************************
 */

int socketClient(char *nomMachine, ushort port);

