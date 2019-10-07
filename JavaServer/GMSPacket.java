import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class GMSPacket {

	private static final int START_SIZE = 1024;

	private boolean isClientHandshake = false;

	private byte[] buffer = null;
	private int pos 			= -1;
	private int messageId = -1;
	private int length 		= -1;
	private boolean isUdp = false;

	public GMSPacket(byte[] buffer){
		
		// inbound constructor //

		pos 						= 0;
		this.buffer 		= buffer;

		// consume header

		this.isUdp 			= (readNextByte() == 1);
		this.messageId 	= readU16LE();
		this.length 		= readU16LE();

		System.out.println(
			"new GMS packet with messageId "
			+messageId+" is udp "+isUdp
			+" length "+length
		);
	}

	public GMSPacket(Message message){

		// outbound constructor //

		pos 						= Server.CLIENT_HDR_LEN + Server.GMS_HDR_LEN;
		this.buffer 		= new byte[START_SIZE];
		this.isUdp 			= false; // server doesn't send datagrams
		this.messageId 	= message.getValue();
	}

	public GMSPacket(Message message, boolean isClientHandshake){

		this.isClientHandshake = isClientHandshake;

		this(message);
	}

	public boolean getIsClientHandshake(){

		return isClientHandshake;
	}

	public int getMessageId(){

		return this.messageId;
	}

	public byte[] getBuffer(){

		int startPos = pos;

		// write client header

		pos = GMS_HDR_LEN;

		writeBool(isUdp);
		writeU16(messageId);
		writeU16(startPos);

		// write GMS header

		pos = 0;

		writeU32((long) 0xdeadc0de);
		writeU32((long) GMS_HDR_LEN);
		writeU32((long) startPos);

		// reset write position

		pos = startPos;

		return this.buffer;
	}

	public int getPosition(){

		return this.pos;
	}

	private byte readNextByte(){

		return buffer[pos++];
	}

	public boolean readBool(){

		return (readNextByte() == 1);
	}

	public int readU8(){

		return (0xFF & (int) readNextByte());
	}

	public int readU16LE(){

		int first  = readU8();
		int second = readU8();

		return (int) (second << 8 | first);
	}

	public long readU32LE(){

		int first  = readU8();
		int second = readU8();
		int third  = readU8();
		int fourth = readU8();

		return (long) (
			0xFFFFFFFFL & (
				fourth << 24 |
				third  << 16 |
				second <<  8 |
				first
			)
		);
	}

	public void writeBool(boolean value){

		buffer[pos++] = (byte) ((value) ? 1 : 0);
	}

	public void writeU8(int value){

		buffer[pos++] = (byte) value;
	}

	public void writeU16(int value){

		byte first  = (byte) (value);
		byte second = (byte) (value >> 8);

		buffer[pos++] = first;
		buffer[pos++] = second;
	}

	public void writeU32(long value){

		byte first  = (byte) (value);
		byte second = (byte) (value >> 8);
		byte third  = (byte) (value >> 16);
		byte fourth = (byte) (value >> 24);

		buffer[pos++] = first;
		buffer[pos++] = second;
		buffer[pos++] = third;
		buffer[pos++] = fourth;
	}

	public void writeS32(int value){

		byte first  = (byte) (value);
		byte second = (byte) (value >> 8);
		byte third  = (byte) (value >> 16);
		byte fourth = (byte) (value >> 24);

		buffer[pos++] = first;
		buffer[pos++] = second;
		buffer[pos++] = third;
		buffer[pos++] = fourth;	
	}

	public void writeString(String value){
		
		try {

			byte[] stringBytes = value.getBytes("UTF-8");

			for(int idx = 0; idx < stringBytes.length; ++idx)
				buffer[pos++] = stringBytes[idx];

			buffer[pos++] = '\0';

		} catch (UnsupportedEncodingException e){

			System.out.println(e.getMessage());
		}
	}		

	/*public static void main(String[] args){

		GMSPacket packet = new GMSPacket(Message.TELL_NEW_ID);

		packet.writeU8(64);
		packet.writeU8(128);
		packet.writeU8(255);
		packet.writeU16(32768);
		packet.writeU16(49152);
		packet.writeU16(65535);
		packet.writeString("dog");
	}*/
}