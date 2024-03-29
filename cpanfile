requires 'perl', 'v5.14.0'; # for kwalitee

requires 'Carp';
requires 'Moose';
requires 'version';
requires 'namespace::autoclean';

requires 'Dist::Zilla';
requires 'Dist::Zilla::Role::Plugin';
requires 'Dist::Zilla::Role::PluginBundle::Easy';

requires 'Git::Wrapper';
requires 'Dist::Zilla::Role::LicenseProvider';

requires 'Dist::Zilla::Plugin::Test::Compile', '2.055';
requires 'Dist::Zilla::Plugin::Test::ReportPrereqs';
requires 'Dist::Zilla::Plugin::StaticInstall';
requires 'Test::HasVersion';

requires 'Dist::Zilla::Plugin::InlineFiles';

# Fails to set a version due to to a misplaced check fixed in 0.20
requires 'Dist::Zilla::Plugin::OurPkgVersion', '0.20';
requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';
requires 'Dist::Zilla::Plugin::MetaProvides::Package';

requires 'Dist::Zilla::Plugin::GitHub::Meta', '0.46';
requires 'Dist::Zilla::Plugin::GitHub::UploadRelease';

requires 'Dist::Zilla::Plugin::Git::NextVersion', '2.044';
requires 'Dist::Zilla::Plugin::Git::Commit';
requires 'Dist::Zilla::Plugin::Git::Tag', '2.046';
requires 'Dist::Zilla::Plugin::Git::Push';

requires 'Dist::Zilla::Plugin::ChangelogFromGit::CPAN::Changes', '> 0.230480';

requires 'Dist::Zilla::Plugin::Git::Contributors';
requires 'Dist::Zilla::Plugin::PodWeaver';
requires 'Pod::Weaver::Section::Contributors';

requires "Pod::Coverage::TrustPod";
requires "Test::Pod", "1.41";
requires "Test::Pod::Coverage", "1.08";

on test => sub {
    requires 'Dist::Zilla::Role::MetaProvider';
    requires 'File::Spec';
    requires 'File::Temp';
    requires 'File::pushd';
    requires 'IPC::Cmd';
    requires 'Test::DZil';
    requires 'Test::Deep';
    requires 'Test::Fatal';
    requires 'Test::More';
    requires 'Test::Pod', '1.14';
    requires 'Time::Piece';
    requires 'lib';
    requires 'strict';
    requires 'warnings';
};

on develop => sub {
    requires 'Dist::Zilla::Plugin::Bootstrap::lib';
    requires 'Test::Strict';
};
