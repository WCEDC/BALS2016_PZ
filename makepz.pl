#!/usr/bin/env perl
use strict;
use warnings;

my $net = "A1";
my $loc = "01";
my $dir = "pzfiles";
mkdir $dir;
open (OUT, "> $dir/PZ.ALL") or die;
open (IN, "<  BBstations_model.txt") or die;
foreach (<IN>) {
    next if ($_ =~ '#');
    chomp;
    # BBSX|2016-11-22T09:24:42|2018-01-27T10:08:01|Eentec_EP-300_120s|Eentec_DR4050P
    my ($sta, $start, $end, $sensor, $logger) = split m/\|/;
    my ($resp_sensor, $resp_logger);
    open (RESP, "< model-resp.txt") or die;
    foreach (<RESP>) {
        #Eentec_EP-300_120s RESP.XX.NS184..BHZ.EP300.120.2000
        my @info = split m/\s+/;
        $resp_sensor = $info[1] if ($sensor eq $info[0]);
        $resp_logger = $info[1] if ($logger eq $info[0]);
    }
    close(RESP);
    my @zeros;
    my @poles;
    my $a0;
    my $sens_sensor;
    my $sens_logger;
    open(SENSOR, "< $resp_sensor") or die;
    foreach (<SENSOR>) {
        chop;
        my @info = split m/\s+/;
        push @zeros, "\t$info[2]\t$info[3]" if ($info[0] eq "B053F10-13");
        push @poles, "\t$info[2]\t$info[3]" if ($info[0] eq "B053F15-18");
        $a0 = $info[4] if ($info[0] eq "B053F07");
        $sens_sensor = $info[2] if (($info[0] eq "B058F04") and ($info[1] eq "Sensitivity:"));
    }
    close(SENSOR);
    push @zeros, "\t0.000000e+00\t0.000000e+00\n";
    open(LOGGER, "< $resp_logger") or die;
    foreach (<LOGGER>) {
        chop;
        my @info = split m/\s+/;
        $sens_logger = $info[2] if (($info[0] eq "B058F04") and ($info[1] eq "Sensitivity:"));
    }
    close(LOGGER);
    my $constant = $a0 * $sens_sensor * $sens_logger;
    foreach my $chn ("BHE", "BHN", "BHZ") {
        my @out;
        push @out, "* **********************************";
        push @out, "** NETWORK   (KNETWK): $net";
        push @out, "** STATION    (KSTNM): $sta";
        push @out, "** LOCATION   (KHOLE): $loc";
        push @out, "** CHANNEL   (KCMPNM): $chn";
        push @out, "** CREATED           : 2019-10-10T10:10:10";
        push @out, "** START             : $start";
        push @out, "** END               : $end";
        push @out, "** DESCRIPTION       : $resp_sensor/$resp_logger";
        push @out, "** LATITUDE          : -12345";
        push @out, "** LONGITUDE         : -12345";
        push @out, "** ELEVATION         : -12345";
        push @out, "** DEPTH             : -12345";
        push @out, "** DIP               : -12345";
        push @out, "** AZIMUTH           : -12345";
        push @out, "** SAMPLE RATE       : -12345";
        push @out, "** INPUT UNIT        : -12345";
        push @out, "** OUTPUT UNIT       : -12345";
        push @out, "** INSTTYPE          : -12345";
        push @out, "** INSTGAIN          : -12345";
        push @out, "** COMMENT           : -12345";
        push @out, "** SENSITIVITY       : -12345";
        push @out, "** A0                : $a0";
        push @out, "** **********************************";
        my $i = @zeros;
        push @out, "ZEROS	$i";
        foreach (@zeros) {
            push @out, "$_";
        }
        my $j = @poles;
        push @out, "POLES	$j";
        foreach (@poles) {
            push @out, "$_";
        }
        push @out, "CONSTANT	$constant";
        open (OUT1, "> $dir/PZ.$net.$sta.$loc.$chn");
        foreach (@out) {
            print OUT "$_\n";
            print OUT1 "$_\n";
        }
        close(OUT1);
    }
}
close(OUT);
