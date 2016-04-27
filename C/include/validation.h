/*
 **********************************************************
 *
 *  Programme : validation.h
 *
 *  ecrit par : FB / VF
 *
 *  resume : entete pour la validation des coups
 *
 *  date :      24 / 02 / 16
 *  modifie : 
 ***********************************************************
 */

#ifndef _validation_h
#define _validation_h

#include <stdbool.h>

/* Validation d'un coup on doit passer :
 * le numero du joueur : 1(le premier avec les croix) ou 
 *                       2(le deuxième avec les ronds)
 * le coup (TypCoupReq)
 * resultat : type bool (coup valide ou non) 
 *            propCoup  (GAGNANT, PERDU, NULLE - le coup rend le joueur gagnant, perdant ou la partie est nulle, ou CONT si aucune des autres)
*/
bool validationCoup(int joueur, TypCoupReq coup, TypCoup* propCoup);

#endif 
