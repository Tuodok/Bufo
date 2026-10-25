import struct
import socket

from robot import Robot




class TCPServer:

    def __init__(self):
        
        self.client_socket = None
        self.client_handling_terminated = False
        
        self._ip_address = socket.gethostbyname(socket.gethostname())
        self._listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._port = None
        
        
       
    def bind_listener_socket(self):
        self._listener_socket.bind((self._ip_address, 0))
        self._port = self._listener_socket.getsockname()[1]
    
    
    def wait_for_client(self) -> tuple[str, int]:
        self._listener_socket.listen(1)
        print(f'listening at {self._ip_address} : {self._port}')

        client_socket, client = self._listener_socket.accept()
        self.client_socket = client_socket
        self._listener_socket.close()
        
        return client
        
    def send_msg_to_client(self, header: int, content: int):
        # B = Unsigned Char, H = Unsgined short
        udp_port_msg = struct.pack('!BH', header, content)
        self.client_socket.send(udp_port_msg)
        

    def handle_client(self, handle_msg: function, handle_socket_error: function):
    
        while not self.client_handling_terminated:
            try:
                client_msg = self.client_socket.recv(1024)
              
                handle_msg(client_msg)
                
            except TimeoutError:
                handle_socket_error()
            except ConnectionResetError:
                handle_socket_error()
            except OSError:
                handle_socket_error()
            
    
    
                

       


 