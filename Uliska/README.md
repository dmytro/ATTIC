# @title Uliska Overview


DEPRECATION: THere are way too many inventory scanners to support yet another one:

- [Ohai](http://docs.opscode.com/ohai.html)
- [GLPI](http://www.glpi-project.org/spip.php?lang=en)
- [Facter](http://puppetlabs.com/facter)

# Name

Uliska - UNIX, Linux Inventory and Configuration Scanner

## Development principles

### [Scanner](./file.ScannerOverview.html)

* Modular, extendable

* Understable - aimed primarily at UNIX SA's

  * Simple format for commands list file

* Requires minimum deployment to clients Basically that means Perl with no extra modules. Perl is installed by default on most current Unices, to avoid any extra installations try to write Perl code with as least requirements as possible.

* Light - ability to run from cron or inetd

  * Must take little CPU, memory and disk resources when run and stores data. Very little intelligence on the client side, most parsing done by server. Simply run sequence of UNIX commands and capture output into YAML file.

  * Print out either to file of STDOUT.

* Support multiple OSes by adding modules/list of commands


### [Parser](./file.ParserOverview.html)

* Modular, extendable parsers - using factories

* Parse into data structure for web services API for submission

### Viewer

See http://dmytro.github.com/Ulivie

TBD



## Who

Dmytro Kovalov, dmytro.kovalov@gmail.com, started in Jan, 2012.
 
