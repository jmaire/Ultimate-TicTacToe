// importation des classes utiles à Jasper
import se.sics.jasper.*;
// pour les lectures au clavier
import java.io.*;
// pour utiliser les HashMap 
import java.util.*;

public class JulIA {
  public static final String PROLOG_FILE_PATH = "../Prolog/ai.pl";
  public static final String joueur = "1";
  public static final String CLE_COUP = "Coup";

  public static int AB_PROFONDEUR = 4;

  public static void main(String[] args) {
    int[][] plateau = new int[][]{
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                   }
    recupererCoup(plateau,-1);
  }

  public static int[] recupererCoup(int[][] plateau, int imorpion) {
    try {
      // Creation d'un object SICStus
      SICStus sp = new SICStus();
      // Chargement d'un fichier prolog .pl
      sp.load(PROLOG_FILE_PATH);
    }
    // exception déclanchée par SICStus lors de la création de l'objet sp
    catch(SPException e) {
      System.err.println("Exception SICStus Prolog : " + e);
      e.printStackTrace();
      System.exit(-2);
    }

    // TODO Pm
    String saisie = "prochainCoup("+AB_PROFONDEUR+","+plateauToString(plateau)+","+imorpion+","+joueur+","+CLE_COUP+").";
    HashMap results = new HashMap();
    try {
      Query qu = sp.openQuery(saisie,results);
      boolean moreSols = qu.nextSolution();
      int[] res = parsingResultat(results);
      qu.close();
      return res;
    }
    catch(Exception e) {
      return null;
    }
  }

  public static int[] parsingResultat(HashMap result) {
    SPTerm sp = (SPTerm) result.get(CLE_COUP);
    try {
      SPTerm[] spterms = sp.toTermArray();
      int[] res = new int[2];
      res[0] = (int)spterms[0].getInteger();
      res[1] = (int)spterms[1].getInteger();
      return res;
    }
    catch(Exception e) {
      return null;
    }
  }

  public static String plateauToString(int[][] plateau) {
    // TODO Inverser le tableau
    String str = "[";
    int size = plateau.length;    
    for(int i=0; i<size; i++) {
      str += "[";
      int size2 = plateau[i].length;
      for(int j=0; j<size2; j++) {
        if(plateau[i][j]==0) {
          str += "'_'";
        } else {
          str += plateau[i][j];
        }
        if(j<size2-1)
          str += ",";
      }
      str += "]";
      if(i<size-1)
        str += ",";
    }
    return str+"]";
  }
}
