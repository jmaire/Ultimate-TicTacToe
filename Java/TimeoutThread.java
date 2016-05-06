import java.io.IOException;
import java.io.InputStream;
import java.net.Socket;
import java.io.DataInputStream;

public class TimeoutThread extends Thread {
	private static final long TIME_MAX = 5000;
	
	private Socket sockComm;
	
	private CoupThread otherThread = null;

	public TimeoutThread(Socket sC) {
		this.sockComm = sC;
	}
	
	public void recevoirDebutTour() throws IOException {
		DataInputStream dis = new DataInputStream(sockComm.getInputStream());
		dis.readByte();
	}
	
	public void setOtherThread(CoupThread thread) {
		this.otherThread = thread;
	}
	
	public void run() {
	
		try {
			recevoirDebutTour();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		try {
			sleep(TIME_MAX);
		  System.out.println("Delai dépassé.");
		} catch (InterruptedException e) {
			this.currentThread().interrupt();
		}
	  this.otherThread.interrupt();
	}
}
