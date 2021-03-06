use strict;
use warnings;

use Test::More;

use Test::DZil;

use Git::Wrapper;
use File::Temp qw();
use File::pushd qw();
use version;

use lib qw(lib);
use Dist::Zilla::Plugin::Author::GSG;

$ENV{EMAIL} = 'fake@example.com'; # force a default for git
#$Git::Wrapper::DEBUG = 1;

my $dir = File::Temp->newdir("dzpag-XXXXXXXXX");

{
    my $git = Git::Wrapper->new($dir);
    plan skip_all => "No Git!" unless $git->has_git_in_path;

    my $git_version = $git->version;
    diag "Have git $git_version";

    plan skip_all => "Git is too old: $git_version"
        unless Dist::Zilla::Plugin::Author::GSG::_git_version_ok($git_version);

    $git->init;
    $git->commit( { m => 'init', date => '2001-02-03 04:05:06' },
        '--allow-empty' );
}

my $author = 'Grant Street Group <developers@grantstreet.com>';
my $holder = 'Grant Street Group';
my $year   = 1900 + (localtime)[5];

subtest 'Require git v1.7.5' => sub {
    my $version;
    no warnings 'redefine';
    local *Git::Wrapper::version = sub {$version};
    use warnings 'redefine';

    for ( '1', '1.7', '1.7.4', '1.7.4.9') {
        $version = $_;
        local $@;
        eval { local $SIG{__DIE__}; Builder->from_config(
            { dist_root => 'corpus/dist/old-git' },
            {   add_files => {
                    'source/dist.ini' => dist_ini(
                        { name => 'Old-Git', }, 'Author::GSG',
                    ),
                }
            }
        ) };

        like $@, qr/\QGit 1.7.5 or greater is required, only have $version./,
            "[$version] Fatal error with old git versions";
    }

    for ( '1.7.5', '1.7.6', '1.70.0', '2.21.1 (Apple Git-122.3)' ) {
        $version = $_;
        local $@;
        eval { local $SIG{__DIE__}; Builder->from_config(
            { dist_root => 'corpus/dist/old-git' },
            {   add_files => {
                    'source/dist.ini' => dist_ini(
                        { name => 'New-Git', }, 'Author::GSG',
                    ),
                }
            }
        ) };

        ok !$@, "[$version] No errors with new git";
    }
};

subtest 'Dist with defaults' => sub {
    my $tzil = Builder->from_config(
        { dist_root => 'corpus/dist/defaults' },
        {   also_copy => { $dir => 'source' },
            add_files => {
                'source/dist.ini' => dist_ini(
                    {   name    => 'Defaults',
                        version => '1.2.3',
                    },
                    'Author::GSG',
                    'GatherDir',
                ),
                'source/lib/Defaults.pm' =>
                    "package Defaults;\n# ABSTRACT: ABSTRACT\n1;",
            }
        }
    );

    $tzil->build;

    is_deeply $tzil->authors, [$author], "Correct default author";

    is $tzil->license->name, 'The Artistic License 2.0 (GPL Compatible)',
        "Correct default license";
    is $tzil->license->holder, $holder, "Correct default license holder";
    is $tzil->license->year, "2001 - $year", "Correct default license year";
};

subtest 'Dist with defaults, without git repo' => sub {
    # Hope for no .git directories in TMPDIR
    my $tmpdir = File::Temp->newdir( 'dzpag-XXXXXXXXX', TMPDIR => 1 );
    my $tzil = Builder->from_config(
        { dist_root => 'corpus/dist/defaults' },
        {   tempdir_root => "$tmpdir",    # requires a string
            add_files    => {
                'source/dist.ini' => dist_ini(
                    {   name    => 'Defaults',
                        version => '1.2.3',
                    },
                    'Author::GSG',
                    'GatherDir',
                ),
                'source/lib/Defaults.pm' =>
                    "package Defaults;\n# ABSTRACT: ABSTRACT\n1;",
            }
        }
    );

    $tzil->build;

    is_deeply $tzil->authors, [$author], "Correct default author";

    is $tzil->license->name, 'The Artistic License 2.0 (GPL Compatible)',
        "Correct default license";
    is $tzil->license->holder, $holder, "Correct default license holder";
    is $tzil->license->year,   $year,   "Correct default license year";
};

subtest 'Dist overriding defaults' => sub {

    my $tzil = Builder->from_config(
        { dist_root => 'corpus/dist/override' },
        {   also_copy => { $dir => 'source' },
            add_files => {
                'source/dist.ini' => dist_ini(
                    {   name    => 'Overrides',
                        version => '1.2.3',
                        author  => 'An Author <an.author@example.test>',
                        license => 'MIT',
                        copyright_holder => 'An Author',
                        copyright_year   => '1995',
                    },
                    'Author::GSG',
                    'GatherDir',
                ),
                'source/lib/Overrides.pm' =>
                    "package Overrides;\n# ABSTRACT: ABSTRACT\n1;",
            }
        }
    );

    $tzil->build;

    is_deeply $tzil->authors,
        ['An Author <an.author@example.test>'],
        "Correct overridden author";

    is $tzil->license->name, 'The MIT (X11) License',
        "Correct overridden license";
    is $tzil->license->holder, "An Author",
        "Correct overridden license holder";
    is $tzil->license->year, "1995", "Correct overridden license year";
};

done_testing;
