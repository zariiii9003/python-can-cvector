import os
import platform
from pathlib import Path

from setuptools import Extension, setup, find_packages
import Cython.Build
import Cython.Compiler.Options

Cython.Compiler.Options.annotate = True

distribution_pkg_name = "python-can-cvector"
import_pkg_name = "can_cvector"
pkg_dir = Path("src") / import_pkg_name

# read version
with open(pkg_dir / "__init__.py") as f:
    for line in f:
        if line.startswith("__version__"):
            version = line.split("=")[-1].strip().strip('"')
            break


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

package_data = {import_pkg_name: ["py.typed", "*.pyi"]}
install_requires = ["python-can==4.0.*"]

setup(
    name=distribution_pkg_name,
    author="Artur Drogunow",
    author_email="artur.drogunow@zf.com",
    version=version,
    license="LGPL v3",
    packages=find_packages("src"),
    package_dir={"": "src"},
    package_data=package_data,
    python_requires=">=3.7",
    ext_modules=ext_modules,
    zip_safe=False,
    install_requires=install_requires,
    entry_points={
        "can.interface": [
            f"cvector={import_pkg_name}.cvector:CVectorBus",
        ]
    },
)
