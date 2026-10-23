
import socket
import pyscreeze
import cv2
import struct
import logging
import time
from io import BytesIO

logging.basicConfig(level=logging.INFO)

class UdpScreenCaster:
    FPS = 15
    MAX_COMPRESSED_IMG_SIZE = 8 *1024 *1024
    DATAGRAM_DATA_SIZE = 1180
    
    def __init__(self, clientValidator: function):
        
        self._address = socket.gethostbyname(socket.gethostname())
        self._port = None
        self._socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._target_address = None
        self._target_port = None
        
        self._clientValidator = clientValidator
        
        self._img_id = 0
        
        self._wait_for_client = True
        self._casting_stopped = False
    
    def getPort(self):
        return self._port
    
    def bind_socket(self):
        self._socket.bind((self._address, 0))
        self._port = self._socket.getsockname()[1]
        print(f'udp addr: {self._socket.getsockname()[0]}')
        print(f'Udp port: {self._port}')
        
    def start(self):
        if (not self._wait_for_client): 
            return
        while True:
            byteMsg, client = self._socket.recvfrom(5)
            msg = byteMsg.decode()
            print(f'udp recv msg: {msg}')
            validClient = self._clientValidator(client[0])
            print(f'Is client valid: {validClient}')
            print(f'is Hello = Hello: {msg == 'Hello'}')
            if(validClient and msg == 'Hello'):
                print('Check sssss!')
                self._target_address = client[0]
                self._target_port = client[1]
                self._wait_for_client = False;
                break;
        
        self.task = self._casting_loop()
    
    def stop(self):
        self._wait_for_client = False
        self._casting_stopped = True
    
    def _casting_loop(self):
        while not self._casting_stopped:
            
            screenshot = pyscreeze.screenshot()
            img_bytes = BytesIO()
            screenshot.save(
                img_bytes,
                format='JPEG',
                quality=70,
                optimize=False
            )
            
            if(img_bytes.getbuffer().nbytes > self.MAX_COMPRESSED_IMG_SIZE):
                logging.warning('Compressed image is to big!')
                continue
            
            self._send_datagrams(img_bytes)
            self._img_id = (self._img_id + 1) & 0xFFFFFFFF
            time.sleep(1.0/ self.FPS)
        self._socket.close()
            
    
    def _send_datagrams(self, img_bytes : BytesIO) -> None:
        datagram_count = (img_bytes.getbuffer().nbytes + self.DATAGRAM_DATA_SIZE) // self.DATAGRAM_DATA_SIZE
        
        for datagram_index in range(datagram_count):
            img_piece = img_bytes.getbuffer()[
                datagram_index * self.DATAGRAM_DATA_SIZE:
                (datagram_index + 1) * self.DATAGRAM_DATA_SIZE
            ]

            # ! = Big-endian, I = unsigned 32, H = unsigned 16
            header = struct.Struct('!IHH').pack(self._img_id, datagram_index, datagram_count)
            self._socket.sendto(header + img_piece, (self._target_address, self._target_port))
            
                
    
            
            
            