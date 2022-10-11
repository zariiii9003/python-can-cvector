import os
import platform
from pathlib import Path

from setuptools import Extension, setup
import Cython.Build
import Cython.Compiler.Options

Cython.Compiler.Options.annotate = True

distribution_pkg_name = "python-can-cvector"
import_pkg_name = "can_cvector"
pkg_dir = Path("src") / import_pkg_name


if not os.getenv("VXLAPI_DIR"):
    raise RuntimeError("Environment variable VXLAPI_DIR not set.")


ext_modules = Cython.Build.cythonize(
    module_list=[
        Extension(
            name=f"{import_pkg_name}._abstraction",
            sources=[str(pkg_dir / "_abstraction.pyx")],
            libraries=[
                "vxlapi64" if platform.architecture()[0] == "64bit" else "vxlapi"
            ],
            include_dirs=[os.getenv("VXLAPI_DIR")],
            library_dirs=[os.getenv("VXLAPI_DIR")],
        ),
    ],
    compiler_directives={
        "language_level": 3,
    },
)

setup(
    ext_modules=ext_modules,
)
