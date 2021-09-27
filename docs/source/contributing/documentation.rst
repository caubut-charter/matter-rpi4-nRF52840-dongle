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

.. tabs::

   .. tab:: HTTP

      ::

         docker run -it --rm --name=matter-example-docs \
          -v $PWD/docs/build/html:/usr/share/nginx/html:ro \
          -p 8888:80 \
          -d nginx:alpine

   .. tab:: HTTPS (Let's Encrypt)

      ::

         sudo certbot certonly --nginx

         export MATTER_EXAMPLE_DOCS_FQDN=<fqdn>

         cat << EOF > nginx.conf
         server {
           listen 443 ssl;
           server_name ${MATTER_EXAMPLE_DOCS_FQDN};
           ssl_certificate /etc/nginx/certs/fullchain.pem;
           ssl_certificate_key /etc/nginx/certs/privkey.pem;
         }
         EOF

         sudo cp -rL /etc/letsencrypt/live/${MATTER_EXAMPLE_DOCS_FQDN} certs

         docker run -it --name=matter-example-docs \
          -v $PWD/docs/build/html:/etc/nginx/html:ro \
          -v $PWD/nginx.conf:/etc/nginx/conf.d/nginx.conf \
          -v $PWD/certs:/etc/nginx/certs \
          -p 8888:443 \
          -d nginx:alpine

Regenerating the Documentation
------------------------------

Incremental updates can be built using the same command as generating the documentation.

::

   poetry run make -C docs html

Cleaning the build directory will break the docker volume and requires restarting the web server container.

::

   poetry run make clean -C docs && poetry run make -C docs html && docker restart matter-example-docs

Stopping the Web Server
-----------------------

Stopping the container will automatically remove it.

::

   docker container stop matter-example-docs
