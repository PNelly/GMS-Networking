import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;	

public class ClientHandler implements Runnable {

	private int clientId 							= -1;
	private Socket socket 						= null;
	private GMSPacketSplicer splicer 	= null;

	public ClientHandler(Socket socket) throws IOException {

		this.socket  = socket;
		this.splicer = new GMSPacketSplicer(
			this.socket.getInputStream()
		);
	}

	@Override
	public void run(){

		System.out.println("new client connected - starting handler");

		while(true){

			try {

				GMSPacket packet = splicer.splice();

			} catch (IOException e){

				System.out.println("splicer ioexception: "+e.getMessage());

				close();

				Server.removeClient(clientId);

				break;
			}
		}

		System.out.println("end client handler");
	}

	public void close(){

		try {

			this.socket.close();

		} catch (IOException e){

			// nothing to be done
		}
	}

	public void setClientId(int id){

		this.clientId = id;
	}
}