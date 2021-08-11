#!/usr/bin/perl
# 1.04 arb Fri Jun 15 10:20:31 BST 2018 - added _YYYYMMDDHHMM_ filenames
# 1.03 arb Tue May 29 15:04:52 BST 2018 - put Quicklook before ls
# 1.02 arb Mon May 22 12:34:46 GMT 2017 - added Oceansat-2 filenames
# 1.01 arb Fri Oct  7 11:09:39 BST 2016 - added tar format, and qlook dir style
# 1.00 arb Fri May 23 10:59:34 BST 2014
# 
# Sort the input lines according to a date sub-string
# eg. pipe the output from ls or tar into this program.
# All it does is decode the date and prepend it to each line,
# pipe the result through the external sort program,
# then remove the prepended date again with sed.
# Usage: datesort.pl [-r|-u] < input > output
# -r or -u are passed onto the sort program (reverse or unique)
# Could also use -ru (but not -r -u) as only one arg passed.

# Configuration
$output_unrecognised=1;

# Options
# Allow -r to be passed for a reverse sort
if ($ARGV[0] =~ /^-/) { $sortargs=$ARGV[0]; shift; }

# Current time
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year+=1900;
$mon+=1;

# Pipe the output through the sort program then remove the datetime
open(OUT, "| sort -n $sortargs | sed 's/^[0-9\.]* //'");

