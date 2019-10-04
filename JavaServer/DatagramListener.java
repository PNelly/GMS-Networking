import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;	

public class DatagramListener implements Runnable {

	private volatile boolean listening 	= false;
	private DatagramSocket udpSocket 		= null;
	private byte[] listenBuffer 				= new byte[Server.DATAGRAM_LENGTH];

	public DatagramListener(int port) throws IOException {

		try {

			udpSocket = new DatagramSocket(port);
			listening = true;

		} catch (IOException e){

			System.out.println("datagram listener startup failed");
		}
	}

	@Override
	public void run(){

		System.out.println("datagram listener started");

		while(listening){

			DatagramPacket inPacket = 
				new DatagramPacket(
					listenBuffer, 
					listenBuffer.length
				);

			try {

				udpSocket.receive(inPacket);

				InetAddress senderAddress = inPacket.getAddress();
				int senderPort 						= inPacket.getPort();

				handlePacket(
					new GMSPacket(inPacket.getData()), 
					senderAddress,
					senderPort
				);

			} catch (IOException e){

				System.out.println("datagram ioexception");
			}
		}

		shutdown();
	}

	public void shutdown(){

		listening = false;
		udpSocket.close();
	}

	public void handlePacket(GMSPacket inPacket, InetAddress senderAddress, int senderPort){

		int messageId = inPacket.getMessageId();
		int clientId 	= inPacket.readU16LE();
		Client client = Server.getClient(clientId);

		if(messageId == Message.UDP_PING_H_W_H.getValue()
		|| messageId == Message.UDP_PING_C_W_H.getValue())
			client.setUdpHostPort(senderPort);

		if(messageId == Message.UDP_PING_H_W_C.getValue()
		|| messageId == Message.UDP_PING_C_W_C.getValue())
			client.setUdpClientPort(senderPort);

		boolean hasBoth = (
			client.getUdpHostPort() > 0
			&& client.getUdpClientPort() > 0
		);

		if(hasBoth){

			if(messageId == Message.UDP_PING_H_W_H.getValue()
			|| messageId == Message.UDP_PING_H_W_C.getValue()){
				client.setIsUdpHost(true);
				client.setUdpHostClients(0);			
			}

			GMSPacket outPacket = new GMSPacket(Message.UDP_ACK);
			outPacket.writeString(senderAddress.getHostAddress());
			outPacket.writeS32(client.getUdpHostPort());
			outPacket.writeS32(client.getUdpClientPort());

			client.send(outPacket);

			Server.updateClientInfo(clientId);
		}
	}
}