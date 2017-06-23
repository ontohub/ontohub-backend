# frozen_string_literal: true

# Setup time zone for sequel such that it gets converted before storing into the
# database and after loading from the database correctly.
Sequel.default_timezone = Time.now.getlocal.zone
