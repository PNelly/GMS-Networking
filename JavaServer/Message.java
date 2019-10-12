
public enum Message {

	HANDSHAKE(Server.U16_MAX), // invisible to client

	TELL_NEW_ID(0),
	TCP_KEEP_ALIVE(1),
	TCP_KEEP_ALIVE_ACK(2),
	REQUEST_ID(3),
	IDLE_DISCONNECT(4),
	NEW_UDP_HOST(5),
	NEW_UDP_CLIENT(6),
	REQUEST_UDP_PING(7),
	UDP_PING_H_W_H(8),   // host with host socket
	UDP_PING_H_W_C(9),   // host with client socket
	UDP_PING_C_W_H(10),  // client with host socket
	UDP_PING_C_W_C(11),  // client with client socket
	UDP_ACK(12),
	UDP_HOST_CANCEL(13),
	UDP_HP_REQUEST(14),
	UDP_HP_NOTICE(15),
	UDP_HP_REJECTED(16),
	CLIENT_CONNECTED(17),
	CLIENT_DISCONNECTED(18),
	CLIENT_UPDATE(19),
	BRING_UP_TO_SPEED(20),
	UDP_HOST_UPDATE(21);

	private final int value;

	private Message(int value){
		this.value = value;
	}

	public int getValue(){
		return this.value;
	}
}