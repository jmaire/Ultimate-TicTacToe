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
import java.io.DataInputStream;
import java.io.DataOutputStream;

public class JulIA {
  public static final String PROLOG_FILE_PATH = "../Prolog/ai.pl";
  public static final String joueur = "1";
  public static final String KEY_COUP = "Coup";
  public static final String KEY_SPLAT = "SPlat";

  private static final int PORT_SOCKET = 5555;
  private static final int BYTE_TO_RECV = 2;
  private static final int BYTE_TO_SEND = 3;

  private static final int SAFE_AB_PROFONDEUR = 1;

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
      System.out.println("ENTREE COMMENCE TON");
      commenceTOn();

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
    int imorpion = recevoirCoupAdverse();
    TimeoutThread toThread = new TimeoutThread(sockComm);
    toThread.start();

    String stPlateau = plateauToString(plateau);
    int[] coupSafe = recupererCoupSafe(stPlateau, imorpion);

    CoupThread coupThread = new CoupThread(sp,stPlateau,imorpion, coupSafe);
    coupThread.start();
    
    DataOutputStream dos = new DataOutputStream(sockComm.getOutputStream());
    plateau[coupSafe[0]][coupSafe[1]] = 1;
    dos.writeInt(coupSafe[0]*100+coupSafe[1]*10+tictactoeWon());
    dos.flush();
  }

  public static int recevoirCoupAdverse() throws IOException {
    DataInputStream dis = new DataInputStream(sockComm.getInputStream());
    
    int coup = dis.readInt();

    int imorp = (int)(coup/10);
    int icase = coup%10;
    plateau[imorp][icase] = 2;

    System.out.println("");
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
  
  public static int parsingSPlat(HashMap result) {
    SPTerm sp = (SPTerm) result.get(KEY_SPLAT);
    try {
      return (int)sp.getInteger();
    }
    catch(Exception e) {
      return -1;
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

  public static void commenceTOn() throws IOException {
    DataInputStream dis = new DataInputStream(sockComm.getInputStream());
    System.out.println("ON ATTEND");
    if(dis.readByte() != 0)
    {
      System.out.println("RECU");
      int[] coupSafe = null;
      String stPlateau = plateauToString(plateau);
      String saisie = "prochainCoup(1,"+stPlateau+",-1,"+KEY_COUP+").";
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
      
      DataOutputStream dos = new DataOutputStream(sockComm.getOutputStream());
      plateau[coupSafe[0]][coupSafe[1]] = 1;
      int formatcoup = coupSafe[0]*100+coupSafe[1]*10;
      System.out.println("COUP: "+coupSafe[0]+" "+coupSafe[1]+" "+formatcoup);
      dos.writeInt(formatcoup);
      dos.flush();
    }
  }
  
  public static int tictactoeWon() throws IOException {
    String stPlateau = plateauToString(plateau);
    String saisie = "sousplateauGagne("+stPlateau+","+KEY_SPLAT+").";
    int res = -1;
    HashMap results = new HashMap();
    try {
      Query qu = sp.openQuery(saisie,results);
      boolean moreSols = qu.nextSolution();
      res = parsingSPlat(results);
      System.out.println("tictactoe "+res);
      qu.close();
    }
    catch(Exception e) {
      //TODO
      System.err.println("Exception query : " + e);
    }
    return res;
  }
}
