from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

examples_extension = Extension(
    name="cmmk",
    sources=["cmmk.pyx"],
    libraries=["cmmk", "hidapi-hidraw"],
    include_dirs=["/usr/lib"],
)
setup(
    name="cmmk",
    ext_modules=cythonize(
        [examples_extension],
        compiler_directives={'language_level' : "3"},
        annotate=True
    )
)
