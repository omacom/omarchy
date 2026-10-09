#!/usr/bin/perl
# Rex worker for Perl's own regex engine. Same protocol as rex_worker.py:
# one JSON request per line on stdin, replies one per line on stdout, match
# offsets in UTF-16 code units.
#
# Patterns are interpolated at run time, so (?{ code }) blocks stay
# forbidden: Perl refuses them without `use re 'eval'`, which this file
# never says.

use strict;
use warnings;
no warnings 'regexp';
use JSON::PP;
use IO::Select;
use Time::HiRes qw(time);

use constant SLICE_SECONDS => 0.05;

$| = 1;
my $json = JSON::PP->new->utf8->canonical;
my $select = IO::Select->new(\*STDIN);
binmode STDIN;
binmode STDOUT;

my $pending = "";

sub read_line {
  while (index($pending, "\n") < 0) {
    my $chunk;
    my $n = sysread(STDIN, $chunk, 1 << 20);
    return undef unless $n;
    $pending .= $chunk;
  }
  my $at = index($pending, "\n");
  my $line = substr($pending, 0, $at);
  $pending = substr($pending, $at + 1);
  return $line;
}

sub waiting {
  return 1 if index($pending, "\n") >= 0;
  return scalar $select->can_read(0);
}

sub send_reply {
  print $json->encode($_[0]), "\n";
}

# Code point offsets to UTF-16: astral characters take two units.
sub astral_positions {
  my ($text) = @_;
  my @astral;
  while ($text =~ /[^\x{0}-\x{FFFF}]/g) { push @astral, $-[0] }
  return \@astral;
}

sub utf16 {
  my ($astral, $cp) = @_;
  return $cp if $cp < 0 || !@$astral;
  my ($lo, $hi) = (0, scalar @$astral);
  while ($lo < $hi) {
    my $mid = int(($lo + $hi) / 2);
    if ($astral->[$mid] < $cp) { $lo = $mid + 1 } else { $hi = $mid }
  }
  return $cp + $lo;
}

sub run_match {
  my ($request, $text, $astral) = @_;
  my $id = $request->{id};
  my %allowed = map { $_ => 1 } qw(i m s x n a);
  my $flags = join "", grep { $allowed{$_} } @{ $request->{flags} || [] };
  my $pattern = $request->{pattern};
  my $re = eval { $flags ne "" ? qr/(?$flags)$pattern/ : qr/$pattern/ };
  if (!$re) {
    my $error = $@ || "invalid pattern";
    $error =~ s/ at \S+ line \d+\.?\n?$//;
    send_reply({ id => $id, ok => JSON::PP::false, done => JSON::PP::true, error => $error, matches => [], stride => 2 });
    return;
  }
  my $limit = $request->{limit} || 100000;
  my $all = !defined $request->{all} || $request->{all};
  # $#+ is the pattern's group count after any successful match, and
  # matching the pattern or nothing always succeeds.
  "" =~ /(?:$re)|/;
  my $groups = $#+;
  my $stride = ($groups + 1) * 2;
  my $started = time;
  my $slice = $started;
  my @out;
  my $count = 0;
  pos($text) = 0;
  while ($text =~ /$re/g) {
    for my $g (0 .. $groups) {
      if (defined $-[$g]) {
        push @out, utf16($astral, $-[$g]), utf16($astral, $+[$g]);
      } else {
        push @out, -1, -1;
      }
    }
    $count++;
    last if $count >= $limit || !$all;
    if (time - $slice > SLICE_SECONDS) {
      send_reply({ id => $id, ok => JSON::PP::true, done => JSON::PP::false, matches => [@out], stride => $stride, elapsed => (time - $started) * 1000 });
      @out = ();
      $slice = time;
      return if waiting();
    }
  }
  send_reply({ id => $id, ok => JSON::PP::true, done => JSON::PP::true, matches => \@out, stride => $stride, elapsed => (time - $started) * 1000, names => named_groups($re) });
}

sub named_groups {
  my ($re) = @_;
  my %out;
  my $index = 0;
  # Names in pattern order, with the number of the group each first names.
  my $source = "$re";
  while ($source =~ /\\.|\[(?:\\.|[^\]])*\]|(\((?!\?)|\(\?(?:P?<([A-Za-z_]\w*)>|'([A-Za-z_]\w*)'))/g) {
    next unless defined $1;
    $index++;
    my $name = defined $2 ? $2 : $3;
    $out{$name} = $index if defined $name && !exists $out{$name};
  }
  return \%out;
}

my %texts;
my %astrals;
while (defined(my $line = read_line())) {
  my $request = eval { $json->decode($line) } or next;
  my $id = $request->{id};
  if (($request->{op} || "") eq "info") {
    send_reply({ id => $id, ok => JSON::PP::true, done => JSON::PP::true, versions => { perl => sprintf("%vd", $^V) } });
    next;
  }
  if (exists $request->{text}) {
    %texts = ();
    %astrals = ();
    $texts{ $request->{textId} } = $request->{text};
    $astrals{ $request->{textId} } = astral_positions($request->{text});
  }
  my $text = $texts{ $request->{textId} };
  if (!defined $text) {
    send_reply({ id => $id, ok => JSON::PP::false, done => JSON::PP::true, error => "missing-text", matches => [], stride => 2 });
    next;
  }
  eval { run_match($request, $text, $astrals{ $request->{textId} }); 1 } or do {
    my $error = $@ || "failed";
    send_reply({ id => $id, ok => JSON::PP::false, done => JSON::PP::true, error => "$error", matches => [], stride => 2 });
  };
}
