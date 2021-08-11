#!/usr/bin/perl
# 1.13 arb Tue Sep 29 16:45:27 BST 2015 - split on whitespaces not a space
#      and fixed patterns to handle du containing paths
# 1.12 arb Tue Apr  7 13:56:48 BST 2015 - handle output from find -ls too
# 1.11 arb Tue Dec  2 10:23:59 GMT 2014 - handle output from tar tv too
# 1.10 arb Mon Oct 28 12:42:45 GMT 2013 - handle output from ls -lh too
# Sort the input (stdin or files) by size,
# the input is of the format like the output from du -h or ls -lh
#
# output from ls -lh
# -rw------- 1 arb local  117 Mar 20  2003 RICHPse.txt
# drwx------ 4 arb local    4 Jan 27  2014 rsync/
#
# output from du -h
# 1.5K	RICHPse.txt
# 3.0K	rsync/src/eumetcast/057.0E
#
# output from tar tv
# -rw------- arb/local      2240 2008-11-03 18:12 opera9/mail-via-import/store/account4/2006/01/19/6162.mbs
#
# eg.
# 12.3K  mytextfile
# 12.3M  mymp3file
# usage: sizesort.pl [-r]
# -r will sort in reverse

$reverse = 0;
$debug = 0;
if ($ARGV[0] eq "-d") { $debug=1; shift; }
if ($ARGV[0] eq "-r") { $reverse=1; shift; }

sub prettysize
{
	my $mult = 1/1024;
	#my @cols=split('\s+', $_[0]); # split by whitespace
	my @cols=split('[ \t]+', $_[0]); # split by whitespace
	my $colnum = 0; # default to the first column, ok for du -sh

	# tar tv (-rw-rw---- arb/local    433202) first col is perms, second col contains a slash
	$colnum = 2 if (length($cols[0] == 10) && ($cols[1] =~ /.*\/.*/));

	# ls -lh (drwx------ 1 arb local 1.2M) not a digit in first char
	$colnum = 4 if (substr($cols[0],0,1) !~ /[0-9]/);

	# find -ls (390232   84 drwx------   1 arb      local       86016) third col is permissions
	$colnum = 6 if (length($cols[2])==10 && substr($cols[2],0,1) !~ /[0-9]/);

	my $col = $cols[$colnum];
	my $suffix = substr($col, -1, 1);
	if ($suffix eq "K") { $mult=1; }
	elsif ($suffix eq "M") { $mult=1024; }
	elsif ($suffix eq "G") { $mult=1024*1024; }
	elsif ($suffix eq "T") { $mult=1024*1024*1024; }
	my $val = $mult * $col;
	print "returning $val for / $fields[1] / $_[0]" if ($debug);
	return $val;
}

sub bysize
{
	$sizes[$a] <=> $sizes[$b];
}

sub bysize_reverse
{
	$sizes[$b] <=> $sizes[$a];
}

@sizes=();
@lines=();

while (<>)
{
	push @sizes, prettysize($_);
	push @lines, $_;
}

if ($reverse)
{
	@indexes = sort bysize_reverse 0..$#lines;
}
else
{
	@indexes = sort bysize 0..$#lines;	
}

print @lines[@indexes];

exit 0;
