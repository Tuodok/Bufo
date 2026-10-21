import asyncio
import struct

from tcp_server import TCPServer
from robot import Robot
from screen_caster import ScreenCaster

SCREEN_SIZE_EVENT = 0;
KEY_PRESS_EVENT = 1;
TAP_EVENT = 2;
WRITE_EVENT = 3;
UDP_EVENT = 4;

class EventManager:
    
    def __init__(self):
        self._tcp_server = TCPServer(self.handle_server_client_msg)
        self._screen_caster = ScreenCaster()
        self._robot = Robot()
     
       
    async def run(self):
        
        self._tcp_server.start()
        #when task is finished connection has been closed
        await self._tcp_server.task
        if(self._screen_caster.task):
            self._screen_caster.stop()
            await self._screen_caster.task
 
    
    def handle_server_client_msg(self, client_msg_bytes: bytes):
        event_type = client_msg_bytes[0]
        content = client_msg_bytes[1:]
        if(event_type & SCREEN_SIZE_EVENT):
            width, height = struct.unpack('!dd', content)
            self._robot.set_click_pos_scaler(width, height)
            
        elif(event_type & KEY_PRESS_EVENT):
            self._robot.key_press(content.decode())
            
        elif(event_type & TAP_EVENT):
            posX, posY =  struct.unpack('!dd', content)
            self._robot.click(posX, posY)
        
        elif(event_type & WRITE_EVENT):
            self._robot.write(content.decode())
            
        elif(event_type & UDP_EVENT):
            self._screen_caster.start(self._tcp_server.client_ip, int.from_bytes(content, 'big'))
            
            
            
        

   
   
    
                        