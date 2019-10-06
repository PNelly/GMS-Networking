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

		byte[] header = new byte[Server.HEADER_LENGTH];

		for(int idx = 0; idx < Server.HEADER_LENGTH; ++idx)
			header[idx] = getNextByte();

		int length 		= readU16LE(header, Server.HEADER_LENGTH -2);

		byte[] buffer = new byte[length];

		for(int idx = 0; idx < length; ++idx)
			buffer[idx] = (idx < Server.HEADER_LENGTH)
									? header[idx]
									: getNextByte();

		return new GMSPacket(buffer);
	}

	private int readU16LE(byte[] data, int pos){

		int first  = 0xFF & (int) data[pos];
		int second = 0xFF & (int) data[pos +1];

		return (int) (second << 8 | first);
	}
}