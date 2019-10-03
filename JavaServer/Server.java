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
	public static final int UDP_MAX_CLIENTS = 7;
	public static final int IDLE_DISC_TIME 	= 1000 * 60 * 5; // five minutes

	private static Listener listener 						= null;
	private static DatagramListener udpListener = null;

	private static ConcurrentHashMap<Integer,Client> clients = null;

	public static void main(String[] args){

		Server.start();
		Server.manage();
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

	private static void manage(){

		while(true){

			Set<Map.Entry<Integer, Client>> entries = clients.entrySet();

			Iterator<Map.Entry<Integer, Client>> iterator = entries.iterator();

			while(iterator.hasNext()){

				Map.Entry<Integer, Client> entry = iterator.next();

				Client client = entry.getValue();

				// manage idle timers //

				if(System.currentTimeMillis() -client.getTimeCreated() > IDLE_DISC_TIME){

					System.out.println("idle disconnect for client " + client.getClientId());

					disconnectClient(client.getClientId());
				}
			}
		}
	}

	public static Client getClient(int clientId){

		return clients.get(clientId);
	}

	public static  void sendToAllClients(GMSPacket packet, int excludeId){

		Set<Map.Entry<Integer, Client>> entries = clients.entrySet();

		Iterator<Map.Entry<Integer, Client>> iterator = entries.iterator();

		while(iterator.hasNext()){

			Map.Entry<Integer, Client> entry = iterator.next();

			Client client = entry.getValue();

			if(client.getClientId() != excludeId)
				client.send(packet);
		}		
	}

	private static int nextClientId(){

		int id = 0;

		for(;clients.containsKey(id);++id);

		return id;
	}

	public static void addClient(Socket socket){

		int id = nextClientId();

		try {

			Client client = new Client(socket, id);

			new Thread(client).start();

			clients.put(id, client);

			System.out.println("added new client " + id);

			bringClientUpToSpeed(client);
			shareNewClientDetails(client);

		} catch (IOException e) {

			System.out.println("add client failed: "+e.getMessage());

			disconnectClient(id);
		}
	}

	public static void bringClientUpToSpeed(Client newClient){

		GMSPacket packet = new GMSPacket(Message.BRING_UP_TO_SPEED);

		// new client's id

		packet.writeU16(newClient.getClientId());
		
		Set<Map.Entry<Integer, Client>> entries = clients.entrySet();

		Iterator<Map.Entry<Integer, Client>> iterator = entries.iterator();

		// number of entries

		packet.writeU16(clients.size());

		while(iterator.hasNext()){

			Map.Entry<Integer, Client> entry = iterator.next();

			Client client = entry.getValue();

			// information on each client

			packet.writeU16(client.getClientId());
			packet.writeString(client.getClientIp());
			packet.writeBool(client.getIsUdpHost());
			packet.writeS32(client.getUdpHostPort());
			packet.writeU8(client.getUdpHostClients());
			packet.writeU8(client.getUdpHostMaxClients());
			packet.writeS32(client.getUdpClientPort());
			packet.writeBool(client.getUdpHostInProgress());
		}		

		newClient.send(packet);
	}

	public static void shareNewClientDetails(Client newClient){

		GMSPacket packet = new GMSPacket(Message.CLIENT_CONNECTED);

		packet.writeU16(newClient.getClientId());
		packet.writeString(newClient.getClientIp());

		sendToAllClients(packet, newClient.getClientId());
	}

	public static void updateClientInfo(int clientId){

		Client client = clients.get(clientId);

		GMSPacket packet = new GMSPacket(Message.CLIENT_UPDATE);
		packet.writeU16(clientId);
		packet.writeString(client.getClientIp());
		packet.writeBool(client.getIsUdpHost());
		packet.writeS32(client.getUdpHostPort());
		packet.writeU8(client.getUdpHostClients());
		packet.writeU8(client.getUdpHostMaxClients());
		packet.writeS32(client.getUdpClientPort());
		packet.writeBool(client.getUdpHostInProgress());

		sendToAllClients(packet, -1);
	}

	public static void disconnectClient(int clientId){

		Client client = clients.get(clientId);

		client.close();

		clients.remove(clientId);

		System.out.println("removed client " + clientId);
	}
}