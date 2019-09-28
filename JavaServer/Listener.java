import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class Listener implements Runnable {

	private volatile boolean listening 	= false;
	private ServerSocket serverSocket 	= null;

	public Listener(int port) throws IOException {

		serverSocket = new ServerSocket(port);
		listening 	 = true;
	}

	@Override 
	public void run(){

		System.out.println("listener started");

		while(listening){

			try {

				ClientHandler handler = 
					new ClientHandler(serverSocket.accept());

				new Thread(handler).start();

				Server.addClient(handler);

			} catch (IOException e){

				System.out.println("client connect failed");
			}
		}

		shutdown();
	}

	public void shutdown(){

		listening = false;

		try{

			serverSocket.close();

		} catch (IOException e){

			serverSocket = null;
		}
	}
}