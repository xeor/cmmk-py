LIB_DIR = lib

default: cmmk-py

cmmk-py: setup.py cmmk.pyx
	python3 setup.py build_ext --inplace

wheel: setup.py cmmk.pyx
	python3 setup.py bdist_wheel


clean:
	rm *.so
	rm -f cmmk.c
	rm -Rf build
