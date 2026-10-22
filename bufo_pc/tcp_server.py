import struct
import socket

from robot import Robot

SCREEN_SIZE_EVENT = 1;
KEY_PRESS_EVENT = 2;
TAP_EVENT = 3;
WRITE_EVENT = 4;
UDP_EVENT = 5;


class TCPServer:

    def __init__(self):
        
        self._ip_address = socket.gethostbyname(socket.gethostname())
        self._port = None
        self._listener_socket = None
        self._client_ip = None
        self._client_socket = None
        
        self._robot = Robot()
        
        self._end_connection = False
        
    def getClientIp(self):
        return self._client_ip; 
    
    def start(self):
        self._bind_listener_socket()
        self._wait_for_client()
        self._handleClient, self.client_socket()
        
    def _bind_listener_socket(self):
        print('Binding')
        self._listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._listener_socket.bind((self._ip_address, 0))
        self._port = self._listener_socket.getsockname()[1]
    
    def _wait_for_client(self):
        self._listener_socket.listen(1)
        print(f'listening at {self._ip_address} : {self._port}')

        client_socket, client_address = self._listener_socket.accept()
        self.client_socket = client_socket
        self.client_ip = client_address[0]
        self._listener_socket.close()
      

    def _handleClient(self, client_socket: socket):
        print('handling client')
        
        while not self._end_connection:
            try:
                client_msg = client_socket.recv(1024)
                if not client_msg:
                    print('client disconnected')
                    break
              
                self._callback(client_msg)
            except (ConnectionResetError, BrokenPipeError, OSError) as e:
                print(f'Connection error with {self.client_ip}: {e}')     
                break       
        client_socket.close()
    
    def handle_server_client_msg(self, client_msg_bytes: bytes):
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
                

       


 