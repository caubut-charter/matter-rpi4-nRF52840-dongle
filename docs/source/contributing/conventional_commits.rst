.. _Conventional Commits: https://www.conventionalcommits.org/en/v1.0.0/#summary
.. _NodeJS: https://nodejs.org/

Conventional Commits
====================

This project uses `Conventional Commits`_.  For an interactive commit message form, use :code:`git cz` as a drop in replacement for :code:`git commit`.  If :code:`git commit` is preferred, a git-hook to lint the message can be used.  Both tools require NodeJS_ and :code:`node_modules/.bin` will need to be in the shell's path.

::

   npm install --production
   husky install
   npx husky add .husky/commit-msg "npx --no-install commitlint --edit $1"
