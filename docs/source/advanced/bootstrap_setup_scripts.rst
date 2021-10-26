.. _GitHub's Scripts to Rule Them All convention: https://github.com/github/scripts-to-rule-them-all
.. _container images: https://hub.docker.com/u/caubutcharter
.. _build artifacts: https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/releases/tag/nightly

.. _Bootstrap / Setup Usage Guide:

Bootstrap / Setup Usage Guide
=============================

The :code:`bootstrap` and :code:`setup` scripts follow `GitHub's Scripts to Rule Them All convention`_.  Both include a help menu which prints available dependency/artifact flags.

::

   script/bootstrap -h
   script/setup -h

It is not always necessary to rebuild the entire dependency chain to rebuild a specific artifact.  For instance, rebuilding the thread lighting app should not require rebuilding the build-tool container images.

   ::

     # example: only rebuild chip-device-ctrl and thread-lighting-app from the latest version of CHIP
     script/bootstrap --chip
     script/setup --nrf52840-dongle-thread-lighting-app --chip-device-ctrl

Direct downloads are also available for `container images`_ and various `build artifacts`_.  The following dependency graph specifies the prerequisites for each artifact.

   .. image:: ../_static/dependency_graph.png
      :align: center
