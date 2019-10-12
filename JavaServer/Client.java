import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;	

public class Client implements Runnable {

	private HandShakeStatus handShakeStatus = null;

	private int clientId 							= -1;
	private Socket socket 						= null;
	private GMSPacketSplicer splicer 	= null;
	private String ip 								= null;
	private boolean isUdpHost 				= false;
	private int udpHostPort 					= -1;
	private int udpHostClients 				= 0;
	private int udpHostMaxClients 		= Server.UDP_MAX_CLIENTS;
	private boolean udpHostInProgress = false;
	private int udpClientPort 				= -1;
	private long idleStamp 						= -1;

	public Client(Socket socket) throws IOException {

		this.socket  	= socket;

		this.splicer 	= new GMSPacketSplicer(
			this,
			this.socket.getInputStream()
		);

		this.ip 			= socket.getInetAddress().getHostAddress();

		beginHandShake();
	}

	public HandShakeStatus getHandShakeStatus(){return this.handShakeStatus;}
	public void setHandShakeStatus(HandShakeStatus status){this.handShakeStatus = status;}

	public int 			getClientId(){return this.clientId;}
	public void 		setClientId(int id){this.clientId = id;}

	public String 	getClientIp(){return this.ip;}

	public boolean 	getIsUdpHost(){return this.isUdpHost;}
	public void 		setIsUdpHost(boolean isUdpHost){this.isUdpHost = isUdpHost;}

	public int 			getUdpHostClients(){return this.udpHostClients;}
	public void 		setUdpHostClients(int clients){this.udpHostClients = clients;}

	public int 			getUdpHostMaxClients(){return this.udpHostMaxClients;}
	public void 		setUdpHostMaxClients(int clients){this.udpHostMaxClients = clients;}

	public int 			getUdpHostPort(){return this.udpHostPort;}
	public void 		setUdpHostPort(int udpHostPort){this.udpHostPort = udpHostPort;}

	public int 			getUdpClientPort(){return this.udpClientPort;}
	public void 		setUdpClientPort(int udpClientPort){this.udpClientPort = udpClientPort;}

	public boolean 	getUdpHostInProgress(){return this.udpHostInProgress;}
	public void 		setUdpHostInProgress(boolean inProgress){this.udpHostInProgress = inProgress;}

	public long 		getIdleStamp(){return this.idleStamp;}
	public void 		setIdleStamp(long stamp){this.idleStamp = stamp;}

	@Override
	public void run(){

		System.out.println("starting client thread");

		while(true){

			try {

				GMSPacket packet = splicer.splice();

				handlePacket(packet);

			} catch (IOException e){

				System.out.println("splicer read ioexception: "+e.getMessage());

				Server.disconnectClient(this.clientId);

				close();

				break;
			}
		}

		System.out.println("client handler terminated for client "+clientId);
	}

	public void send(GMSPacket packet){

		System.out.println("sent message "
			+packet.getMessageId()+" to client "
			+clientId
		);

		try {

			OutputStream stream = socket.getOutputStream();

			// use position to exclude padding

			stream.write(packet.getBuffer(), 0, packet.getPosition());
			stream.flush();

		} catch (IOException e){

			System.out.println("client write ioexception: "+e.getMessage());
		}
	}

	private void beginHandShake(){

		System.out.println("begin handshake");

		try {

			OutputStream stream = socket.getOutputStream();

			String str = "GM:Studio-Connect";

			byte[] initial 		= str.getBytes("US-ASCII");
			byte[] terminated = new byte[initial.length +1];

			for(int idx = 0; idx < initial.length; ++idx)
				terminated[idx] = initial[idx];

			terminated[terminated.length -1] = '\0';

			stream.write(terminated, 0, terminated.length);
			stream.flush();

			handShakeStatus = HandShakeStatus.AWAITING_ACK;

		} catch (IOException e){

			System.out.println("io exception on handshake begin");

			close();
		}
	}

	private void completeHandShake(){

		System.out.println("received handshake ack");

		try {

			OutputStream stream = socket.getOutputStream();

			// write magic numbers in little endian

			byte[] magic  = {
				(byte) 0xad, (byte) 0xbe, (byte) 0xaf, (byte) 0xde, // 0xdeafbead
				(byte) 0xeb, (byte) 0xbe, (byte) 0x0d, (byte) 0xf0, // 0xf00dbeeb
				(byte) 0x0c, (byte) 0x00, (byte) 0x00, (byte) 0x00  // 0x0000000c
			}; 

			stream.write(magic);

			stream.flush();

			handShakeStatus = HandShakeStatus.COMPLETE;

			Server.integrateClient(this);

		} catch (IOException e){

			System.out.println("io exception on handshake complete");

			close();
		}
	}

	private void handlePacket(GMSPacket packet){

		if(packet.getMessageId() == Message.HANDSHAKE.getValue())
			completeHandShake();

		if(packet.getMessageId() == Message.NEW_UDP_HOST.getValue()
		|| packet.getMessageId() == Message.UDP_HOST_UPDATE.getValue()
		|| packet.getMessageId() == Message.UDP_HOST_CANCEL.getValue()
		|| packet.getMessageId() == Message.NEW_UDP_CLIENT.getValue()
		|| packet.getMessageId() == Message.UDP_HP_REQUEST.getValue())
			setIdleStamp(System.currentTimeMillis());

		if(packet.getMessageId() == Message.TCP_KEEP_ALIVE.getValue())
			send(new GMSPacket(Message.TCP_KEEP_ALIVE_ACK));

		if(packet.getMessageId() == Message.REQUEST_ID.getValue()){
			GMSPacket outPacket = new GMSPacket(Message.TELL_NEW_ID);
			outPacket.writeU16(clientId);
			send(outPacket);
		}

		if(packet.getMessageId() == Message.CLIENT_DISCONNECTED.getValue())
			Server.disconnectClient(clientId);

		if(packet.getMessageId() == Message.NEW_UDP_HOST.getValue())
			send(new GMSPacket(Message.REQUEST_UDP_PING));

		if(packet.getMessageId() == Message.UDP_HOST_UPDATE.getValue())
			Server.handleHostUpdate(this, packet);

		if(packet.getMessageId() == Message.UDP_HOST_CANCEL.getValue())
			Server.handleHostCancel(this);

		if(packet.getMessageId() == Message.NEW_UDP_CLIENT.getValue())
			send(new GMSPacket(Message.REQUEST_UDP_PING));

		if(packet.getMessageId() == Message.UDP_HP_REQUEST.getValue())
			Server.handleHolePunchRequest(clientId, packet.readU16LE());

		if(packet.getMessageId() == Message.UDP_HP_REJECTED.getValue())
			Server.handleHostHolePunchReject(packet);

	}

	public void close(){

		try {

			if(!socket.isClosed())
				this.socket.close();

		} catch (IOException e){

			// nothing to be done
		}
	}
}