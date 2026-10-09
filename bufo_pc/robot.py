import pyautogui

class Robot:

    _modifier_keys = ['ctrl', 'shift', 'alt', 'altright', 'win']
    _active_modifier_keys = []

    def click(self, pos_x, pos_y):
        print(f'clicking at: {pos_x}, {pos_y}')
        pyautogui.click(pos_x, pos_y)


    def key_press(self, key):
        print('key: {key}')
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