import random
import socket
import threading
from message_broker import MessageBroker

class TCPServer:

    _IP_address = socket.gethostbyname(socket.gethostname())
    _port = None
    _messageBroker = MessageBroker()
    _end_connection = False

    def launch(self):
        listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        listener_socket.bind((self._IP_address, 0))
        self._port = listener_socket.getsockname()[1]

        listener_socket.listen(1)
        print(f'listening at {self._IP_address} : {self._port}')

        client_socket, address = listener_socket.accept()
        self._handleClient(client_socket, address)
        listener_socket.close()

    def _handleClient(self, client_socket, adderss):
        while not self._end_connection:
            client_msg = client_socket.recv(1024)
            print(f'Received: {client_msg}')
            self._messageBroker.processMessage(client_msg)
            

        client_socket.close()


 