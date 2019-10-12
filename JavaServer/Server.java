import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

import java.util.concurrent.ConcurrentHashMap;

public class Server {

	public static final int EPHEMERAL_MIN 	= 49152;
	public static final int EPHEMERAL_MAX 	= 65535;
	public static final int PORT_TCP 				= 4643;
	public static final int PORT_UDP 				= 4644;
	public static final int IN_BUFFER_LEN 	= 256;
	public static final int DATAGRAM_LENGTH = 256;
	public static final int CLIENT_HDR_LEN 	= 3;
	public static final int GMS_HDR_LEN 		= 12;
	public static final int SOCKET_TIMEOUT 	= 1000 * 60;
	public static final int U16_MAX 				= 65535;
	public static final int UDP_MAX_CLIENTS = 7;
	public static final int IDLE_DISC_TIME 	= 1000 * 60 * 5; // five minutes

	private static Listener listener 						= null;
	private static DatagramListener udpListener = null;

	private static ConcurrentHashMap<Integer,Client> clients = null;

	private static Random random = null;

	public static void main(String[] args){

		boolean started = Server.start();

		if(started) 
			Server.manage();
	}

	public static boolean start(){

		clients = new ConcurrentHashMap<Integer,Client>();
		random  = new Random();

		try {

			listener 		= new Listener(PORT_TCP);
			udpListener = new DatagramListener(PORT_UDP);

			new Thread(listener).start();
			new Thread(udpListener).start();

			return true;

		} catch (IOException e){

			System.out.println("startup failed");

			return false;
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

				long elapsed = System.currentTimeMillis() -client.getIdleStamp();

				if(!client.getIsUdpHost() && elapsed > IDLE_DISC_TIME){

					System.out.println("idle disconnect for client " + client.getClientId());

					client.send(new GMSPacket(Message.IDLE_DISCONNECT));

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

		// bound exclusive so U16_MAX +1

		int id = random.nextInt(U16_MAX +1);

		while(clients.containsKey(id))
			id = random.nextInt(U16_MAX +1);

		return id;
	}

	public static void handShakeClient(Socket socket){

		try {

			Client client = new Client(socket);

			new Thread(client).start();

		} catch (IOException e){

			System.out.println("io execption on client handshake (server)");
		}
	}

	public static void integrateClient(Client client){

		int id = nextClientId();

		client.setClientId(id);
		client.setIdleStamp(System.currentTimeMillis());

		clients.put(id, client);

		bringClientUpToSpeed(client);
		shareNewClientDetails(client);
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

	public static void handleHostUpdate(Client client, GMSPacket packet){

		client.setUdpHostClients(packet.readU8());
		client.setUdpHostMaxClients(packet.readU8());
		client.setUdpHostInProgress(packet.readBool());

		updateClientInfo(client.getClientId());
	}

	public static void handleHostCancel(Client client){

		client.setIsUdpHost(false);

		updateClientInfo(client.getClientId());
	}

	public static void disconnectClient(int clientId){

		Client client = clients.get(clientId);

		if(client != null){

			client.close();
			clients.remove(clientId);
		}

		shareDisconnect(clientId);

		System.out.println("disconnected client " + clientId);
	}

	public static void shareDisconnect(int clientId){

		GMSPacket packet = new GMSPacket(Message.CLIENT_DISCONNECTED);

		packet.writeU16(clientId);

		sendToAllClients(packet, -1);
	}

	public static void handleHolePunchRequest(int clientIdFrom, int clientIdTo){

		Client clientFrom = getClient(clientIdFrom);
		Client clientTo 	= getClient(clientIdTo);

		if(clientTo != null
		&& clientTo.getIsUdpHost()
		&& clientTo.getUdpHostPort() >= EPHEMERAL_MIN 
		&& clientTo.getUdpHostPort() <= EPHEMERAL_MAX){

			GMSPacket hostPacket = new GMSPacket(Message.UDP_HP_NOTICE);
			hostPacket.writeU16(clientIdFrom);
			hostPacket.writeString(clientFrom.getClientIp());
			hostPacket.writeS32(clientFrom.getUdpClientPort());
			clientTo.send(hostPacket);

			GMSPacket joinPacket = new GMSPacket(Message.UDP_HP_NOTICE);
			joinPacket.writeString(clientTo.getClientIp());
			joinPacket.writeS32(clientTo.getUdpHostPort());
			clientFrom.send(joinPacket);

		} else {

			rejectHolePunchRequest(clientFrom);
		}
	}

	public static void rejectHolePunchRequest(Client client){

		client.send(new GMSPacket(Message.UDP_HP_REJECTED));
	}

	public static void handleHostHolePunchReject(GMSPacket packet){

		int rejectedId = packet.readU16LE();

		Client rejectedClient = clients.get(rejectedId);

		rejectedClient.send(new GMSPacket(Message.UDP_HP_REJECTED));
	}
}