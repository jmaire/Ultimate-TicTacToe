// importation des classes utiles à Jasper
import se.sics.jasper.*;
// pour les lectures au clavier
import java.io.*;
// pour utiliser les HashMap 
import java.util.*;

public class JulIA {
  public static final String PROLOG_FILE_PATH = "../Prolog/ai.pl";
  public static int AB_PROFONDEUR = 4;
  public static final String joueur = "1";

  public static void main(String[] args) {
    /*System.out.println(":::::::::"+plateauToString(new int[][]{
                                                    new int[]{1,1,1,1,1,1,1,0,1,1},
                                                    new int[]{0,1,1,1,1,1,1,0,1,1},
                                                    new int[]{1,0,1,1,1,1,0,1,1,1},
                                                    new int[]{1,1,0,1,1,1,1,1,1,1},
                                                    new int[]{1,1,1,0,1,1,1,1,1,1},
                                                    new int[]{1,1,1,1,0,1,0,1,1,1},
                                                    new int[]{1,1,1,1,1,1,1,0,1,1},
                                                    new int[]{1,1,1,1,1,1,0,1,1,1},
                                                    new int[]{1,1,0,0,1,1,1,1,1,1},
                                                   }));*/
    recupererCoup(new int[][]{
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                    new int[]{0,0,0,0,0,0,0,0,0},
                                                   },-1);

/*
    String saisie = new String("");
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

    // lecture au clavier d'une requète Prolog
    System.out.print("| ?- ");
    saisie = saisieClavier();

    // boucle pour saisir les informations 
    while(! saisie.equals("halt.")) {
      // HashMap utilisé pour stocker les solutions
      HashMap results = new HashMap();
      
      try {
        // Creation d'une requete (Query) Sicstus
        //  - en fonction de la saisie de l'utilisateur 
        //  - instanciera results avec les résultats de la requète
        Query qu = sp.openQuery(saisie,results);

        // parcours des solutions
        boolean moreSols = qu.nextSolution();

        // on ne boucle que si la liste des instanciations de variables est non vide 
        boolean continuer = !(results.isEmpty());

        while(moreSols && continuer) {
          // chaque solution est sockée dans un HashMap 
          // sous la forme : VariableProlog -> Valeur
          System.out.print(results + " ? ");
            
          // demande à l'utilisateur de continuer ...
          saisie = saisieClavier();
          if(saisie.equals(";")) {
            // solution suivante --> results contient la nouvelle solution
            moreSols = qu.nextSolution();
          } 
          else {
            continuer = false;
          }
        }
        if(moreSols) {
          // soit :
          //  - il y a encore des solutions et (continuer == false)
          //  - le prédicat a réussi mais (results.isEmpty() == true)
          System.out.println("yes");
        }
        else {
          // soit :
          //    - on est à la fin des solutions
          //    - il n'y a pas de solutions (le while n'a pas été exécuté)
          System.out.println("no");
        }

        // fermeture de la requète
        System.err.println("Fermeture requete");
        qu.close();
      }
      catch(SPException e) {
        System.err.println("Exception prolog\n" + e);
      }
      // autres exceptions levées par l'utilisation du Query.nextSolution()
      catch(Exception e) {
        System.err.println("Other exception : " + e);
      }
      System.out.print("| ?- ");
      // lecture au clavier
      saisie = saisieClavier();	
    }
    System.out.println("End of jSicstus");
    System.out.println("Bye bye");*/
  }


  public static String saisieClavier() {
    // declaration du buffer clavier
    BufferedReader buff = new BufferedReader(new InputStreamReader(System.in));

    try {
      return buff.readLine();
    }
    catch(IOException e) {
      System.err.println("IOException " + e);
      e.printStackTrace();
      System.exit(-1);
    }
    return "halt.";
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
    String saisie = "prochainCoup("+AB_PROFONDEUR+","+plateauToString(plateau)+","+imorpion+","+joueur+",Coup).";
    System.out.println("--"+saisie);
    HashMap results = new HashMap();
    try {
      Query qu = sp.openQuery(saisie,results);
      //boolean moreSols = qu.nextSolution();

      System.out.println(":"+results);


      qu.close();
    }
    catch(Exception e){}
    return null;
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
/*
    str += "[";
    int size2 = plateau[size].length-1;
    for(int j=0; j<size2; j++) {
      if(plateau[size][j]==0) {
          str += "'_'";
        } else {
          str += plateau[size][j];
        }
        str += ",";
    }
    str += plateau[size][size2]+"]]";
*/
    return str+"]";
  }
}
