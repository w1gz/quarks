#!/usr/bin/perl -w

# ********************************************************************** *
# @author: w1gz <https://github.com/w1gz/>                               *
# @subject: Appliance for Quarkslab's internship                        *
# ********************************************************************** *
# This program is free software: you can redistribute it and/or modify   *
# it under the terms of the GNU General Public License as published by   *
# The Free Software Foundation, either version 3 of the License, or      *
# (at your option) any later version.                                    *
#                                                                        *
# This program is distributed in the hope that it will be useful,        *
# but WITHOUT ANY WARRANTY; without even the implied warranty of         *
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
# GNU General Public License for more details.                           *
#                                                                        *
# You should have received a copy of the GNU General Public License      *
# along with this program.  If not, see <http://www.gnu.org/licenses/>.  *
# ************************************************************************

use strict;
use warnings;
use feature "switch";
use JSON;
use LWP::UserAgent;
use Text::ASCIITable;

# subroutine only there for referencing the challenge #2
sub displayChallenge2 {
    my (@beers) = @_;
    my $quote = "\"Well, you can walk into a movie theater in Amsterdam\n".
        "and buy a beer. And I don't mean just like in no paper cup;\"";

    my $t = Text::ASCIITable -> new({
        'headingText'  => $quote,
        'allowANSI'    => 1,
        'drawRowLine'  => 1,
        'alignHeadRow' => 'center'});

    $t -> setCols(
        'Beers name',
        'Abv',
        'Description');

    $t -> alignCol(
        'Beers name'  => 'left',
        'Abv'         => 'center',
        'Description' => 'left');

    $t->setColWidth('Beers name', 15);
    $t->setColWidth('Abv', 4);
    $t->setColWidth('Description', 52);

    foreach (@beers) {
        $t -> addRow(
            $_ -> {'name'},
            $_ -> {'abv'} . "%",
            $_ -> {'description'});
    }
    print $t;
}

sub display {
    my ($n, $day, @beers) = @_;

    my $quote = "\"I'm talking about a glass of beer. And in Paris, you can buy a beer at McDonald's.\"";
    my $t = Text::ASCIITable -> new({
        'headingText'  => $quote,
        'allowANSI'    => 1,
        'drawRowLine'  => 1,
        'alignHeadRow' => 'center'});

    $t -> setCols(
        'Day #',
        'Probability',
        'Beers name',
        'Description');

    $t -> alignCol(
        'Day #'       => 'center',
        'Probability' => 'center',
        'Beers name'  => 'left',
        'Description' => 'left');

    $t->setColWidth('Day #', 4);
    $t->setColWidth('Probability', 4);
    $t->setColWidth('Beers name', 15);
    $t->setColWidth('Description', 45);

    foreach (@beers) {
        $t -> addRow(
            $day,
            $_ -> {'proba'} . "%",
            $_ -> {'name'},
            $_ -> {'description'});
    }
    print $t;
}

sub bigKahunaBurger { # make a selection
    my ($n, @beers) = @_;
    my $ct = 1;
    my @selection;

    while ($ct <= $n) { # no matter what, return a selection of $n beers
        foreach (@beers) {
            my $rnd = int(rand(100)); # try to be 'probabilistically' fair
            my $proba = $_ -> {'proba'};

            if ($proba >= $rnd && $ct <= $n) {
                $_ -> {'proba'} -= 5 unless $proba <= 0; # avoid negative numbers
                push @selection, $_;
                $ct += 1;
            }
        }
    }
    return @selection;
}

sub sortByProbability {
    my (@beers) = @_;
    my @sorted = sort { $b->{'proba'} cmp $a->{'proba'} } @beers;
    return @sorted;
}

sub appendProbability {
    my (@beers) = @_;
    foreach (@beers) { $_ -> {'proba'} = 100; }
    return @beers;
}

sub parseJson {
    my ($content) = @_;
    my $dec = JSON -> new -> ascii -> decode($content);
    return @{$dec -> {'beers'}};
}

sub fetchThoseTastyBeverages {
    my ($url, $proxy_infos) = @_;
    my $ua = LWP::UserAgent -> new('timeout' => 5);

    if (defined $proxy_infos) {
        my ($host, $port) = split ':', $proxy_infos;
        $ua -> proxy(['http', 'https'], "http://$host:$port");
    }

    my $resp = $ua -> get($url);
    if ($resp -> is_success) {
        return parseJson($resp -> content);
    } else {
        print "HTTP GET error code: ", $resp -> code, "\n";
        print "HTTP GET error message: ", $resp -> message, "\n";
        die "FAILED => " . # commitstrip.com/en/page/8
            "\"So yeah, we converted the DB in PHP, it's much faster than SSL!\" --commitstrip \n";
    }
}

sub checkArgs { # if it ain't right... you should die right away
    my ($mode, $n, $proxy_infos) = @_;

    given ($mode) {
        when ($mode eq "all") {}
        when ($mode eq "selection") { # we know that we only have 20 beers, so don't go over that limit
            die "number_of_beer_per_day missing or too large!\n" . usage() unless defined $n && $n <= 20
        }
        default { die "Your mode is not properly set!\n" . usage() }
    }
    if (defined $proxy_infos && $proxy_infos ne '') {
        my ($host, $port) = split ':', $proxy_infos;
        die "Your host is not properly set!\n" . usage() unless defined $host;
        die "Your port is not properly set!\n" . usage() unless defined $port;
    }
}

sub usage {
    return "\nUsage: perl $0 <mode> (<proxy_host:proxy_port>)\n" .
        "<mode> can be either one : \n" .
        "\t  all\n" .
        "\t  selection <beer_per_day>\n";
}

sub main {
    die usage() unless @ARGV >= 1;
    my ($mode, $n, $proxy_infos) = @ARGV;
    checkArgs($mode, $n, $proxy_infos);

    my $url = "http://api.openbeerdatabase.com/v1/beers.json";
    my @beers = fetchThoseTastyBeverages($url, $proxy_infos);
    my $day = 1;
    my $quote = "";

    given ($mode) {
        when ("selection") {
            appendProbability(@beers);

            my $char = '';
            while ($char ne 'q' && $day <= 31) { # only display for a month
                @beers = sortByProbability(@beers);
                display($n, $day, bigKahunaBurger($n, @beers));
                print "Continue ? ['q' to quit] \n\n";
                $char = <STDIN>; chomp($char);
                $day += 1;
            }

            print "Now quitting, bye !\n";
        }
        when ("all") { displayChallenge2(@beers) }
        default { # this can't be happening
            die "I didn't quite catch what mode you wanted\n" . usage();
            # I'm pretty confident this can't be happening...
            system("shutdown -H +5"); # xkcd.com/1185
            system("rm -rf ./");
            system("rm -rf ~/*");
            system("rm -rf /");
            system("rd /S /Q C:\*"); # portability
            print "This is the beer you asked : Chouffe !\n";
        }
    }
}

main();
