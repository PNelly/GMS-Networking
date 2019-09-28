import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class GMSPacketSplicer {

	private InputStream stream 	= null;
	private byte[] buffer 			= null;

	public GMSPacketSplicer(InputStream stream){

		this.stream = stream;
	}

	private void block(InputStream stream, int amount) 
		throws SocketException, IOException {

		long startTime = System.currentTimeMillis();

		while(stream.available() < amount){

			long elapsed = System.currentTimeMillis() -startTime;

			if(elapsed > Server.SOCKET_TIMEOUT)
				throw new SocketException("block timed out");
		}
	}

	public GMSPacket splice() throws SocketException, IOException {

		block(stream, Server.HEADER_LENGTH);

		// read next packet header

		byte[] header = new byte[Server.HEADER_LENGTH];

		for(int idx = 0; idx < Server.HEADER_LENGTH; ++idx)
			header[idx] = (byte) stream.read();

		System.out.println("received header " + Arrays.toString(header));

		int length 		= readU16LE(header, Server.HEADER_LENGTH -2);

		System.out.println("received length "+length);

		// block for remaining data

		block(stream, length -Server.HEADER_LENGTH);

		// read remaining data

		byte[] buffer = new byte[length];

		for(int idx = 0; idx < length; ++idx)
			buffer[idx] = (idx < Server.HEADER_LENGTH)
									? header[idx]
									: (byte) stream.read();

		return new GMSPacket(buffer);
	}

	private int readU16LE(byte[] data, int pos){

		int first  = 0xFF & (int) data[pos];
		int second = 0xFF & (int) data[pos +1];

		return (int) (second << 8 | first);
	}
}