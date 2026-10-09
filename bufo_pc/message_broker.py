import json
from robot import Robot

class MessageBroker:
     
    _messageTypes = ('screenSize', 'keyPress', 'tap')
    _robot = Robot()
       
    def processMessage(self, msg):
        print(f'data: {msg}' )
        msg = json.loads(msg)
        
        if 'keyPress' in msg:
            self._robot.key_press(msg['keyPress'])
