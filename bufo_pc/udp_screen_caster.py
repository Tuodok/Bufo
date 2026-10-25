
import socket
import pyscreeze
import cv2
import struct
import time
from io import BytesIO


FPS = 15
   
DATAGRAM_DATA_SIZE = 1180

class UdpScreenCaster:
    
    def __init__(self):
        
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.port = None
        self.casting_terminated = False
        
        self._address = socket.gethostbyname(socket.gethostname())
        
        self._img_id = 0
        
    
    def bind_socket(self):
        self.socket.bind((self._address, 0))
        self.port = self.socket.getsockname()[1]
       
    
    def wait_for_client(self) ->tuple[tuple[str, int], bytes]:
        handshake_msg, potential_client = self.socket.recvfrom(5)
        return (potential_client, handshake_msg)
        
  
    
    def start_casting(self, client: tuple[str, int]):
        while not self.casting_terminated:
            
            screenshot = pyscreeze.screenshot()
            img_bytes = BytesIO()
            screenshot.save(
                img_bytes,
                format='JPEG',
                quality=70,
                optimize=False
            )
            
            self._send_screenshot(img_bytes, client)
            self._img_id = (self._img_id + 1) & 0xFFFFFFFF
            time.sleep(1.0/ FPS)
            
    
    def _send_screenshot(self, img_bytes : BytesIO, client: tuple[str, int]) -> None:
        datagrams_per_screenshot = (img_bytes.getbuffer().nbytes + DATAGRAM_DATA_SIZE) // DATAGRAM_DATA_SIZE
        
        for datagram_index in range(datagrams_per_screenshot):
            jpeg_chunk = img_bytes.getbuffer()[
                datagram_index * DATAGRAM_DATA_SIZE:
                (datagram_index + 1) * DATAGRAM_DATA_SIZE
            ]

            # ! = Big-endian, I = unsigned 32, H = unsigned 16
            header = struct.Struct('!IHH').pack(self._img_id, datagram_index, datagrams_per_screenshot)
            self.socket.sendto(header + jpeg_chunk, client)
            
                
    
            
            
            