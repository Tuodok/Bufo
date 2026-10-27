import pyscreeze
import time
from io import BytesIO
from enum import Enum
import socket
import struct



class ScreenCaster:
    def __init__(self, datagram_data_size: int, fps: float):
        self.datagram_data_size = datagram_data_size
        self.fps = fps
        self.casting_loop_stopped = False
        self._screenshot_id = 0
    
    def screen_casting_loop(self, datagram_socket: socket, client: tuple[str, int]):
        while not self.casting_loop_stopped:
            
            self.send_screenshot(datagram_socket=datagram_socket, client=client, screenshot_bytes=self.take_screenshot())
            time.sleep(1.0/ self.fps)
  
            
    def send_screenshot(self, datagram_socket: socket, client: tuple[str, int] , screenshot_bytes : BytesIO) -> None:
        datagrams_per_screenshot = (screenshot_bytes.getbuffer().nbytes + self.datagram_data_size) // self.datagram_data_size
        
        for datagram_index in range(datagrams_per_screenshot):
            jpeg_chunk = screenshot_bytes.getbuffer()[
                datagram_index * self.datagram_data_size:
                (datagram_index + 1) * self.datagram_data_size
            ]

            # ! = Big-endian, I = unsigned 32, H = unsigned 16
            header = struct.Struct('!IHH').pack(self._screenshot_id, datagram_index, datagrams_per_screenshot)
            datagram_socket.sendto(header + jpeg_chunk, client)
            
        self._screenshot_id = (self._screenshot_id + 1) & 0xFFFFFFFF
            
      
    def take_screenshot(self) -> BytesIO:
        screenshot = pyscreeze.screenshot()
        bytes = BytesIO()
        screenshot.save(
                bytes,
                format='JPEG',
                quality=70,
                optimize=False
        )
        return bytes