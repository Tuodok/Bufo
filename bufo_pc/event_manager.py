import asyncio
import json

from tcp_server import TCPServer
from robot import Robot
from screen_caster import ScreenCaster


class EventManager:
    
    def __init__(self):
        self._tcp_server = TCPServer(self.handle_server_client_msg)
        self._screen_caster = ScreenCaster()
        self._robot = Robot()
     
       
    async def run(self) -> None:
        
        self._tcp_server.start()
        #when task is finished connection has been closed
        await self._tcp_server.task
        # stop screen casting
        self._screen_caster.stop()
        await self._screen_caster.task
 
    
    def handle_server_client_msg(self, client_msg : str) -> None:
        print(f'data: {client_msg}' )
        client_msg = json.loads(client_msg)
            
        if 'keyPress' in client_msg:
            self._robot.key_press(client_msg['keyPress'])
        elif 'write' in client_msg:
            self._robot._robot.write(client_msg['write'])
        elif 'screenSize' in client_msg:
            width = client_msg['screenSize'][0]
            height = client_msg['screenSize'][1]
            self._robot.set_click_pos_scaler(width, height)
        elif 'tap' in client_msg:
            self._robot.click(client_msg['tap'][0], client_msg['tap'][1])
        elif 'udp' in client_msg:
            self._screen_caster.start()

   
   
    
                        