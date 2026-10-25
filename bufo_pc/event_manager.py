import threading
import struct

from tcp_server import TCPServer
from udp_screen_caster import UdpScreenCaster
from robot import Robot


#TCP MSG HEADER
#Sent by server
UDP_PORT_INFO_EVENT = 0

#TCP MSG HEADER
#Sent by client
SCREEN_SIZE_EVENT = 10
KEY_PRESS_EVENT = 11
TAP_EVENT = 12
WRITE_EVENT = 13
ZOOM_EVENT = 14
UNZOOM_EVENT = 15

class EventManager:
    
   
    def __init__(self):
        self._tcp_server = TCPServer()
        self._udp_screen_caster = UdpScreenCaster()
        self._robot = Robot()
        self._screen_casting_thread = None
       
    def run(self):
        self._tcp_server.bind_listener_socket()
        self._udp_screen_caster.bind_socket()
        
        tcp_client_ip, tcp_client_port = self._tcp_server.wait_for_client()
        
        self._tcp_server.send_msg_to_client(
            header=UDP_PORT_INFO_EVENT, 
            content=self._udp_screen_caster.port
        )
        potential_client, handshake_msg = self._udp_screen_caster.wait_for_client()
       
        
        if(potential_client[0] != tcp_client_ip or handshake_msg.decode() != 'Hello'):
            self.closeConnections()
            return
        
        self._screen_casting_thread = threading.Thread(
            target= self._udp_screen_caster.start_casting, 
            args=(potential_client,)
        )

        self._screen_casting_thread.start()
        
        self._tcp_server.handle_client(
            handle_msg=self.handle_tcp_client_msg, 
            handle_socket_error=self.handle_tcp_client_msg
        )
        
        
        
       
    
    
    def close_connections(self):
        if(not self._screen_casting_thread):
            self._udp_screen_caster.socket.close()
            self._tcp_server.client_socket.close()
            return
        
        self._udp_screen_caster.casting_terminated = True
        self._screen_casting_thread.join()
        self._udp_screen_caster.socket.close()
        self._tcp_server.client_handling_terminated = True
        self._tcp_server.client_socket.close()
      
        
        
    def handle_socket_error(self):
        self.close_connections()
        
    def handle_tcp_client_msg(self, client_msg_bytes: bytes):
        if(client_msg_bytes == b''):
            self.close_connections()
            return
            
        header = client_msg_bytes[0]
        content = client_msg_bytes[1:]
        if(header == SCREEN_SIZE_EVENT):
            width, height = struct.unpack('!dd', content)
            self._robot.set_click_pos_scaler(width, height)
            
        elif(header == KEY_PRESS_EVENT):
            self._robot.key_press(content.decode())
            
        elif(header == TAP_EVENT):
            print(f'tap data len: {len(content)}')
            posX, posY =  struct.unpack('!dd', content)
            self._robot.click(posX, posY)
        
        elif(header == WRITE_EVENT):
            self._robot.write(content.decode())
        
        elif(header == ZOOM_EVENT):
            pass
        elif(header == UNZOOM_EVENT):
            pass
            
       
 
    
    
       
            
            
        

   
   
    
                        