import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class GMSPacket {

	private byte[] buffer = null;
	private int pos 			= -1;
	private int messageId = -1;
	private int length 		= -1;
	private boolean isUdp = false;

	public GMSPacket(byte[] buffer){
		
		pos 						= 0;
		this.buffer 		= buffer;

		// consume header

		this.isUdp 			= (nextByte() != 0);
		this.messageId 	= readU16LE();
		this.length 		= readU16LE();

		System.out.println(
			"new GMS Packet: isUdp "
			+isUdp+" msg id "
			+messageId+" length "
			+length
		);
	}

	public int getMessageId(){

		return this.messageId;
	}

	private byte nextByte(){

		return buffer[pos++];
	}

	public int readU8(){

		return (0xFF & (int) nextByte());
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
}