/*******************************************************/
/*
 * Fichier : protocoleTicTacToe.h
 *
 * Synopsis : entete du protocole d'acces au serveur
 *            pour le jeur Tic-Tac-Toe
 *
 * Ecrit par : VF/AR
 * Date :  24 / 02 / 16
 */ 
/*******************************************************/

#ifndef _protocoleTTT_h
#define _protocoleTTT_h

/* Taille des chaines */
#define MAX_CH 30

/* Identificateurs des requetes */
typedef enum { PARTIE, COUP } TypIdRequest;

/* Types d'erreur */
typedef enum { ERR_OK,      /* Validation de la requete */
	       ERR_PARTIE,  /* Erreur sur la demande de partie */
	       ERR_COUP,    /* Erreur sur le coup joue */
	       ERR_TYP      /* Erreur sur le type de requete */
} TypErreur;

/* 
 * Structures demande de partie
 */
typedef struct{

  TypIdRequest idRequest;     /* Identificateur de la requete */
  char nomJoueur[MAX_CH];     /* Nom du joueur */

} TypPartieReq;

typedef enum { ROND, CROIX } TypSymbol;

typedef struct {

  TypErreur  err;           /* Code d'erreur */
  TypSymbol  symb;          /* Symbol du joueur */
  char nomAdvers[MAX_CH];   /* Nom du joueur adversaire */

} TypPartieRep;


/* 
 * Definition d'une position de case
 */
typedef enum { UN, DEUX, TROIS, QUATRE, CINQ, SIX, SEPT, HUIT, NEUF } TypSousPlat;
typedef enum { A, B, C, D, E, F, G, H, I } TypPlat;

typedef struct {

  TypPlat numPlat;
  TypSousPlat numSousPlat;

} TypCase;

/* Structures coup du joueur 
 */

typedef struct {

  TypIdRequest idRequest;     /* Identificateur de la requete */
  TypSymbol    symbolJ;       /* Symbol du joueur */
  TypCase      pos;           /* Position du symbol */
  int          nbSousPlatG;   /* Nombre de sous-plateaux gagnes */ 

} TypCoupReq;


/* Validite du coup */
typedef enum { VALID, TIMEOUT, TRICHE } TypValCoup;

/* Propriete du coup */
typedef enum { CONT, GAGNANT, NULLE, PERDU } TypCoup;

/* Reponse a un coup */
typedef struct {

  TypErreur err;                  /* Code d'erreur */
  TypValCoup validCoup;           /* Validite du coup */
  TypCoup propCoup;               /* Propriete du coup : rend le joueur gagnant, perdant ou partie nulle; ou autre   */

} TypCoupRep;

#endif

