// importation des classes utiles à Jasper
import se.sics.jasper.*;
// pour les lectures au clavier
import java.io.*;
// pour utiliser les HashMap 
import java.util.*;

import java.net.Socket;
import java.net.ServerSocket;
import java.io.InputStream;
import java.io.IOException;

public class JulIA {
  private static final String PROLOG_FILE_PATH = "../Prolog/ai.pl";
  private static final String joueur = "1";
  private static final String CLE_COUP = "Coup";
  private static final int PORT_SOCKET = 5555;
  private static final int BYTE_TO_READ = 3*4;

  private static final int SAFE_AB_PROFONDEUR = 1;
  private static int AB_PROFONDEUR = 1;

  private static int[][] plateau;
  private static Socket sockComm = null;

  public static void main(String[] args) {
    plateau = new int[][] {
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                  new int[]{0,0,0,0,0,0,0,0,0},
                };

    ServerSocket srv = null;

    try {
      srv = new ServerSocket(PORT_SOCKET);
      sockComm = srv.accept();
    
      recevoirDeC();

      sockComm.close();
      srv.close(); // ferme la socket de comm et de connex
    } catch(IOException e) {
      //TODO
      System.err.println("Exception io : " + e);
    }
    /*int[] coup = recupererCoup(plateau,-1);
    System.out.println(":="+coup[0]+","+coup[1]);*/
  }

  public static void recevoirDeC() throws IOException {
    InputStream is = sockComm.getInputStream();
    byte[] tabloServ = new byte[BYTE_TO_READ];
    if(BYTE_TO_READ!=is.read(tabloServ))
        {}//TODO
      for(int i=0;i<BYTE_TO_READ;i++){
        System.out.print(tabloServ[i]);
      }
      System.out.println("");
    is.close();
  }

  public static int[] recupererCoup(int[][] plateau, int imorpion) {
    SICStus sp = null;
    try {
      // Creation d'un object SICStus
      sp = new SICStus();
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
    //Coup secure
    String stPlateau = plateauToString(plateau);
    String saisie = "prochainCoup("+SAFE_AB_PROFONDEUR+","+stPlateau+","+imorpion+","+joueur+","+CLE_COUP+").";
    HashMap results = new HashMap();
    try {
      Query qu = sp.openQuery(saisie,results);
      boolean moreSols = qu.nextSolution();
      int[] safe_res = parsingResultat(results);
      qu.close();
    }
    catch(Exception e) {
      //TODO
      System.err.println("Exception query : " + e);
      return null;
    }

    //Coup normal
    saisie = "prochainCoup("+AB_PROFONDEUR+","+stPlateau+","+imorpion+","+CLE_COUP+").";
    results = new HashMap();
    try {
      //TODO threadé timeout
      Query qu = sp.openQuery(saisie,results);
      boolean moreSols = qu.nextSolution();
      int[] res = parsingResultat(results);
      qu.close();
      return res;
    }
    catch(Exception e) {
      //TODO
      System.err.println("Exception query : " + e);
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
