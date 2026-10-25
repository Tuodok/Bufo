import pyautogui

class Robot:

   
    
    def __init__(self):
        self._screenWidth = pyautogui.size()[0]
        self._screenHeight = pyautogui.size()[1]
        self._clickWidthScaler = None
        self._clickHeightScaler = None
        self._modifier_keys = ['ctrl', 'shift', 'alt', 'altright', 'win']
        self._active_modifier_keys = []

    def set_click_pos_scaler(self, clientWidth, clientHeight):
        self._clickWidthScaler = self._screenWidth / clientWidth
        self._clickHeightScaler = self._screenHeight / clientHeight
    
    def click(self, pos_x, pos_y):
        print('clickig')
        pyautogui.click(pos_x * self._clickWidthScaler, pos_y * self._clickHeightScaler)


    def key_press(self, key):
        if key in self._modifier_keys:
            if key not in self._active_modifier_keys:
                self._active_modifier_keys.append(key)
            else:
                self._active_modifier_keys.remove(key)
            return

        for active_modifier in  self._active_modifier_keys:
            pyautogui.keyDown(active_modifier)

        pyautogui.press(key)

        for active_modifier in self._active_modifier_keys:
            pyautogui.keyUp(active_modifier)

    def write(self, text):
        pyautogui.write(text)