import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

public class Server {
	
	public static String temp;
	public static OutputStream out;
	public static boolean heatOn = false;
	public static boolean manualOn = false;
	public static SerialPort serialPort;
	
    public static void main(String[] args) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
        server.createContext("/temp", new GetTemp());
        server.createContext("/heat", new GetHeat());
        server.createContext("/togheat", new ToggleHeat());
        server.createContext("/togmanual", new ToggleManual());
        server.setExecutor(null); // creates a default executor
        server.start();
        connect("COM3");
        Runtime.getRuntime().addShutdownHook(new Thread(new ShutDown()));
    }

    static class GetTemp implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
            String response = temp;
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }

    static class GetHeat implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
            String response = Boolean.toString(heatOn);
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }

    static class ToggleHeat implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
        	heatOn = !heatOn;
        	System.out.println("Turning heat "+(heatOn?"on":"off"));
            String response = Boolean.toString(heatOn);
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }

    static class ToggleManual implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
        	manualOn = !manualOn;
        	System.out.println("Turning manual "+(manualOn?"on":"off"));
            String response = Boolean.toString(manualOn);
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
    
    public static void connect ( String portName ) throws Exception
    {
        CommPortIdentifier portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
        if ( portIdentifier.isCurrentlyOwned() )
        {
            System.out.println("Error: Port is currently in use");
        }
        else
        {
            CommPort commPort = portIdentifier.open("Treehacks Temperature Server" ,2000);
            
            if ( commPort instanceof SerialPort )
            {
                serialPort = (SerialPort) commPort;
                serialPort.setSerialPortParams(9600,SerialPort.DATABITS_8,SerialPort.STOPBITS_1,SerialPort.PARITY_NONE);
                
                InputStream in = serialPort.getInputStream();
                out = serialPort.getOutputStream();
                               
                (new Thread(new SerialWriter(out))).start();
                
                serialPort.addEventListener(new SerialReader(in));
                serialPort.notifyOnDataAvailable(true);
            }
            else
            {
                System.out.println("Error: Only serial ports are handled by this example.");
            }
        }     
    }
    
    public static class SerialReader implements SerialPortEventListener 
    {
        private InputStream in;
        private byte[] buffer = new byte[1024];
        public SerialReader ( InputStream in )
        {
            this.in = in;
        }
        public void serialEvent(SerialPortEvent arg0) {
            int data;
            try
            {
                int len = 0;
                while ( ( data = in.read()) > -1 )
                {
                    if ( data == '\n' ) {
                        break;
                    }
                    buffer[len++] = (byte) data;
                }
                temp = new String(buffer,0,len);
                System.out.println(temp);
            }
            catch ( IOException e )
            {
                e.printStackTrace();
                System.exit(-1);
            }             
        }
    }
    
    public static class SerialWriter implements Runnable 
    {
        OutputStream out;
        boolean lastState = false;
        boolean lastManual = false;
        public SerialWriter ( OutputStream out )
        {
            this.out = out;
        }
        public void run ()
        {
        	while(true){
	            try
	            {        
	            	//System.out.println(this.lastManual+" "+manualOn);
	                if(this.lastState != heatOn){
	                	this.lastState = heatOn;
	                	System.out.println("writing heat");
	                    this.out.write((heatOn ? '1' : '0'));
	                } else if(this.lastManual != manualOn){
	                	this.lastManual = manualOn;
	                	System.out.println("writing man");
	                    this.out.write((manualOn ? '2' : '3'));
	                }         
	                Thread.sleep(100);
	            }
	            catch ( Exception e )
	            {
	                e.printStackTrace();
	                System.exit(-1);
	            }  
        	}
        }
    }
    
    public static class ShutDown implements Runnable
    {
		@Override
		public void run() {
			System.out.println("Interrupted");
			//serialPort.removeEventListener();
		}
    }
}
