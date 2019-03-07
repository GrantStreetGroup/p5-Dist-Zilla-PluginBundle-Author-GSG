# NAME

Dist::Zilla::PluginBundle::Author::GSG - Grant Street Group CPAN dists

# VERSION

version 0.0.1

# SYNOPSIS

Your `dist.ini` can be as short as this:

    name = Foo-Bar-GSG
    [@Author::GSG]

Which is equivalent to all of this:

# Setting up a new dist

## OVERRIDING THE DEFAULT Makefile

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
is to add a Makefile target that uses the `SHARE_DIR` we set above.

    Makefile: $(SHARE_DIR)/Makefile
        cp $< $@
        @echo Makefile updated>&2

# AUTHOR

Grant Street Group <developers@grantstreet.com>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2019 by Grant Street Group.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)

# CONTRIBUTOR

Andrew Fresh <andrew.fresh@grantstreet.com>
