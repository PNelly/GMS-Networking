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
}