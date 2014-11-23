FROM debian:stable
MAINTAINER w1gz

# Install prerequisites from debian repos
RUN apt-get update
RUN apt-get install -y perl-modules curl gcc binutils make
RUN apt-get install -y openjdk-7-jre

# Install perl CPAN modules
RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm install JSON LWP::UserAgent Text::ASCIITable

# Prepare the working directory
RUN mkdir -p /home/quarks/scala_src-and-tools
ADD choosemybeer.pl spiral.jar /home/quarks/
ADD scala_src-and-tools/ /home/quarks/scala_src-and-tools/
