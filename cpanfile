requires 'Moose';
requires 'namespace::autoclean';

requires 'Dist::Zilla';
requires 'Dist::Zilla::Role::PluginBundle::Easy';

requires 'Dist::Zilla::Plugin::Test::Compile';
requires 'Dist::Zilla::Plugin::Test::ReportPrereqs';

requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

on test => sub {
    requires 'Test::Pod', '1.14';
    requires 'Test::Strict';
};
