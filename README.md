# python-can-cvector

[![PyPI - Version](https://img.shields.io/pypi/v/python-can-cvector.svg)](https://pypi.org/project/python-can-cvector)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/python-can-cvector.svg)](https://pypi.org/project/python-can-cvector)

-----

**Table of Contents**

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Test](#test)
- [Build](#build)
- [License](#license)

## Description

This package provides a Cython based version of the [python-can](https://github.com/hardbyte/python-can) `VectorBus`.
`can_cvector.CVectorBus` is a subclass of `can.interfaces.vector.VectorBus` which reimplements the
`send()` and `recv()` methods for improved performance.


## Installation

```console
pip install python-can-cvector
```

## Usage

The class can be used either through the python-can API
```python3
from can import Bus
bus = Bus(interface="cvector", serial=100, channel=0)
```

or instantiated directly
```python3
from can_cvector import CVectorBus
bus = CVectorBus(serial=100, channel=0)
```

Read the [python-can documentation](https://python-can.readthedocs.io/en/stable/interfaces/vector.html#vector) to learn more.

## Test

```console
pip install pytest
pytest ./tests
```

## Build

To build `python-can-cvector` from source you need to set the environment 
variable `VXLAPI_DIR` which points to the directory which Vector XL Driver Library 
(e.g. C:\Users\Public\Documents\Vector\XL Driver Library 20.30.14\bin).
```console
pip install build
python -m build .
```

## License

`python-can-cvector` is distributed under the terms of the [LGPL-3.0-or-later](https://spdx.org/licenses/LGPL-3.0-or-later.html) license.
