import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class GMSPacketSplicer {

	private Client client 			= null;
	private InputStream stream 	= null;
	private byte[] buffer 			= null;

	public GMSPacketSplicer(Client client, InputStream stream){

		this.client = client;
		this.stream = stream;
	}

	private byte getNextByte() throws SocketException, IOException {

		int nextByte = stream.read();

		if(nextByte >= 0) 
			return (byte) nextByte;

		long startTime = System.currentTimeMillis();

		while((nextByte = stream.read()) < 0){

			long elapsed = System.currentTimeMillis() -startTime;

			if(elapsed > Server.SOCKET_TIMEOUT)
				throw new SocketException("socket timeout");
		}

		return (byte) nextByte;
	}

	public GMSPacket splice() throws SocketException, IOException {

		// check for GMS handshake

		if(client.getHandShakeStatus() == HandShakeStatus.AWAITING_ACK.getValue()){

			byte[] ack = new byte[4];

			for(int idx = 0; idx < 4; ++idx)
				ack[idx] = getNextByte();

			long magic = readU32LE(ack, 0);

			if(magic == 0xcafebabe)
				return new GMSPacket(Message.HANDSHAKE);
			else
				throw new IOException("handshake missing magic number");

		} else if (client.getHandShakeStatus() == HandShakeStatus.COMPLETE.getValue()){

			// read client header

			byte[] header = new byte[Server.HEADER_LENGTH];

			for(int idx = 0; idx < Server.HEADER_LENGTH; ++idx)
				header[idx] = getNextByte();

			int length 		= readU16LE(header, Server.HEADER_LENGTH -2);

			// read payload

			byte[] buffer = new byte[length];

			for(int idx = 0; idx < length; ++idx)
				buffer[idx] = (idx < Server.HEADER_LENGTH)
										? header[idx]
										: getNextByte();

			return new GMSPacket(buffer);

		} else {

			throw new IOException("client has invalid handshake status");
		}
	}

	private int readU16LE(byte[] data, int pos){

		int first  = 0xFF & (int) data[pos];
		int second = 0xFF & (int) data[pos +1];

		return (int) (second << 8 | first);
	}

	private long readU32LE(byte[] data, int pos){

		int first  = 0xFF & (int) data[pos];
		int second = 0xFF & (int) data[pos +1];
		int third  = 0xFF & (int) data[pos +2];
		int fourth = 0xFF & (int) data[pos +3];

		return (long) (
			0xFFFFFFFFL & (
				fourth << 24 |
				third  << 16 |
				second <<  8 |
				first
			)
		);
	}
}