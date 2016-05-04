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
  public static final String PROLOG_FILE_PATH = "../Prolog/ai.pl";
  public static final String joueur = "1";
  public static final String KEY_COUP = "Coup";

  private static final int PORT_SOCKET = 5555;
  private static final int BYTE_TO_RECV = 2;
  private static final int BYTE_TO_SEND = 3;

  private static final int SAFE_AB_PROFONDEUR = 1;

  private static boolean onCommence = true;

  private static int[][] plateau;
  private static SICStus sp = null;
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

    try {
      ServerSocket srv = new ServerSocket(PORT_SOCKET);
      sockComm = srv.accept();

      sp = new SICStus();
      sp.load(PROLOG_FILE_PATH);
      
      onCommence = commenceTOn();

      boolean v = true;
      while(v)
        truc();

      sockComm.close();
      srv.close();
    } catch(IOException e) {
      //TODO
      System.err.println("Exception io : " + e);
    }
    catch(SPException e) {
      System.err.println("Exception SICStus Prolog : " + e);
      e.printStackTrace();
      System.exit(-2);
    }
  }

  public static void truc() throws IOException {
    int imorpion = -1;
    if(!onCommence)
      imorpion = recevoirCoupAdverse();
    onCommence = false;
    TimeoutThread toThread = new TimeoutThread(sockComm);
    toThread.start();

    String stPlateau = plateauToString(plateau);
    int[] coupSafe = recupererCoupSafe(stPlateau, imorpion);

    CoupThread coupThread = new CoupThread(sp,stPlateau,imorpion, coupSafe);
    coupThread.start();
    
    OutputStream os = sockComm.getOutputStream();
    byte[] tab = new byte[BYTE_TO_SEND];
    tab[0] = (byte)coupSafe[0];
    tab[1] = (byte)coupSafe[1];
    //TODO tab[2]
    plateau[tab[0]][tab[1]] = 1;

    os.write(tab);
    os.close(); // A TESTER
  }

  public static int recevoirCoupAdverse() throws IOException {
    InputStream is = sockComm.getInputStream();
    byte[] tab = new byte[BYTE_TO_RECV];

    if(BYTE_TO_RECV!=is.read(tab)) {
      return -1;
    }

    int imorp = (int)tab[0];
    int icase = (int)tab[1];
    plateau[imorp][icase] = 2;

    System.out.println("");
    is.close(); // A TESTER
    return imorp;
  }

  public static int[] recupererCoupSafe(String stPlateau, int imorpion) {
    int[] coupSafe = null;
    String saisie = "prochainCoup("+SAFE_AB_PROFONDEUR+","+stPlateau+","+imorpion+","+KEY_COUP+").";
    HashMap results = new HashMap();
    try {
      Query qu = sp.openQuery(saisie,results);
      boolean moreSols = qu.nextSolution();
      coupSafe = parsingResultat(results);
      qu.close();
    }
    catch(Exception e) {
      //TODO
      System.err.println("Exception query : " + e);
    }
    return coupSafe;
  }

  public static int[] parsingResultat(HashMap result) {
    SPTerm sp = (SPTerm) result.get(KEY_COUP);
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

  public static boolean commenceTOn() throws IOException {
    InputStream is = sockComm.getInputStream();
    byte[] tab = new byte[1];
    if(is.read(tab)!=1) {
      return false; //TODO !
    }

    return tab[0]!=0;
  }
}
