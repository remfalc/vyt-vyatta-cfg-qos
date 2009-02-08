# This is a wrapper around Token Bucket Filter (TBF) queue discipline
#
#
# **** License ****
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# This code was originally developed by Vyatta, Inc.
# Portions created by Vyatta are Copyright (C) 2008 Vyatta, Inc.
# All Rights Reserved.
# **** End License ****

package Vyatta::Qos::RateLimiter;

use strict;
use warnings;

use Vyatta::Config;
use Vyatta::Qos::Util qw/getRate getTime/;

my %fields = (
    _rate	=> undef,
    _burst	=> undef,
    _latency	=> undef,
);

sub new {
    my ( $that, $config ) = @_;
    my $level = $config->setLevel();
    my $class = ref($that) || $that;
    my $self = {%fields};

    $self->{_rate} = getRate($config->returnValue("bandwidth"));
    defined $self->{_rate}  or die "$level bandwidth not defined\n";

    $self->{_burst}     = $config->returnValue("burst");
    defined $self->{_burst}  or die "$level burst not defined\n";

    $self->{_latency} = getTime($config->returnValue("latency"));
    defined $self->{_latency}  or die "$level latency not defined\n";

    return bless $self, $class;
}

sub commands {
    my ( $self, $out, $dev ) = @_;

    
    printf {$out} "qdisc add dev %s root tbf rate %s latency %s burst %s\n",
	    $dev, $self->{_rate}, $self->{_latency}, $self->{_burst};
}

sub isChanged {
    my ($self, $name) = @_;
    my $config = new Vyatta::Config;

    $config->setLevel("qos-policy rate-limit $name");
    foreach my $attr ('bandwidth', 'burst', 'latency') {
	return $attr if ($config->isChanged($attr));
    }
    return; # false
}

1;