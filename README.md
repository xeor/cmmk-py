# cmmk-py

This is a wrapper around https://github.com/chmod222/libcmmk so you can change the keyboard-colors from python code.
It is using cython, and it is fairly fast.

## Installation

TODO

## Support

Note that this wrapper is currently scoped mostly for sk650 and a scandinavian layout.
It might work on other models as well, it should. But please submit pull-requests if you want something.

## Usage

```py
from cmmk import CMMK

kb = CMMK()

# Manual control keyboard colors (not via it's firmware)
kb.mode('manual')

# Set a single key to red
kb.key('a', 'red')

# Set 3 keys to a dark purple (r, g, b)
kb.key('esc space o', (100, 0, 100))

# Set a-z to blue with a delay
import string
kb.key(
    ' '.join([i for i in string.ascii_lowercase]),
    'blue', delay=0.1
)

# Set a x-mas theme
import string, random
kb.key(
    ' '.join([i for i in string.ascii_lowercase]),
    lambda row, col: random.choice(['red', 'green'])
)

```