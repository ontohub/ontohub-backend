[![Build Status](https://travis-ci.org/ontohub/ontohub-backend.svg?branch=master)](https://travis-ci.org/ontohub/ontohub-backend)
[![Coverage Status](https://codecov.io/gh/ontohub/ontohub-backend/branch/master/graph/badge.svg)](https://codecov.io/gh/ontohub/ontohub-backend)
[![Code Climate](https://codeclimate.com/github/ontohub/ontohub-backend/badges/gpa.svg)](https://codeclimate.com/github/ontohub/ontohub-backend)
[![GitHub issues](https://img.shields.io/github/issues/ontohub/ontohub-backend.svg?maxAge=2592000)](https://waffle.io/ontohub/ontohub-backend?source=ontohub%2Fontohub-backend)

# ontohub-backend
The main Ontohub service that serves the data for the frontend and other clients via the [GraphQL API](http://graphql.org/).

## Run the backend in development mode

You need to have the `postgres` and `rabbitmq` services started.
This guide assumes that you have got the [hets-agent](https://github.com/ontohub/hets-agent) located at `../hets-agent` relative to the ontohub-backend repository.

#### With invoker
We use the [invoker](http://invoker.codemancers.com) process manager during development to run all the needed processes with one command.
You can start it with either `bundle exec rails invoker` or `bundle exec invoker start invoker.ini` (the former only calls the latter, but consumes more memory).

#### Manually
Alternatively, you can start the processes yourself by running each of these commands in a separate terminal:
* `bundle exec rails sneakers:run` to run the sneakers workers
* `bundle exec rails server` to run the HTTP server of the backend in development mode
* `pushd ../hets-agent && bin/hets_agent; popd` to run the HetsAgent

#### Access the backend
The backend is then reachable from the browser at [http://localhost:3000](http://localhost:3000).
The interactive GraphiQL console can be accessed at [http://localhost:3000/graphiql](http://localhost:3000/graphiql).

## Dependencies

The backend is implemented in [Ruby on Rails](http://rubyonrails.org).  First,
the Ruby version referenced in the file [.ruby-version](.ruby-version) needs to
be installed, as well as the gem [bundler](http://bundler.io). `git` needs to
be installed as well.  Invoking the command `bundle install` in the directory
of this repository will then install all dependencies of the backend.

## Set up a development environment

In order to set up a complete environment, please refer to the [wiki](https://github.com/ontohub/ontohub-backend/wiki) page [Setting up the development environment](https://github.com/ontohub/ontohub-backend/wiki/Setting-up-the-development-environment).

## Build the REST API documentation

We maintain API documentation with a JSON schema description.
The schemas are located at [spec/support/api/schemas](https://github.com/ontohub/ontohub-backend/tree/master/spec/support/api/schemas).
You can build an HTML-representation of it with [doca](https://github.com/cloudflare/doca).
This requires the tools `npm` and `yarn` to be installed on your system and be in your `PATH`.

First, you need to install doca with npm.
We created a Rake task for this:

    rails apidoc:prepare

Next, you need to create the documentation server files:

    rails apidoc:init

This initialization must be run whenever new schema files are created.

And finally, you can run the API documentation server (the default port is 3002):

    rails apidoc:run
    # or to change the port:
    PORT=8001 rails apidoc:run

Then, visit http://localhost:3002 to see the REST API documentation.
This server listens to changes on the JSON schema files and updates the documentation.
