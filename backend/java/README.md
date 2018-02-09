Other than using the `webupd8team PPA` for installing Oracle JDK, one can also 
- Download jdk8 tarball from official source, e.g. [http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html). 
- Untar the tarball, e.g. "jdk-8u162-linux-x64.tar.gz".
  ```
  root@shell> tar -xvf  /absolute/path/to/jdk-8u162-linux-x64.tar.gz

  # Assume that the extracted root is /absolute/path/to/jdk1.8.0_162.
  ```
- Install the alternative for "/usr/bin/java" with name "java" and priority "100".  
  ```
  root@shell>  update-alternatives --install /usr/bin/java java /absolute/path/to/jdk1.8.0_162/bin/java 100
  ```
- Manually choose the new alternative for name "java".
  ```
  root@shell>  update-alternatives --config java
  ```
- _OPTIONAL_ To view syntax details.
  ```
  root@shell> man update-alternatives
  ```
- _OPTIONAL_ Try `ls -l /usr/bin/java` and then `ls -l /etc/alternatives/java` to see why it works on Ubuntu14.04.
- _OPTIONAL_ Repeat similar procedures for "javac", "javah" and "javap" etc. when necessary. 
