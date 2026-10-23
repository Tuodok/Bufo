import struct
import socket

from robot import Robot

UDP_PORT_MSG = 0

SCREEN_SIZE_EVENT = 1
KEY_PRESS_EVENT = 2
TAP_EVENT = 3
WRITE_EVENT = 4



class TCPServer:

    def __init__(self, handleClientDisconnection: function):
        
        self._ip_address = socket.gethostbyname(socket.gethostname())
        self._port = None
        self._listener_socket = None
        self._client_ip = None
        self._client_socket = None
        
        self._robot = Robot()
        
        self._handleClientDisconnection = handleClientDisconnection
        
        self._end_connection = False
        
    def getClientIp(self):
        return self._client_ip; 
    
    def bind_listener_socket(self):
        print('Binding')
        self._listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._listener_socket.bind((self._ip_address, 0))
        self._port = self._listener_socket.getsockname()[1]
    
    def start(self, udp_port: int):
        self._wait_for_client()
        self._handleClient(udp_port)
        
    
    
    def _wait_for_client(self):
        self._listener_socket.listen(1)
        print(f'listening at {self._ip_address} : {self._port}')

        client_socket, client_address = self._listener_socket.accept()
        self._client_socket = client_socket
        self._client_ip = client_address[0]
        self._listener_socket.close()
      

    def _handleClient(self, udpPort: int):
        print('handling client')
        
        udpPortMsg = struct.pack('!BH', UDP_PORT_MSG, udpPort)
        self._client_socket.send(udpPortMsg)
        print(f'message sent: {udpPortMsg}')
        
        while not self._end_connection:
            try:
                client_msg = self._client_socket.recv(1024)
                if not client_msg:
                    print('client disconnected')
                    self._handleClientDisconnection()
                    break
              
                self._handle_server_client_msg(client_msg)
                
            except (ConnectionResetError, BrokenPipeError, OSError) as e:
                print(f'Connection error with {self.client_ip}: {e}')     
                break       
        self._client_socket.close()
    
    def _handle_server_client_msg(self, client_msg_bytes: bytes):
            event_type = client_msg_bytes[0]
            content = client_msg_bytes[1:]
            if(event_type == SCREEN_SIZE_EVENT):
                width, height = struct.unpack('!dd', content)
                self._robot.set_click_pos_scaler(width, height)
                
            elif(event_type == KEY_PRESS_EVENT):
                self._robot.key_press(content.decode())
                
            elif(event_type == TAP_EVENT):
                posX, posY =  struct.unpack('!dd', content)
                self._robot.click(posX, posY)
            
            elif(event_type == WRITE_EVENT):
                self._robot.write(content.decode())
                

       


 