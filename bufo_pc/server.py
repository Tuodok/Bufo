from dataclasses import dataclass
import threading
import struct
import socket
import pyscreeze
import struct
import time
from io import BytesIO
from enum import Enum

from tcp_server import TCPServer
from udp_screen_caster import ScreenCastMode
from robot import Robot



DATAGRAM_DATA_SIZE = 1180
#TCP MSG HEADER
#Sent by server
UDP_PORT_INFO_EVENT = 0

#TCP MSG HEADER
#Sent by client
SCREEN_SIZE_EVENT = 10
KEY_PRESS_EVENT = 11
TAP_EVENT = 12
WRITE_EVENT = 13
UDP_PORT_INFO_EVENT = 14
ZOOM_EVENT = 15
CANCEL_ZOOM_EVENT = 16
CHANGE_SCREEN_CAST_MODE = 17

class ScreenCastMode(Enum):
    STREAM = 1
    ON_CLIENT_ACTION = 2
    PAUSED = 3


@dataclass
class ServerClient:
    connection_socket: socket.socket = None
    ip_address: str = None
    tcp_port: int = None
    udp_port: int = None
    screen_width_scaler: float = 0.0
    screen_height_scaler: float = 0.0
    
@dataclass
class ScreenCast:
    screen_cast_mode: ScreenCastMode = ScreenCastMode.STREAM
    fps: float = 15.0
    casting_stopped:bool = False
    screenshot_id: int = 0


class Server:
   
    def __init__(self):
        print(f'host name: {socket.gethostname}');
        self._ip_address = socket.gethostbyname(socket.gethostname())
        self._client = ServerClient()
        self._listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._datagram_socket = socket.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._screen_cast = ScreenCast()
        self._robot = Robot()
        self._screen_casting_loop_thread = threading.Thread(
            target= self._udp_screen_caster.casting_loop, 
            daemon=True
        )
       
    def launch(self):
        self._listener_socket.bind((self._ip_address, 0))
        
        (self._client.ip_address, self._client.tcp_port), self._client.connection_socket_socket = self._wait_for_client()
        
        
        self._handle_client(
            handle_msg=self._handle_tcp_client_msg, 
            handle_socket_error=self._handle_socket_error
        )
        
    
    def close(self):
        if(not self._screen_casting_loop_thread.is_alive):
            self._screen_cast.casting_stopped = True
            self._screen_casting_loop_thread.join()

        self._udp_screen_caster.socket.close()
        self._tcp_server.client_handling_terminated = True
        self._tcp_server.client_socket.close()
        
        
    def _wait_for_client(self) -> tuple[tuple[str, int], socket.socket]:
        print(f'IP: {self._ip_address}, Port {self._listener_socket.getsockname()[1]}')
        
        self._listener_socket.listen(1)
        client_socket, client = self._listener_socket.accept()
        self._listener_socket.close()
        return client, client_socket
        
        

    def _handle_client(self, handle_msg: function, handle_socket_error: function):
    
        while not self._screen_cast.casting_stopped:
            try:
                client_msg = self._client.connection_socket.recv(1024)
                
                handle_msg(client_msg)
                
            except TimeoutError:
                handle_socket_error()
            except ConnectionResetError:
                handle_socket_error()
            except OSError:
                handle_socket_error()
                
    def _screen_casting_loop(self):

        while not self._casting_loop_terminated:
            
            self._send_screenshot(self._take_screenshot())
            time.sleep(1.0/ self._screen_cast.fps)

    def _take_screenshot(self) -> BytesIO:
        screenshot = pyscreeze.screenshot()
        bytes = BytesIO()
        screenshot.save(
                bytes,
                format='JPEG',
                quality=70,
                optimize=False
            )
        return bytes
            
        
            
    def _send_screenshot(self, img_bytes : BytesIO) -> None:
        datagrams_per_screenshot = (img_bytes.getbuffer().nbytes + DATAGRAM_DATA_SIZE) // DATAGRAM_DATA_SIZE
        
        for datagram_index in range(datagrams_per_screenshot):
            jpeg_chunk = img_bytes.getbuffer()[
                datagram_index * DATAGRAM_DATA_SIZE:
                (datagram_index + 1) * DATAGRAM_DATA_SIZE
            ]

            # ! = Big-endian, I = unsigned 32, H = unsigned 16
            header = struct.Struct('!IHH').pack(self._img_id, datagram_index, datagrams_per_screenshot)
            print(f'sending to: {self.client}')
            self.socket.sendto(header + jpeg_chunk, self.client)
            
        self._screen_cast.screenshot_id = (self._img_id + 1) & 0xFFFFFFFF
        
    def _handle_socket_error(self):
        self.close_connections()
        
    def _handle_tcp_client_msg(self, client_msg_bytes: bytes):
        if(client_msg_bytes == b''):
            self.close_connections()
            return
            
        header = client_msg_bytes[0]
        msg_content = client_msg_bytes[1:]
        if(header == SCREEN_SIZE_EVENT):
            width, height = struct.unpack('!dd', msg_content)
            self._client.screen_width_scaler = self._robot.screenWidth / width
            self._client.screen_height_scaler = self._robot.screenHeight / height
            
        elif(header == KEY_PRESS_EVENT):
            self._robot.key_press(msg_content.decode())
            
        elif(header == TAP_EVENT):
            posX, posY =  struct.unpack('!dd', msg_content)
            self._robot.click(posX*self._client.screen_width_scaler, posY * self._client.screen_height_scaler)
        
        elif(header == WRITE_EVENT):
            self._robot.write(msg_content.decode())
            
        elif(header == UDP_PORT_INFO_EVENT):
            if(self._client.udp_port):
                return
            self._client.udp_port = int.from_bytes(msg_content)
            if(self._screen_cast.screen_cast_mode == ScreenCastMode.STREAM):
                self._screen_casting_loop_thread.start()
        
        elif(header == ZOOM_EVENT):
            pass
        elif(header == CANCEL_ZOOM_EVENT):
            pass
        else:
            return
        
        if(self._screen_cast.screen_cast_mode == ScreenCastMode.ON_CLIENT_ACTION and self._client.udp_port):
            self._send_screenshot(self._take_screenshot)
            
    
 
    
    
       
            
            
        

   
   
    
                        