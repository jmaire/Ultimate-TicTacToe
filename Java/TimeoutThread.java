import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;

public class TimeoutThread extends Thread {
	private static final long TIME_MAX = 5000;
	
	private Socket sockComm;
	
	private CoupThread otherThread = null;

	public TimeoutThread(Socket sC) {
		this.sockComm = sC;
	}
	
	public boolean recevoirDebutTour() throws IOException {
		InputStream is = this.sockComm.getInputStream();
		byte[] data = new byte[1];
		System.out.println("LECTURE");
		boolean estDebut = is.read(data)!=1;
		System.out.println(data[0]);
		
		is.close();
		return estDebut;
	}
	
	public void setOtherThread(CoupThread thread) {
		this.otherThread = thread;
	}
	
	public void run() {
	
		System.out.println("TENTATIVE DEBUT TOUR");
		try {
			while(recevoirDebutTour());
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		System.out.println("DEBUT TOUR");
		try {
			sleep(TIME_MAX);
		} catch (InterruptedException e) {
			e.printStackTrace();
			this.currentThread().interrupt();
		}
		System.out.println("Delai dépassé.");
	    this.otherThread.interrupt();
	}
}
