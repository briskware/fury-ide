# fury-ide

*fury-ide* is an attempt to construct a [Fury](http://fury.build/) IDE environment.

As it stands, the project source is fragmented across tens of "micro-libraries" and other tools, and there is
no build framework available. Furthermore, the circular references and the directory structure does not allow
for easy dependency management between components, e.g. source package directories are arbitrarily named and don't
follow the actual package naming conventions, which is somewhat mandated by the JVM ecosystem.

The included [clone.sh](./clone.sh) script downloads and links all necessary project artifacts from
[Propensive](https://github.com/propensive)'s Github, with other dependencies from Maven, etc. so the project can be
built from within a single context, e.g. via an IDE.

To get this to work e.g. in IDEA, after you have run the *clone.sh* script, set up your project as follows:
* import the two JARs from fury-libs folder
* create a module for nailgun, set the src/main/java as a source route, make sure the above two libraries are set as dependencies
* create a module for fury-build, set the src/main/scala as your source route and src/test/scala as the test root; set the nailgun module as a dependent.
