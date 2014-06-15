# RCR

A basic Ruby OCR library.

## Installation

This library is not yet on RubyGems. To install it,
first clone this repository. Then make sure that you have `bundler` installed:

    $ gem install bundler

And then, in the cloned repository, execute:

    $ bundle install

RCR requires RMagick and it has some problems with installing
on systems that have ImageMagick built with enabled HDR. If you
encounter problems with RMagick installation, try building ImageMagick
without HDR.

Before running, RCR requires some configuration (e.g. creating a configuration file
in `~/.rcr-config.yml` and downloading a training dataset). See the documentation
in `docs/` for details.

## Documentation

Look into `docs/`. To build a PDF of the docs, run `make` in the directory.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
