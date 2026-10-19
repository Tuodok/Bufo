import asyncio
import socket
import pyscreeze
import cv2
import struct
import logging
import time

logging.basicConfig(level=logging.INFO)

class ScreenCaster:
    FPS = 15
    MAX_COMPRESSED_IMG_SIZE = 8 *1024 *1024
    DATAGRAM_DATA_SIZE = 1180
    
    def __init__(self):
        
        self._target_address = None
        self._target_port = None
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        
        self._img_id = 0
        
        self.task = None
        self._casting_stopped = False
    
    def start(self, target_address: str, target_port: int):
        self._target_address = target_address
        self._target_port = target_port
        self.task = asyncio.create_task(self._casting_loop())
    
    def stop(self):
        self._casting_stopped = True
    
    async def _casting_loop(self) -> None:
        while not self._casting_stopped:
            
            screenshot = await asyncio.to_thread(pyscreeze.screenshot)
            success, compressed_img = await asyncio.to_thread(
                cv2.imencode,
                '.jpg',
                screenshot,
                [cv2.IMWRITE_JPEG_QUALITY, 70]
            )
            if not success:
                continue
            
            img_bytes = compressed_img.tobytes()
            
            if(len(img_bytes) > self.MAX_COMPRESSED_IMG_SIZE):
                logging.warning('Compressed image is to big!')
                continue
            
            self._send_datagrams(img_bytes)
            self._img_id = (self._img_id + 1) & 0xFFFFFFFF
            await asyncio.sleep(1.0/ self.FPS)
            
    
    def _send_datagrams(self, img_bytes : bytes) -> None:
        datagram_count = (len(img_bytes) + self.DATAGRAM_DATA_SIZE) // self.DATAGRAM_DATA_SIZE
        
        for datagram_index in range(datagram_count):
            img_piece = img_bytes[
                datagram_index * self.DATAGRAM_DATA_SIZE:
                (datagram_index + 1) * self.DATAGRAM_DATA_SIZE
            ]

            # ! = Big-endian, I = unsigned 32, H = unsigned 16
            header = struct.Struct('!IHH').pack(self._img_id, datagram_index, datagram_count)
            self._socket.sendto(header + img_piece, self._target_address, self._target_port)
            
                
    
            
            
            