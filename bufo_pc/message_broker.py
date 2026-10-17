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
        elif 'write' in msg:
            self._robot.write(msg['write'])
        elif 'screenSize' in msg:
            width = msg['screenSize'][0]
            height = msg['screenSize'][1]
            self._robot.set_click_pos_scaler(width, height)
        elif 'tap' in msg:
            self._robot.click(msg['tap'][0], msg['tap'][1])
