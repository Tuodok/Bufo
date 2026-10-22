
import socket
import pyscreeze
import cv2
import struct
import logging
import time

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
    
    def start(self):

        self._socket.bind(self._address, 0)
        self._port = self._socket.getsockname()[1]
        
        while self._wait_for_client:
            msg, client = self._socket.recvfrom(5)
            
            validClient = self._clientValidator(self._target_address)
            if(not validClient):
                continue
            elif(msg != 'Hello'):
                continue
            self._target_address = client[0]
            self._target_port = client[1]
            break
        
        self.task = self._casting_loop()
    
    def stop(self):
        self._wait_for_client = False
        self._casting_stopped = True
    
    def _casting_loop(self):
        while not self._casting_stopped:
            
            screenshot = pyscreeze.screenshot()
            success, compressed_img = cv2.imencode('.jpg',screenshot,[cv2.IMWRITE_JPEG_QUALITY, 70])
            
            if not success:
                continue
            
            img_bytes = compressed_img.tobytes()
            
            if(len(img_bytes) > self.MAX_COMPRESSED_IMG_SIZE):
                logging.warning('Compressed image is to big!')
                continue
            
            self._send_datagrams(img_bytes)
            self._img_id = (self._img_id + 1) & 0xFFFFFFFF
            time.sleep(1.0/ self.FPS)
        self._socket.close()
            
    
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
            
                
    
            
            
            