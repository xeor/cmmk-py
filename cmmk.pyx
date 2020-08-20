import time
from typing import List

cdef extern from "libcmmk/libcmmk.h":
    int cmmk_find_device(int *product)
    int cmmk_attach(cmmk *dev, int product, int layout)
    int cmmk_set_control_mode(cmmk *dev, int mode)
    int cmmk_set_single_key(cmmk *dev, int row, int col, rgb *color)

    cpdef enum cmmk_control_mode:
        CMMK_FIRMWARE
        CMMK_EFFECT
        CMMK_MANUAL
        CMMK_PROFILE_CUSTOMIZATION

    struct cmmk:
        pass

    struct rgb:
        unsigned char R
        unsigned char G
        unsigned char B

cdef cmmk state
cdef int product

cdef connect():
    cmmk_find_device(&product)
    cmmk_attach(&state, product, -1)

cdef set_single_key(int r, int g, int b, int row, int col):
    cdef rgb color = rgb(r, g, b)
    cmmk_set_single_key(&state, row, col, &color)


class InvalidEnumError(Exception):
    pass

class InvalidColorError(Exception):
    pass

cdef class CMMK:
    enums = {}

    # Only one for now..
    keylayout = 'sk650_eu_no'

    keymap = {
        'sk650_eu_no': {
            'esc': (0,0),
            'f1': (0,1), 'f2': (0,2), 'f3': (0,3), 'f4': (0,4), 'f5': (0,6), 'f6': (0,7),
            'f7': (0,8), 'f8': (0,9), 'f9': (0,11), 'f10': (0,12), 'f11': (0,13), 'f12': (0,14),
            'prtsc': (0, 15), 'scrlk': (0, 16), 'pause': (0, 17),

            '|': (1, 0),
            '1': (1,1), '2': (1, 2), '3': (1, 3), '4': (1, 4), '5': (1, 5), '6': (1, 6),
            '7': (1,7), '8': (1, 8), '9': (1, 9), '0': (1, 10), '+': (1, 11), '\\': (1, 12),
            'backspace': (1, 14), 'ins': (1,15), 'home': (1,16), 'pgup': (1,17),

            'tab': (2,0), 'q': (2,1), 'w': (2,2), 'e': (2,3), 'r': (2,4), 't': (2,5), 'y': (2,6),
            'u': (2,7), 'i': (2,8), 'o': (2,9), 'p': (2,10), 'å': (2,11), '^': (2,12), 'enter': (2,14), 'del': (2,15),
            'end': (2,16), 'pgdn': (2,17),
            
            'capslk': (3,0), 'a': (3,1), 's': (3,2), 'd': (3,3), 'f': (3,4), 'g': (3,5), 'h': (3,6), 'j': (3,7),
            'k': (3,8), 'l': (3,9), 'ø': (3,10), 'æ': (3,11), '\'': (3,12),
            
            'lshift': (4,0), '<': (4,1), 'z': (4,2), 'x': (4,3), 'c': (4,4), 'v': (4,5), 'b': (4,6), 'n': (4,7), 'm': (4,8), ',': (4,9), 
            '.': (4,10), '-': (4,11), 'rshift': (4,14), 'up': (4,16),
            
            'lctrl': (5,0), 'lwin': (5,1), 'lalt': (5,2), 'space': (5,6), 'ralt': (5,10), 'rwin': (5,1),
            'cm': (5,12), 'rctrl': (5,14), 'left': (5,15), 'down': (5,16), 'right': (5,17)
        }
    }

    def __init__(self):
        self.enums['cmmk_control_mode'] = cmmk_control_mode

        connect()

    def _get_enum(self, enumname: str, param):
        enumname = 'cmmk_' + enumname
        paramname = 'CMMK_' + param.upper().replace('-', '_')

        try:
            enum = self.enums[enumname]
        except KeyError:
            valid_enums = ', '.join([i.replace('cmmk_', '', 1) for i in self.enums.keys()])
            raise InvalidEnumError(f'No enums defined with name {enumname}. Valid enums are "{valid_enums}", but you need the correct one. See docs')

        try:
            param = enum[paramname]
        except KeyError:
            valid_params = ', '.join([i.replace('CMMK_', '', 1).replace('_', '-').lower() for i in enum.keys()])
            raise InvalidEnumError(f'No parameter found with name {paramname} on enum {enumname}. Valid params are "{valid_params}". See docs for details')

        return param.value

    def _get_rgb(self, color):
        if isinstance(color, str):
            colormap = {
                'red': (255, 0, 0),
                'green': (0, 255, 0),
                'blue': (0, 0, 255)
            }
            color = colormap.get(color)
            if not color:
                valid_colors = ', '.join(colormap.keys())
                raise InvalidColorError(f'No color named {color}. Valid colors are: {valid_colors}')

        return color[0], color[1], color[2]

    def _get_keys(self, key):
        if isinstance(key, str):
            keys = key.split(' ')
            return [self.keymap[self.keylayout][k] for k in keys]
        elif isinstance(key, tuple):
            return [key]
        elif isinstance(key, list):
            return key

    def mode(self, mode):
        """
        mode:
            firmware: Firmware controls everything
            effect: Firmware controlled effect, configured via software
            manual: Manual control of everything
            profile-customization: Profile setup (may actually be a misnomer, as saving the profile works in effect mode as well
        """
        cmmk_set_control_mode(
            &state,
            self._get_enum('control_mode', mode)
        )

    def key(self, key, color, delay=None):
        r, g, b = self._get_rgb(color)

        for k in self._get_keys(key):
            if delay:
                time.sleep(delay)
            set_single_key(r, g, b, k[0], k[1])
