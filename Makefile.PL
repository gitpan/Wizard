# -*- perl -*-

use strict;
use ExtUtils::MakeMaker;
use Getopt::Long ();

use vars qw($opt_config);
Getopt::Long::GetOptions('config');

my $ok = 1;
my %prereq;
$prereq{'Data::Dumper'} = 0;
print "Checking for Data::Dumper ... ";
if (!eval { require Data::Dumper }) {
    $ok = 0;
    print "\nYou don't have installed the Data::Dumper module.\n";
} else {
    print "ok\n";
}

$prereq{'HTML::EP'} = 0;
print "Checking for HTML::EP ... ";
if (!eval { require HTML::EP }) {
    $ok = 0;
    print "\nYou don't have installed the HTML::EP package.\n";
} else {
    print "ok\n";
}

unless ($ok) {
    print q{
Missing modules are available from any CPAN mirror, in particular
	ftp://ftp.funet.fi/pub/languages/perl/CPAN/modules/by-module
};
    exit 1;
}

my $cfg;
if (-f "lib/Wizard/Examples/Apache/Config.pm") {
    $cfg = eval { require "lib/Wizard/Examples/Apache/Config.pm" };
}
if (!$cfg  ||  $opt_config) {
    my $prefsfile = $cfg->{'apache-prefs-file'} || '/etc/httpd/wwwAdmin/prefs';
    $cfg->{'apache-prefs-file'} =
	prompt("Enter path of the Apache Wizard prefs file:", $prefsfile);
}
die "Failed to create directory lib/Wizard/Examples/Apache: $!"
    unless ((-d "lib/Wizard/Examples/Apache")  or
	    mkdir("lib/Wizard/Examples/Apache", 0755));
my $dump = Data::Dumper->new([$cfg],
			     ["Wizard::Examples::Apache::Config::config"]);
$dump->Indent(1);
if (!open(FILE, ">lib/Wizard/Examples/Apache/Config.pm")  or
    !(print FILE ("package Wizard::Examples::Apache::Config;\n",
		  $dump->Dump()))  or
    !close(FILE)) {
    die "Failed to create file lib/Wizard/Examples/Apache/Config.pm: $!";
}

my %opts = ('NAME'         => 'Wizard',
	    'VERSION_FROM' => 'lib/Wizard.pm',
	    'EXE_FILES'    => [ 'wizard', 'apacheAdmin' ],
	    'dist'         => { 'SUFFIX'       => ".gz",
				'DIST_DEFAULT' => 'all tardist',
				'COMPRESS'     => "gzip -9f" },
	    'clean'        => { 'FILES' => '$(EXE_FILES)' });
if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
    $opts{ABSTRACT_FROM} = 'lib/Wizard.pm';
    $opts{AUTHOR} = 'Jochen Wiedmann (joe@ispsoft.de) and Amarendran R. Subramanian (amar@ispsoft.de)';
    $opts{PREREQ_PM} = \%prereq;
}


WriteMakefile(%opts);


package MY;

sub libscan {
    my $self = shift;  my $path = shift;
    return undef if $path =~ /\~$/; # Emacs backup file
    $path;
}
