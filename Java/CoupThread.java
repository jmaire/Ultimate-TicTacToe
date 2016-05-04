import se.sics.jasper.*;
import java.util.HashMap;

public class CoupThread extends Thread {
	private static int AB_PROFONDEUR = 1;
	
	private SICStus sp;
	private String plateau;
	private int iMorpion;
	private int[] coup = null;
	
	private TimeoutThread otherThread = null;
	
	public CoupThread(SICStus sp, String pl, int morp, int[] c) {
		this.sp = sp;
		this.plateau = pl;
		this.iMorpion = morp;
		this.coup = c;
	}
	
	public int[] recupererCoup() {
		int[] coup = null;
		String saisie = "prochainCoup("+AB_PROFONDEUR+","+this.plateau+","+this.iMorpion+","+JulIA.KEY_COUP+").";
		HashMap results = new HashMap();
		try {
			//TODO threadé timeout
			Query qu = this.sp.openQuery(saisie,results);
			boolean moreSols = qu.nextSolution();
			coup = JulIA.parsingResultat(results);
			qu.close();
		}
		catch(Exception e) {
			//TODO
			System.err.println("Exception query : " + e);
		}
		return coup;
	}

	public int[] getCoup() {
		return this.coup;
	}
	
	public void setOtherThread(TimeoutThread thread) {
		this.otherThread = thread;
	}
	
	public void run() {
		this.coup = recupererCoup();
	    this.otherThread.interrupt();
	}
}
