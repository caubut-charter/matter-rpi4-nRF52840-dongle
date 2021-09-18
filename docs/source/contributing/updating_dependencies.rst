.. _pull request: https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/compare

Updating Dependencies
=====================

General
-------

All updates should be done from upstream's main.

.. warning::

   Make sure any changes to main are saved in another branch or they will be lost.

::

   # change branch to main
   git checkout main
   # make local main the same as remote main (for the commit we are on locally)
   git reset --hard origin/main
   # update local main to match upstream's main
   git pull

Git Submodules
--------------

#. Create a new branch.

   ::

      # remove last update branch
      git branch -d chore/update-dependencies

      # create new update branch
      git checkout -b chore/update-dependencies

#. Update each submodule from their upstream.

   ::

      scripts/update-submodules.sh

#. Commit the changes.

   ::

      git commit -am 'chore: update submodule dependencies'

#. Push the changes upstream.

   ::

      git push origin chore/update-submodule-dependencies

#. Make a `pull request`_.

Conventional Commits
--------------------

#. Create a new branch.

   ::

      # remove last update branch
      git branch -d chore/update-conventional-commit-dependencies

      # create new update branch
      git checkout -b chore/update-conventional-commit-dependencies

#. Check for outdated dependencies.

   ::

      npm outdated

#. Install the :code:`npm-check-updates` package from :code:`dev-dependencies`.

   ::

      npm install

#. Run :code:`npm-check-updates` to edit the :code:`package.json` file with the latest releases.

   ::

      ncu -u

#. Install the updated dependencies.

   ::

      npm update

#. Commit the changes.

   ::

      git add package.json package-lock.json
      git commit -m 'chore: update conventional commit dependencies'

#. Push the changes upstream.

   ::

      git push origin chore/update-conventional-commit-dependencies

#. Make a `pull request`_.

Documentation
-------------

#. Create a new branch.

   ::

      # remove last update branch
      git branch -d chore/update-documentation-dependencies

      # create new update branch
      git checkout -b chore/update-documentation-dependencies

#. Check for outdated dependencies.

   ::

      poetry show --outdated

#. Install the updated dependencies.

   ::

      poetry update

#. Recheck outdated dependencies.  Updates outside of the allowed SemVer for a package in the :code:`pyproject.toml` will require editing the SemVer's for those dependencies and updating the dependencies again.

   ::

      poetry show --outdated

      # rerun after editing pyproject.toml
      poetry update

#. Stop the documentation web-server if running.

   ::

      docker container stop matter-example-docs

#. Pull the latest version of the web-server.

   ::

      docker pull nginx:alpine

#. Rebuild the documentation.

   ::

      poetry run make clean -C docs && poetry run make -C docs html

#. Restart the web-server.

   ::

      docker run -it --rm --name=matter-example-docs \
       -v $PWD/docs/build/html:/usr/share/nginx/html:ro \
       -p 8888:80 \
       -d nginx:alpine

#. Commit the changes.

   ::

      git add pyproject.toml poetry.lock
      git commit -m 'chore: update documentation dependencies'

#. Push the changes upstream.

   ::

      git push origin chore/update-documentation-dependencies

#. Make a `pull request`_.
