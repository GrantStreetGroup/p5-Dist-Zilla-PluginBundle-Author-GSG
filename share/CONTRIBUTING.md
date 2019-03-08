Put the instructions on CONTRIBUTING to GSG dists here.

You should just be able to have carton available and then run `make test`

In order to work with `dzil` you will need to `carton install` manually
as the default in the Makefile uses `--without develop` to avoid heavy
dependencies that are usually unnecessary.

