# NAME

Dist::Zilla::PluginBundle::Author::GSG - Grant Street Group CPAN dists

# VERSION

version 0.0.4

# SYNOPSIS

Your `dist.ini` can be as short as this:

    name = Foo-Bar-GSG
    [@Author::GSG]

Which is equivalent to all of this:

Some of which comes from [Dist::Zilla::Plugin::Author::GSG](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::GSG).

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

    [ChangelogFromGit]
    tag_regexp = ^v(\d+\.\d+\.\d+)$

    [Git::NextVersion]
    first_version = 0.0.1

    [Git::Commit]
    [Git::Tag]
    [Git::Push]

    [Git::Contributors]

    [GitHub::Meta]
    [GitHub::UploadRelease] # plus magic to work without releasing elsewhere

    [Test::Compile]
    [Test::ReportPrereqs]

# DESCRIPTION

This PluginBundle is here to make it easy for folks at GSG to release
public distributions of modules as well as trying to make it easy for
other folks to contribute.

The `share_dir` for this module includes GSG standard files to include
with open source modules.  Things like a standard Makefile,
a contributing guide, and a MANIFEST.SKIP that should work with this Plugin.
See the ["update"](#update) Makefile target for details.

The expected workflow for a module using this code is that after following
the initial setup decribed below, you would manage changes via standard
GitHub flow pull requests and issues.
When ready for a release, you would first `make update` to update
any included documents, commit those,
and then run `carton exec dzil release`.
You can set a specific release version with the `V` environment variable,
as described in the
[Git::NextVersion Plugin](https://metacpan.org/pod/Dist::Zilla::Plugin::Git::NextVersion) documentation.

# Setting up a new dist

## Create your dist.ini

As above, you need the `name` and `[@Author::GSG]` bundle,
plus any other changes you need.

You can override [Pod::Weaver](https://metacpan.org/pod/Pod::Weaver)'s `finder` by setting `pod_finder`.

## Add Dist::Zilla::PluginBundle::Author::GSG to your cpanfile

    on 'develop' => sub {
        requires 'Dist::Zilla::PluginBundle::Author::GSG',
    };

Doing this in the `develop` phase will cause the default Makefile
not to install it, which means folks contributing to a module
won't need to install all of the Dist::Zilla dependencies just to
submit some patches, but will be able to run most tests.

## Create a Makefile

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

Using this example Makefile does require you run `carton install` after
adding the `on 'develop'` dependency to your cpanfile as described above.

If you want to override the Makefile included with this Plugin
but still want to use some of the targets in it,
you could replace the `Makefile` target in this example with your own targets,
and document running the initial `carton install` manually.

The Makefile that comes in this PluginBundle's `share_dir` has a many
helpers to make development on a module supported by it easier.

Some of the targets that are included in the Makefile are:

- test

    Makes your your `local` `cpanfile.snapshot` is up-to-date and
    if not, will run [Carton](https://metacpan.org/pod/Carton) before running `prove -lfr t`.

- testcoverage

    This target runs your tests under the [Devel::Cover](https://metacpan.org/pod/Devel::Cover) `cover` utility.
    However, `Devel::Cover` is not normally a dependency,
    so you will need to add it to the cpanfile temporarily for this target to work.

- Makefile

    Copies the Makefile included in this PluginBundle's `share_dir` into
    your distribution.

- update

    Generates README.md and copies some additional files from this
    PluginBundle's `share_dir` into the repo so that the shared
    documents provided here will be kept up-to-date.

    - README.md

        This is generated from the post `Pod::Weaver` documentation of the
        main module in the dist.
        Requires installing the `develop` cpanfile dependencies to work.

    - $(CONTRIB)

        The files in this variable are copied from this PluginBundle's

        Currently includes `CONTRIBUTING.md` and `MANIFEST.SKIP`.

- $(CPANFILE\_SNAPSHOT)

    Attempts to locate the correct `cpanfile.snapshot` and
    automatically runs `carton install $(CARTON_INSTALL_FLAGS)` if
    it is out of date.

    The `CARTON_INSTALL_FLAGS` are by default `--without develop`
    in order to avoid unnecessarily installing the heavy `Dist::Zilla`
    dependency chain.

## Cutting a release

    carton exec dzil release

This should calculate the new version number, build a new release tarball,
add a release tag, create the release on GitHub and upload the tarball to it.

You can set the `V` environment variable to force a specific version,
as described by [Dist::Zilla::Plugin::Git::NextVersion](https://metacpan.org/pod/Dist::Zilla::Plugin::Git::NextVersion).

    V=2.0.0 carton exec dzil release

- Your git remote must be a format GitHub::UploadRelease understands

    Either
    `ssh://git@github.com/GrantsStreetGroup/$repo.git`
    or
    `https://github.com/GrantsStreetGroup/$repo.git`.

    As shown in the "Fetch URL" from `git remote -n $remote`,

- Set `github.user` and either `github.password` or `github.token`

    You should probably use a token instead of your password,
    which you can get by following
    [GitHub's instructions](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).

        git config --global github.user  github_login_name
        git config --global github.token token_from_instructions_above

# AUTHOR

Grant Street Group <developers@grantstreet.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Grant Street Group.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)

# CONTRIBUTOR

Andrew Fresh <andrew.fresh@grantstreet.com>
