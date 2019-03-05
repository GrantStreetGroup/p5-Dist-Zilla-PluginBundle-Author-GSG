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
        'GSG::Defaults',

        'Test::Compile',
        'Test::ReportPrereqs',

        [ 'Git::NextVersion' => {
                first_version => '0.0.1',
            }
        ],

        'Git::Commit',
        'Git::Tag',
        'Git::Push',

        [ 'ChangelogFromGit' => {
                # tag_regexp => '^v(\d+\.\d+\.\d+)$'
            }
        ],

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
    Dist::Zilla::Plugin::GSG::Defaults;

use Moose;
with qw(
    Dist::Zilla::Role::LicenseProvider
);
use Git::Wrapper qw();
use namespace::autoclean;

around 'BUILDARGS' => sub {
    my ($orig, $self, $args) = @_;

    $args->{zilla}->{authors}
        ||= ['Grant Street Group <developers@grantstreet.com>'];

    return $self->$orig($args);
};

sub provide_license {
    my ( $self, $conf ) = @_;

    my $license_class = $self->zilla->_license_class || 'Artistic_2_0';
    $license_class =~ s/^(?:Software::License::)?/Software::License::/;

    my $holder = $conf->{copyright_holder} || 'Grant Street Group';

    my $this_year = 1900 + (localtime)[5];
    my $year = $conf->{copyright_year};
    if ( $year eq $this_year ) {
        my ( $commit, $date ) = do { local $@; eval { local $SIG{__DIE__};
            Git::Wrapper->new('.')->RUN(
                qw( rev-list --max-parents=0 --pretty=format:%ai HEAD )) } };

        if ($date) {
            ($year) = $date =~ /^(\d{4})/;
            $year .= " - $this_year" unless $year == $this_year;
        }
    }

    {
        local $@ = undef;
        {
            local $SIG{__DIE__} = 'DEFAULT';
            eval "require $license_class";
        }
        die if $@;
    }

    return $license_class->new(
        {   holder => $holder,
            year   => $year,
        }
    );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS

Your C<dist.ini> can be as short as this:

    name = Foo-Bar-GSG
    [@Author::GSG]

Which is equivalent to all of this:

=cut
