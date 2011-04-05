#!/usr/bin/perl
#
#  Copyright (c) 2011 Opera Software Australia Pty. Ltd.  All rights
#  reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3. The name "Opera Software Australia" must not be used to
#     endorse or promote products derived from this software without
#     prior written permission. For permission or any legal
#     details, please contact
# 	Opera Software Australia Pty. Ltd.
# 	Level 50, 120 Collins St
# 	Melbourne 3000
# 	Victoria
# 	Australia
#
#  4. Redistributions of any form whatsoever must retain the following
#     acknowledgment:
#     "This product includes software developed by Opera Software
#     Australia Pty. Ltd."
#
#  OPERA SOFTWARE AUSTRALIA DISCLAIMS ALL WARRANTIES WITH REGARD TO
#  THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS, IN NO EVENT SHALL OPERA SOFTWARE AUSTRALIA BE LIABLE
#  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
#  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
#  OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

package Cassandane::ThreadedGenerator;
use strict;
use warnings;
use base qw(Cassandane::Generator);
use Cassandane::Address;
use Cassandane::Message;
use Cassandane::Util::Log;
use Cassandane::Util::Words;

my $NTHREADS = 5;
my $NMESSAGES = 20 * $NTHREADS;
my $DELTAT = 300;   # seconds
my $FINISH_CHANCE = 0.08;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{nmessages} = $NMESSAGES;
    $self->{deltat} = $DELTAT;

    $self->{threads} = [];
    for (my $i = 1 ; $i <= $NTHREADS ; $i++)
    {
	my $thread =
	{
	    id => $i,
	    subject => ucfirst(random_word()) . " " . random_word(),
	    last_message => undef,
	};
	push(@{$self->{threads}}, $thread);
    }

    $self->{next_date} = DateTime->now->epoch -
		    $self->{deltat} * ($self->{nmessages}+1);

    return $self;
}

sub _choose_thread
{
    my ($self) = @_;

    my $i = int(rand(scalar(@{$self->{threads}})));
    my $thread = $self->{threads}->[$i];

    my $dice = rand;
    if ($dice <= $FINISH_CHANCE)
    {
	# detach from the generator...we won't find it again
	splice(@{$self->{threads}}, $i, 1);
    }

    return $thread;
}

#
# Generate a single email.
# Args: Generator, (param-key => param-value ... )
# Returns: Message ref
#
sub generate
{
    my ($self, %params) = @_;

    return undef
	if (!$self->{nmessages});

    my $thread = $self->_choose_thread();
    return undef
	if (!defined $thread);

    my $last = $thread->{last_message};
    if (defined $last)
    {
	$params{subject} = "Re: " . $thread->{subject};
	$params{references} = $last->get_header("Message-ID");
    }
    else
    {
	$params{subject} = $thread->{subject};
    }
    $params{date} = DateTime->from_epoch( epoch => $self->{next_date} );
    $self->{next_date} += $self->{deltat};

    my $msg = $self->SUPER::generate(%params);
    $msg->add_header('X-Cassandane-Thread', $thread->{id});
    $thread->{last_message} = $msg;
    $self->{nmessages}--;

    return $msg;
}

# TODO: test that both References: and In-Reply-To: are tracked in the server
# TODO: test that Subject: isnt tracked in the server

1;