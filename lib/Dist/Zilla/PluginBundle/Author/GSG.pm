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
        ) ]
    } );

    $self->add_plugins(
        'Author::GSG',

        'Test::Compile',
        'Test::ReportPrereqs',

        'StaticInstall',

        'GitHub::Meta',
        'Author::GSG::GitHub::UploadRelease',

        [ 'Git::NextVersion' => {
            first_version => '0.0.1',
        } ],

        'Git::Commit',
        'Git::Tag',
        'Git::Push',

        [ 'ChangelogFromGit' => {
            tag_regexp => '^v(\d+\.\d+\.\d+)$'
        } ],

        'Git::Contributors',
        [   'PodWeaver' => {
                finder             => $pod_finder,
                replacer           => 'replace_with_comment',
                post_code_replacer => 'replace_with_nothing',
                config_plugin      => [ '@Default', 'Contributors' ]
            }
        ],

        'MetaJSON',

        'Prereqs::FromCPANfile',
        'ReadmeAnyFromPod',
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

=head1 Setting up a new dist

=head2 OVERRIDING THE DEFAULT Makefile

If you want to override the Makefile included with this Plugin,
but still want to use some of the targets in this Makefile,
you can find and include it like this:

    SHARE_DIR   := $(shell \
        carton exec perl -Ilib -MFile::ShareDir=dist_dir -e \
            'print eval { dist_dir("Dist-Zilla-PluginBundle-Author-GSG") } || "share"' )

    include $(SHARE_DIR)/Makefile

    # Your targets here

Including the Plugin's Makefile that way will disable updating the Makefile
if the Plugin's changes.
An easy way to find the default Makefile to copy from the dist if you want that
is to add a Makefile target that uses the C<SHARE_DIR> we set above.

    Makefile: $(SHARE_DIR)/Makefile
        cp $< $@
        @echo Makefile updated>&2

=cut
