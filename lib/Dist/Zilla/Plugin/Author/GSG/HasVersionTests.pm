package Dist::Zilla::Plugin::Author::GSG::HasVersionTests;;
use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';

use namespace::autoclean;

# ABSTRACT: Appropriate errors for missing $VERSIONs in GSG dists
# VERSION

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

If you don't want the whole L<Dist::Zilla::PluginBundle::Author::GSG>
you can get the C<author/has-version.t>
by adding this Plugin to your C<dist.ini>.

    name = Foo-Bar-GSG
    [@Basic]
    [Author::GSG::HasVersionTests]

=head1 DESCRIPTION

Provides an author test file that runs L<Test::HasVersion/pm_version_ok>
against C<all_pm_files> found by that module.
If any fail a diagnostic message explaining that the files need
to have C<# VERSION> comments due to our use of
L<Dist::Zilla::Plugin::OurPkgVersion>.

=head1 SEE ALSO

L<Test::HasVersion>

L<Dist::Zilla::Plugin::HasVersionTests>

=cut

__DATA__
___[ xt/author/has-version.t ]___
#!perl
# This file was automatically generated by Dist::Zilla::Plugin::Author::GSG::HasVersionTests.
use strict;
use warnings;

use Test::More;

eval "use Test::HasVersion";
plan skip_all =>
     'Test::HasVersion required for testing for version numbers' if $@;

my $failed = 0;

for (all_pm_files()) {
    pm_version_ok($_) or $failed = 1;
}

diag(<<'EOL') if $failed;
To address these failed HasVersion tests, when using Author::GSG derived
Dist::Zilla PluginBundles, you should add a `# VERSION` comment to be used by
the OurPkgVersion Plugin.

See the documetation for Dist::Zilla::Plugin::Author::GSG::HasVersionTests
for further details.
EOL

done_testing