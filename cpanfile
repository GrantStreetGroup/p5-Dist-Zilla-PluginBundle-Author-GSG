requires 'Moose';
requires 'namespace::autoclean';

requires 'Dist::Zilla';
requires 'Dist::Zilla::Role::PluginBundle::Easy';

requires 'Dist::Zilla::Plugin::Test::Compile';
requires 'Dist::Zilla::Plugin::Test::ReportPrereqs';

requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

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
