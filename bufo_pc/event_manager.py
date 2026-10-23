import threading

from tcp_server import TCPServer
from udp_screen_caster import UdpScreenCaster


class EventManager:
    
    def __init__(self):
        self._tcp_server = TCPServer(handleClientDisconnection= lambda : self._screen_caster.stop())
        self._screen_caster = UdpScreenCaster(clientValidator= lambda ip: ip == self._tcp_server.getClientIp())
     
       
    def run(self):
        self._tcp_server.bind_listener_socket()
        self._screen_caster.bind_socket()
        
        tcp_server_thread = threading.Thread(target= self._tcp_server.start, args=(self._screen_caster.getPort(),))
        
        tcp_server_thread.start()
        self._screen_caster.start()
        tcp_server_thread.join()
    
 
        
        
        
        
  
       
 
    
    
       
            
            
        

   
   
    
                        