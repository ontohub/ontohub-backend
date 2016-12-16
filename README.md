[![Build Status](https://travis-ci.org/ontohub/ontohub-backend.svg?branch=master)](https://travis-ci.org/ontohub/ontohub-backend)
[![Coverage Status](https://coveralls.io/repos/github/ontohub/ontohub-backend/badge.svg?branch=master)](https://coveralls.io/github/ontohub/ontohub-backend?branch=master)
[![Code Climate](https://codeclimate.com/github/ontohub/ontohub-backend/badges/gpa.svg)](https://codeclimate.com/github/ontohub/ontohub-backend)
[![Dependency Status](https://gemnasium.com/badges/github.com/ontohub/ontohub-backend.svg)](https://gemnasium.com/github.com/ontohub/ontohub-backend)
[![GitHub issues](https://img.shields.io/github/issues/ontohub/ontohub-backend.svg?maxAge=2592000)](https://waffle.io/ontohub/ontohub-backend?source=ontohub%2Fontohub-backend)

# ontohub-backend
The main Ontohub service that serves the data for the frontend and other clients via the [JSON API](http://jsonapi.org/).

## Run the backend

The backend can be started in development mode with `rails server`.
The backend is then reachable from the browser at [http://localhost:3000](http://localhost:3000).

## Dependencies

The backend is implemented in [Ruby on Rails](http://rubyonrails.org).  First,
the Ruby version referenced in the file [.ruby-version](.ruby-version) needs to
be installed, as well as the gem [bundler](http://bundler.io). `git` needs to
be installed as well.  Invoking the command `bundle install` in the directory
of this repository will then install all dependencies of the backend.

## Set up a development environment

In order to set up a complete environment, please refer to the [wiki](https://github.com/ontohub/ontohub-backend/wiki) page [Setting up the development environment](https://github.com/ontohub/ontohub-backend/wiki/Setting-up-the-development-environment).
