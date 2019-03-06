requires 'Moose';
requires 'namespace::autoclean';

requires 'Dist::Zilla';
requires 'Dist::Zilla::Role::PluginBundle::Easy';

requires 'Dist::Zilla::Plugin::Test::Compile';
requires 'Dist::Zilla::Plugin::Test::ReportPrereqs';

requires 'Dist::Zilla::Plugin::StaticInstall';

requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

requires 'Dist::Zilla::Plugin::GitHub::Meta';
requires 'Dist::Zilla::Plugin::GitHub::UploadRelease';

requires 'Dist::Zilla::Plugin::Git::NextVersion';
requires 'Dist::Zilla::Plugin::Git::Commit';
requires 'Dist::Zilla::Plugin::Git::Tag';
requires 'Dist::Zilla::Plugin::Git::Push';

requires 'Dist::Zilla::Plugin::ChangelogFromGit';

requires 'Dist::Zilla::Plugin::Git::Contributors';
requires 'Dist::Zilla::Plugin::PodWeaver';
requires 'Pod::Weaver::Section::Contributors';

on test => sub {
    requires 'CPAN::Meta';
    requires 'Capture::Tiny';
    requires 'File::pushd';
    requires 'JSON::PP';
    requires 'Path::Tiny';
    requires 'Test::Pod', '1.14';
    requires 'Test::Strict';
};
