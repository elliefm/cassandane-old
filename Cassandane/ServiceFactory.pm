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

package Cassandane::ServiceFactory;
use strict;
use warnings;
use Cassandane::Util::Log;
use Cassandane::Service;
use Cassandane::IMAPService;

sub create
{
    my ($class, %params) = @_;

    my $name = $params{name};
    die "No name specified"
	unless defined $name;

    # try and guess some service-specific defaults
    if ($name =~ m/imap/)
    {
	return Cassandane::IMAPService->new(
				argv => ['imapd'],
				%params);
    }
    elsif ($name =~ m/sync/)
    {
	return Cassandane::Service->new(
				argv => ['imapd'],
				%params);
    }
    elsif ($name =~ m/http/)
    {
	return Cassandane::Service->new(
				argv => ['httpd'],
				%params);
    }
    elsif ($name =~ m/lmtp/)
    {
	return Cassandane::Service->new(
				argv => ['lmtpd'],
				%params);
    }
    elsif ($name =~ m/sieve/)
    {
	return Cassandane::Service->new(
				argv => ['timsieved'],
				%params);
    }
    elsif ($name =~ m/nntp/)
    {
	return Cassandane::Service->new(
				argv => ['nntpd'],
				%params);
    }
    elsif ($name =~ m/smmap/)
    {
	return Cassandane::Service->new(
				argv => ['smmapd'],
				%params);
    }
    elsif ($name =~ m/pop/)
    {
	return Cassandane::Service->new(
				type => 'pop3',
				argv => ['pop3d'],
				%params);
    }
    else
    {
	die "No command specified and cannot guess a default"
	    unless defined $params{argv};
	return Cassandane::Service->new(%params);
    }
}

1;
