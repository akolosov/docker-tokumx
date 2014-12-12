Introduction
============

Docker container for TokuMX 2.x.x with ability to form cluster


Usage
=====

Uses the ability in recent Docker versions to set up hosts entries to locate a node to cluster with. For
convenience sake, the node is named master.


Run 
---

`docker run -d -h tokumx --name tokumx -p 27017:27017 akolosov/tokumx <tokumx options>`
