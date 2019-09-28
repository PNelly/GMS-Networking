import java.util.*;
import java.io.*;
import java.nio.*;
import java.net.*;

public class Client {

	private int id;
	private ClientHandler handler;

	public Client(int id, ClientHandler handler){

		this.id 			= id;
		this.handler 	= handler;
	}

	public int getId(){

		return id;
	}
}