Integration test module:
---

This Maven module comprises the integration test for the ticket checker.

The basic idea is that the jUnit tests spin up "docker-compose",
runs a set of tests accessing the docker instances, and shuts down 
"docker-compose" again.  

By doing this _inside_ the Java code instead of an external framework, 
we can keep the full flexibility of the Maven ecosystem even from
within IDE's and CI-engines as long as "docker-compose up" works.

Initial work done by ABR in the dvdripper project.


/tra 2017-09-20


