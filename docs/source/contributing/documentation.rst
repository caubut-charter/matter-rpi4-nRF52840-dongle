.. _Sphinx: https://www.sphinx-doc.org/
.. _Python>=3.6: https://www.python.org/
.. _Poetry: https://python-poetry.org/

Documentation
=============

Documentation for this project is built using Sphinx_ which requires `Python>=3.6`_ and the Poetry_ package manager.  This process is handled by the CI/CD pipeline, but the documentation can be built locally and previewed at http://localhost:8888 using docker.

Environment Setup
-----------------

::

   poetry install

Generating the Documentation
----------------------------

::

   poetry run make -C docs html

Starting the Web Server
-----------------------

::

   docker run -it --rm --name=matter-example-docs \
    -v $PWD/docs/build/html:/usr/share/nginx/html:ro \
    -p 8888:80 \
    -d nginx:alpine

Regenerating the Documentation
------------------------------

Cleaning the build directory will break the docker volume and requires restarting the web server container.

::

   poetry run make clean -C docs && poetry run make -C docs html && docker restart matter-example-docs

Stopping the Web Server
-----------------------

Stopping the container will automatically remove it.

::

   docker container stop matter-example-docs
