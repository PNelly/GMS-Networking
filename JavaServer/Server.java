import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

import java.util.concurrent.ConcurrentHashMap;

public class Server {

	public static final int PORT_TCP 				= 4643;
	public static final int PORT_UDP 				= 4644;
	public static final int DATAGRAM_LENGTH = 256;
	public static final int HEADER_LENGTH 	= 5;
	public static final int SOCKET_TIMEOUT 	= 30000;
	public static final int U16_MAX 				= 65535;

	private static Listener listener 						= null;
	private static DatagramListener udpListener = null;

	private static ConcurrentHashMap<Integer,Client> clients = null;

	public static void main(String[] args){

		Server.start();
	}

	public static void start(){

		clients = new ConcurrentHashMap<Integer,Client>();

		try {

			listener 		= new Listener(PORT_TCP);
			udpListener = new DatagramListener(PORT_UDP);

			new Thread(listener).start();
			new Thread(udpListener).start();

		} catch (IOException e){

			System.out.println("startup failed");

			return;
		}		
	}

	private static int nextClientId(){

		int id = 0;

		for(;clients.containsKey(id);++id);

		return id;
	}

	public static int addClient(ClientHandler handler){

		int id = nextClientId();

		Client client = new Client(id, handler);

		handler.setClientId(id);

		clients.put(id, client);

		System.out.println("added new client " + id);

		return id;
	}

	public static void removeClient(int clientId){

		clients.remove(clientId);

		System.out.println("removed client " + clientId);
	}
}