while (<>)
{
	# Quicklook directory style dates "2016/9/30/0123"
	# This comes before the ls/find output so if you do 'find /data/qlooks'
	# the filename takes precedence over the file timestamp
	if (/([12][09][0-9][0-9])\/([0-9]+)\/([0-9]+)\/([012][0-9])([0-5][0-9])/) { output_datetime($1,$2,$3,$4,$5,0,0,$_); }
	# The output from ls looks like this "Mar 25  2005"
	elsif (/Jan ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  1, $1, 0, 0, 0, 0, $_); }
	elsif (/Feb ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  2, $1, 0, 0, 0, 0, $_); }
	elsif (/Mar ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  3, $1, 0, 0, 0, 0, $_); }
	elsif (/Apr ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  4, $1, 0, 0, 0, 0, $_); }
	elsif (/May ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  5, $1, 0, 0, 0, 0, $_); }
	elsif (/Jun ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  6, $1, 0, 0, 0, 0, $_); }
	elsif (/Jul ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  7, $1, 0, 0, 0, 0, $_); }
	elsif (/Aug ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  8, $1, 0, 0, 0, 0, $_); }
	elsif (/Sep ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2,  9, $1, 0, 0, 0, 0, $_); }
	elsif (/Oct ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2, 10, $1, 0, 0, 0, 0, $_); }
	elsif (/Nov ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2, 11, $1, 0, 0, 0, 0, $_); }
	elsif (/Dec ([ 0-9][0-9])  ([12][09][0-9][0-9]) /) { output_datetime($2, 12, $1, 0, 0, 0, 0, $_); }
	# The output from tar on solaris (and star on both) looks like this "Sep 27 09:42 2016" (must come before the ls without year)
	elsif (/Jan ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  1, $1, $2, $3, 0, 0, $_); }
	elsif (/Feb ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  2, $1, $2, $3, 0, 0, $_); }
	elsif (/Mar ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  3, $1, $2, $3, 0, 0, $_); }
	elsif (/Apr ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  4, $1, $2, $3, 0, 0, $_); }
	elsif (/May ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  5, $1, $2, $3, 0, 0, $_); }
	elsif (/Jun ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  6, $1, $2, $3, 0, 0, $_); }
	elsif (/Jul ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  7, $1, $2, $3, 0, 0, $_); }
	elsif (/Aug ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  8, $1, $2, $3, 0, 0, $_); }
	elsif (/Sep ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4,  9, $1, $2, $3, 0, 0, $_); }
	elsif (/Oct ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4, 10, $1, $2, $3, 0, 0, $_); }
	elsif (/Nov ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4, 11, $1, $2, $3, 0, 0, $_); }
	elsif (/Dec ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) ([12][09][0-9][0-9])/) { output_datetime($4, 12, $1, $2, $3, 0, 0, $_); }
	# The output from ls or find looks like this "Mar 25 16:05"
	elsif (/Jan ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  1, $1, $2, $3, 0, 0, $_); }
	elsif (/Feb ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  2, $1, $2, $3, 0, 0, $_); }
	elsif (/Mar ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  3, $1, $2, $3, 0, 0, $_); }
	elsif (/Apr ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  4, $1, $2, $3, 0, 0, $_); }
	elsif (/May ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  5, $1, $2, $3, 0, 0, $_); }
	elsif (/Jun ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  6, $1, $2, $3, 0, 0, $_); }
	elsif (/Jul ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  7, $1, $2, $3, 0, 0, $_); }
	elsif (/Aug ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  8, $1, $2, $3, 0, 0, $_); }
	elsif (/Sep ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year,  9, $1, $2, $3, 0, 0, $_); }
	elsif (/Oct ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year, 10, $1, $2, $3, 0, 0, $_); }
	elsif (/Nov ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year, 11, $1, $2, $3, 0, 0, $_); }
	elsif (/Dec ([ 0-9][0-9]) ([012][0-9]):([0-5][0-9]) /) { output_datetime($year, 12, $1, $2, $3, 0, 0, $_); }
	# Oceansat-2 filenames look like this "O2_30JUL2016_029_009_LAP_L1B_ST_S"
	elsif (/O2_([0-9][0-9])JAN(20[0-9][0-9])_/) { output_datetime($2,  1, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])FEB(20[0-9][0-9])_/) { output_datetime($2,  2, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])MAR(20[0-9][0-9])_/) { output_datetime($2,  3, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])APR(20[0-9][0-9])_/) { output_datetime($2,  4, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])MAY(20[0-9][0-9])_/) { output_datetime($2,  5, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])Jun(20[0-9][0-9])_/) { output_datetime($2,  6, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])JUL(20[0-9][0-9])_/) { output_datetime($2,  7, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])AUG(20[0-9][0-9])_/) { output_datetime($2,  8, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])SEP(20[0-9][0-9])_/) { output_datetime($2,  9, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])OCT(20[0-9][0-9])_/) { output_datetime($2, 10, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])NOV(20[0-9][0-9])_/) { output_datetime($2, 11, $1, 0, 0, 0, 0, $_); }
	elsif (/O2_([0-9][0-9])DEC(20[0-9][0-9])_/) { output_datetime($2, 12, $1, 0, 0, 0, 0, $_); }
	# The content of a pass txt file looks like this "11 26 58 473 20 05 2014"
	elsif (/([012][0-9]) ([0-5][0-9]) ([0-5][0-9]) ([0-9][0-9][0-9]) ([0-3][0-9]) ([01][0-9]) ([12][09][0-9][0-9])/) { output_datetime($7, $6, $5, $1, $2, $3, $4, $_); }
	# The output from tar on linux looks like this "2016-09-27 09:42"
	elsif (/([12][09][0-9][0-9])-([01][0-9])-([0123][0-9]) ([012][0-9]):([0-5][0-9])/) { output_datetime($1,$2,$3,$4,$5,0,0,$_); }
	# Some filenames have _YYYYMMDDHHMM_
	elsif (/_(20[0-9][0-9])([01][0-9])([0-3][0-9])([0-2][0-9])([0-5][0-9])_/) { output_datetime($1, $2, $3, $4, $5, 0, 0, $_); }
	# Unrecognised lines are output?
	elsif ($output_unrecognised) { output_datetime(0,0,0,0,0,0,0,$_); }
	# If unrecognised lines are not required then we ignore the line
	else { ; }
}

exit 0;

sub output_datetime()
{
	local($Y,$M,$D,$h,$m,$s,$ms,$str)=@_;

	# If it's in the future then it is last year
	if ($Y > $year) { $Y--; }
	elsif ($Y == $year && $M > $mon) { $Y--; }
	elsif ($Y == $year && $M == $mon && $D > $mday) { $Y--; }
	printf OUT "%04d%02d%02d%02d%02d%02d.%03d $str", $Y,$M,$D, $h,$m,$s,$ms;
}
