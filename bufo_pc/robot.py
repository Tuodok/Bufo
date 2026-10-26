import pyautogui

class Robot:
    
    def __init__(self):
        self.screenWidth = pyautogui.size()[0]
        self.screenHeight = pyautogui.size()[1]
        self._modifier_keys = ['ctrl', 'shift', 'alt', 'altright', 'win']
        self._active_modifier_keys = []

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