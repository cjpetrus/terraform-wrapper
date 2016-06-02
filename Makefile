.PHONY: build

init:
	pip install -r requirements.txt

build:
	python setup.py sdist bdist_wheel
