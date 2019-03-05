use strict;
use warnings;

use Test::More;

use Capture::Tiny qw();
use CPAN::Meta qw();
use File::pushd qw();
use File::Temp qw();
use Path::Tiny qw();

use lib qw(lib);
my $module;
BEGIN {
    $module = 'Dist::Zilla::PluginBundle::Author::GSG';
    use_ok($module);
}

my $year   = 1900 + (localtime)[5];
my $holder = 'Grant Street Group';

#diag( "Testing $module " . $module->VERSION );

subtest 'Build a basic dist' => sub {
    my $ini = <<'__END__';
name = OurExternal-Package
[@Author::GSG]
__END__

    my $dist = new_dist(
        'cpanfile' => '',
        'dist.ini' => $ini,
        'lib/External/Package.pm' => "package External::Package;\n# ABSTRACT: ABSTRACT\n1;",
    );

    my $results = run($dist, 'dzil build');
    ok $results->{success}, 'Built the dist' or diag $results->{output};
    my ($distdir) = $results->{output} =~ / built in (.*)$/m;
    my $built
        = $dist->child($distdir)->child("lib/External/Package.pm")->slurp;
    like $built, qr/\QThis software is Copyright (c) 2001 - $year by $holder./,
        "Put the expected copyright in the module";
};

done_testing;

sub new_dist {
    my (%files) = @_;

    my $dir = Path::Tiny->tempdir;

    run($dir, "git init && git remote add origin $dir");
    for my $path (sort keys %files) {
        my $contents = $files{$path};

        $dir->child($path)
            ->touchpath
            ->spew($contents);
    }
    run($dir, 'git add . && git commit -m init --date="2001-02-03 04:05:06"');

    return $dir;
}

sub load_meta {
    my ($dir)  = @_;
    my ($file) = map { $_->children(qr/^META/) } grep {-d} $dir->children;
    return CPAN::Meta->load_file($file);
}

sub run {
    my ($dir, @command) = @_;
    my $pushd = File::pushd::pushd("$dir");
    my ($merged, $rc) = Capture::Tiny::capture_merged { system(@command) };

    return {
        exit    => $rc >> 8,
        signal  => $rc & 127,
        success => ! $rc,
        output  => $merged,
    };
}
