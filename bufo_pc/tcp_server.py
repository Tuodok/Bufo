import random
import socket
import asyncio


class TCPServer:

    def __init__(self, callback: function):
        
        self._callback = callback
        self.task = None
        
        self._ip_address = socket.gethostbyname(socket.gethostname())
        self._port = None
        self._end_connection = False
        
        self._listener_socket = None
        self.client_ip = None
        self.client_socket = None
        
    
    def start(self):
        self.task = asyncio.create_task(self._run_server)
        
    async def _run_server(self):
        self._bind_listener_socket()
        await asyncio.to_thread(self._wait_for_client)
        await asyncio.to_thread(self._run_server)

    def _bind_listener_socket(self):
        listener_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        listener_socket.bind((self._ip_address, 0))
        self._port = listener_socket.getsockname()[1]
        return listener_socket
    
    def _wait_for_client(self) -> None:
        self._listener_socket.listen(1)
        print(f'listening at {self._ip_address} : {self._port}')

        client_socket, client_address = self._listener_socket.accept()
        self.client_socket = client_socket
        self.client_ip = client_address[0]
        self._listener_socket.close()

    def _handleClient(self, client_socket: socket, address) -> None:
        self.client_ip = address[0]
        while not self._end_connection:
            try:
                client_msg = client_socket.recv(1024)
                if not client_msg:
                    print('client disconnected')
                    break
                print(f'Received: {client_msg}')
                self._callback(client_msg)
            except (ConnectionResetError, BrokenPipeError, OSError) as e:
                print(f'Connection error with {self.client_ip}: {e}')     
                break       
        client_socket.close()

       


 