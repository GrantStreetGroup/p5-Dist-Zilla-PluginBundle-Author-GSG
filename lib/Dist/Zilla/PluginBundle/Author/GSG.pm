package Dist::Zilla::PluginBundle::Author::GSG;

# ABSTRACT: Grant Street Group CPAN dists
# VERSION

use Moose;
with qw(
    Dist::Zilla::Role::PluginBundle::Easy
);
use namespace::autoclean;

sub configure {
    my ($self) = @_;

    my $pod_finder = $self->payload->{pod_finder} || ':InstallModules';

    $self->add_bundle( 'Filter' => {
        -bundle => '@Basic',
        -remove => [ qw(
            MetaYAML
            UploadToCPAN
        ) ]
    } );

    $self->add_plugins(
        'Author::GSG',

        'MetaJSON',
        'Prereqs::FromCPANfile',
        'ReadmeAnyFromPod',

        'StaticInstall',

        [   'PodWeaver' => {
                finder             => $pod_finder,
                replacer           => 'replace_with_comment',
                post_code_replacer => 'replace_with_nothing',
                config_plugin      => [ '@Default', 'Contributors' ]
            }
        ],

        'GitHub::Meta',
        'Author::GSG::GitHub::UploadRelease',

        [ 'ChangelogFromGit' => {
            tag_regexp => '^v(\d+\.\d+\.\d+)$'
        } ],

        [ 'Git::NextVersion' => {
            first_version => '0.0.1',
        } ],

        'Git::Commit',
        'Git::Tag',
        'Git::Push',

        'Git::Contributors',

        'Test::Compile',
        'Test::ReportPrereqs',
    );
}

__PACKAGE__->meta->make_immutable;

package # hide from the CPAN
    Dist::Zilla::Plugin::Author::GSG::GitHub::UploadRelease;
use Moose;
BEGIN { extends 'Dist::Zilla::Plugin::GitHub::UploadRelease' }
with qw(
    Dist::Zilla::Role::Releaser
);

sub release {1} # do nothing, just let the GitHub Uploader do it for us

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS

Your C<dist.ini> can be as short as this:

    name = Foo-Bar-GSG
    [@Author::GSG]

Which is equivalent to all of this:

Some of which comes from L<Dist::Zilla::Plugin::Author::GSG>.

    name = Foo-Bar-GSG
    author = Grant Street Group <developers@grantstreet.com>
    license = Artistic_2_0
    copyright_holder = Grant Street Group
    copyright_year = # detected from git

    [@Filter]
    -bundle = @Basic
    -remove = MetaYAML
    -remove = UploadToCPAN

    # The defaults for author and license come from
    #[Author::GSG]

    [MetaJSON]
    [Prereqs::FromCPANfile]
    [ReadmeAnyFromPod]

    [StaticInstall]

    [Pod::Weaver]
    finder = :InstallModules
    replacer = replace_with_comment
    post_code_replacer = replace_with_nothing
    config_plugin = [ @Default, Contributors ]

    [GitHub::Meta]
    [GitHub::UploadRelease] # plus magic to work without releasing elsewhere

    [ChangelogFromGit]
    tag_regexp = ^v(\d+\.\d+\.\d+)$

    [Git::NextVersion]
    first_version = 0.0.1

    [Git::Commit]
    [Git::Tag]
    [Git::Push]

    [Git::Contributors]

    [Test::Compile]
    [Test::ReportPrereqs]

=head1 DESCRIPTION

This PluginBundle is here to make it easy for folks at GSG to release
public distributions of modules as well as trying to make it easy for
other folks to contribute.

The C<share_dir> for this module includes GSG standard files to include
with open source modules.  Things like a standard Makefile,
a contributing guide, and a MANIFEST.SKIP that should work with this Plugin.
See the L</update> Makefile target for details.

The expected workflow for a module using this code is that after following
the initial setup decribed below, you would manage changes via standard
GitHub flow pull requests and issues.
When ready for a release, you would first C<make update> to update
any included documents, commit those,
and then run C<carton exec dzil release>.
You can set a specific release version with the C<V> environment variable,
as described in the
L<Git::NextVersion Plugin|Dist::Zilla::Plugin::Git::NextVersion> documentation.

=head1 Setting up a new dist

=head2 Create your dist.ini

As above, you need the C<name> and C<[@Author::GSG]> bundle,
plus any other changes you need.

You can override L<Pod::Weaver>'s C<finder> by setting C<pod_finder>.

=head2 Add Dist::Zilla::PluginBundle::Author::GSG to your cpanfile

    on 'develop' => sub {
        requires 'Dist::Zilla::PluginBundle::Author::GSG',
    };

Doing this in the C<develop> phase will cause the default Makefile
not to install it, which means folks contributing to a module
won't need to install all of the Dist::Zilla dependencies just to
submit some patches, but will be able to run most tests.

=head2 Create a Makefile

It is recommended to keep a copy of the Makefile from this PluginBundle
in your app and update it as necessary, which the target in the included
Makefile will do automatically.

An initial Makefile you could use to copy one out of this PluginBundle
might look like this:

    SHARE_DIR   := $(shell \
        carton exec perl -Ilib -MFile::ShareDir=dist_dir -e \
            'print eval { dist_dir("Dist-Zilla-PluginBundle-Author-GSG") } || "share"' )

    include $(SHARE_DIR)/Makefile

    # Copy the SHARE_DIR Makefile over this one:
    # Making it .PHONY will force it to copy even if this one is newer.
    .PHONY: Makefile
    Makefile: $(SHARE_DIR)/Makefile
    	cp $< $@

Using this example Makefile does require you run C<carton install> after
adding the C<on 'develop'> dependency to your cpanfile as described above.

If you want to override the Makefile included with this Plugin
but still want to use some of the targets in it,
you could replace the C<Makefile> target in this example with your own targets,
and document running the initial C<carton install> manually.

The Makefile that comes in this PluginBundle's C<share_dir> has a many
helpers to make development on a module supported by it easier.

Some of the targets that are included in the Makefile are:

=over

=item test

Makes your your C<local> C<cpanfile.snapshot> is up-to-date and
if not, will run L<Carton> before running C<prove -lfr t>.

=item testcoverage

This target runs your tests under the L<Devel::Cover> C<cover> utility.
However, C<Devel::Cover> is not normally a dependency,
so you will need to add it to the cpanfile temporarily for this target to work.

=item Makefile

Copies the Makefile included in this PluginBundle's C<share_dir> into
your distribution.

=item update

Generates README.md and copies some additional files from this
PluginBundle's C<share_dir> into the repo so that the shared
documents provided here will be kept up-to-date.

=over

=item README.md

This is generated from the post C<Pod::Weaver> documentation of the
main module in the dist.
Requires installing the C<develop> cpanfile dependencies to work.

=item $(CONTRIB)

The files in this variable are copied from this PluginBundle's

Currently includes C<CONTRIBUTING.md> and C<MANIFEST.SKIP>.

=back

=item $(CPANFILE_SNAPSHOT)

Attempts to locate the correct C<cpanfile.snapshot> and
automatically runs C<carton install $(CARTON_INSTALL_FLAGS)> if
it is out of date.

The C<CARTON_INSTALL_FLAGS> are by default C<--without develop>
in order to avoid unnecessarily installing the heavy C<Dist::Zilla>
dependency chain.

=back

=cut
