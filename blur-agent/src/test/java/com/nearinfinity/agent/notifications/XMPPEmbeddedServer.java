package com.nearinfinity.agent.notifications;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class XMPPEmbeddedServer implements Runnable {
	private static final Log log = LogFactory.getLog(XMPPEmbeddedServer.class);
	private static Thread serverThread;
	private static XMPPEmbeddedServer server;
	private ServerSocket socket;
	
	public static void startServer(int port) {
		server = new XMPPEmbeddedServer(port);
		serverThread = new Thread(server);
		serverThread.start();
	}
	
	public static void stopServer() {
		server.closeServer();
		serverThread.interrupt();
	}
	
	public static List<Object> getMessages() {
		return new ArrayList<Object>();
	}
	
	private XMPPEmbeddedServer(int port) {
		try {
			log.info("Starting IM Server *:" + port);
			socket = new ServerSocket(port);
			log.info("IM Server started *:" + port);
		} catch (IOException e) {
			log.error("Error creating IM server:" + e.getMessage());
			stopServer();
		}
	}

	@Override
	public void run() {
		if (socket == null) {
			log.info("IM Server has not been configured.");
		} else {
			while(true) {
				if (socket != null) {
					try {
						Socket accept = socket.accept();
						System.out.println("got a connection");
						
						PrintWriter out = new PrintWriter(accept.getOutputStream(), true);
						out.println("<stream id='xxxx' from='192.168.0.12:5222' xmlns='jabber:client'/>");
						
						BufferedReader in = new BufferedReader(new InputStreamReader(accept.getInputStream()));
						
						String inputLine;
						while ((inputLine = in.readLine()) != null) { 
							System.out.println(inputLine);
						}
						
//						out = new PrintWriter(accept.getOutputStream(), true);
//						out.println("<iq type='result' id='reg2'/>");
						
						
						
					} catch (IOException e) {
//						e.printStackTrace();
					}
				}
			}
		}
	}
	
	public void closeServer() {
		if (socket != null) {
			try {
				log.info("Shutting down IM server");
				socket.close();
				log.info("IM server has been shut down");
			} catch (IOException e) {
				log.error("There was a problem trying to close IM server: " + e.getMessage());
			}
			socket = null;
		}
	}
	
	
}
