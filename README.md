# Author
w1gz


# Internship's reference
14-stage-ivy


# Challenges
The output of the perl scripts are formatted to be compatible with 80 columns terminals. I also
didn't resist and put a "few" quotes & references (film, web comics...).

In order to run those programs, you have two choices :

 * The normal way, by hand
 * Or by using the Dockerfile to setup the environment for you (especially the perl dependencies) :
    * `docker build -t quarks-env .`

## Challenge 1: Spiral
Scala is thirsty.

This spiral is written in Scala, however, it has been nicely package into a fat jar. This will allow
(almost) any Java Virtual Machine the ability to run it.


### Requirements (normal way)
**spiral.jar** dependency :

 * Just a recent JVM, for example, the version 8 was used during the development phase

### How to run
* Usage :
    * `java -jar spiral.jar <an_odd_number>`
* Normal way :
    * `java -jar spiral.jar 9`
* Docker way :
    * `docker run -it quarks-env java -jar /home/quarks/spiral.jar 9`


## Challenge 2 & 3: Beers
Perl is having a serious hangover.


### Requirements (normal way)
**choosemybeer.pl** has a few CPAN dependencies :

 * LWP::UserAgent, for dispatching web requests to api.openbeerdatabase.com
    * `cpan install LWP::UserAgent`
 * JSON, to parse the HttpResponses from openbeer
    * `cpan install JSON`
 * Text::ASCIITable, to print out nice tables
    * `cpan install Text::ASCIITable`


### How to run
 * Usage : `perl choosemybeer.pl <mode> <proxy:host>`
    * `<mode>` can be either `all` or `selection <beer_per_day>`
    * The `<proxy:host>` part is obviously optional
    * Some perl version will print warnings about experimental features, you can ignore them
 * Normal way :
    * `perl choosemybeer.pl all | less`
    * `perl choosemybeer.pl selection 3 proxy.quarks:3128`
 * Docker way :
    * `docker run -it quarks-env perl /home/quarks/choosemybeer.pl all
      proxy.quarks:3128 | less`
    * `docker run -it quarks-env perl /home/quarks/choosemybeer.pl selection 3`
