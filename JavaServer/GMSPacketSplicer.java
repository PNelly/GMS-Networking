import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class GMSPacketSplicer {

	private Client client 			= null;
	private InputStream stream 	= null;
	private byte[] inBuffer 		= null;
	private int inBufferPos 		= -1;

	public GMSPacketSplicer(Client client, InputStream stream){

		this.client 			= client;
		this.stream 			= stream;
		this.inBuffer 		= new byte[Server.IN_BUFFER_LEN];
		this.inBufferPos 	= 0;
	}

	private void doubleInBuffer(){

		byte[] newBuff = new byte[2 * inBuffer.length];

		for(int idx = 0; idx < inBuffer.length; ++idx)
			newBuff[idx] = inBuffer[idx];

		inBuffer = newBuff;
	}

	private byte getNextByte() throws SocketException, IOException {

		int nextByte = stream.read();

		if(nextByte >= 0)
			return (byte) nextByte;

		long startTime = System.currentTimeMillis();

		while((nextByte = stream.read()) < 0){

			try {

				// prevent cpu burn
				Thread.sleep(Server.SOCKET_INTERVAL);

			} catch(InterruptedException e){

				Thread.currentThread.interrupt();
			}

			long elapsed = System.currentTimeMillis() -startTime;

			if(elapsed > Server.SOCKET_TIMEOUT)
				throw new SocketException("socket timeout");
		}

		return (byte) nextByte;
	}

	private byte[] scanToNextPacket() throws SocketException, IOException {

		// scan input stream to next valid packet //

		byte[] scanBuff = new byte[Server.GMS_HDR_LEN];

		boolean newPacket = false;

		while(!newPacket){

			while(readU32LE(scanBuff, 0) != 0xdeadc0deL){

				scanBuff = new byte[Server.GMS_HDR_LEN];

				while((scanBuff[0] = getNextByte()) != (byte) 0xde);

				if((scanBuff[1] = getNextByte()) != (byte) 0xc0) continue;
				if((scanBuff[2] = getNextByte()) != (byte) 0xad) continue;
				if((scanBuff[3] = getNextByte()) != (byte) 0xde) continue;
			}

			// read remaining header bytes

			for(int idx = 4; idx < Server.GMS_HDR_LEN; ++idx)
				scanBuff[idx] = getNextByte();

			// extract gms length

			byte[] lenBytes = new byte[4];

			for(int idx = 0; idx < 4; ++idx)
				lenBytes[idx] = scanBuff[Server.GMS_HDR_LEN -4 + idx];

			int len = (int) readU32LE(lenBytes, 0);

			if(len >= Server.CLIENT_HDR_LEN)
				newPacket = true;
			else
				continue;
		}

		return scanBuff;
	}

	public GMSPacket splice() throws SocketException, IOException {

		if(client.getHandShakeStatus() == HandShakeStatus.AWAITING_ACK){

			// Complete Handshake
			// ==================

			int size = 8;

			byte[] ack = new byte[size];

			for(int idx = 0; idx < size; ++idx)
				ack[idx] = getNextByte();

			long magic0 = readU32LE(ack, 0);
			long magic1 = readU32LE(ack, 4);

			if(magic0 == 0xcafebabeL
			&& magic1 == 0xdeadb00bL)
				return new GMSPacket(Message.HANDSHAKE);
			else
				throw new IOException("handshake missing magic number");

		} else if (client.getHandShakeStatus() == HandShakeStatus.COMPLETE){

			// Read Packet Data
			// ================

			byte[] scanBuff = scanToNextPacket();

			// copy GMS header to inBuffer

			inBufferPos = 0;

			for(int idx = 0; idx < Server.GMS_HDR_LEN; ++idx)
				inBuffer[inBufferPos++] = scanBuff[idx];

			// consume application header

			for(int idx = 0; idx < Server.CLIENT_HDR_LEN; ++idx)
				inBuffer[inBufferPos++] = getNextByte();

			// hdr capture for debugging

			int hdrSize = Server.GMS_HDR_LEN +Server.CLIENT_HDR_LEN;

			byte[] hdr = new byte[hdrSize];

			for(int idx = 0; idx < hdrSize; ++idx)
				hdr[idx] = inBuffer[idx];

			// extract length from GMS header

			byte[] lenBytes = new byte[4];

			for(int idx = 0; idx < 4; ++idx)
				lenBytes[idx] = inBuffer[Server.GMS_HDR_LEN -4 +idx];

			int payLen = (int) readU32LE(lenBytes, 0) -Server.CLIENT_HDR_LEN;
				// application header included in GMS payload length

			// read payload

			int payPos = 0;

			while(payPos < payLen){

				if(inBufferPos == inBuffer.length)
					doubleInBuffer();

				inBuffer[inBufferPos++] = getNextByte();

				++payPos;
			}

			// tailor packet buffer

			byte[] packetBuffer = new byte[inBufferPos];

			for(int idx = 0; idx < inBufferPos; ++idx)
				packetBuffer[idx] = inBuffer[idx];

			return new GMSPacket(packetBuffer);

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