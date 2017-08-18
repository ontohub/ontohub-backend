# frozen_string_literal: true

repository = RepositoryCompound.wrap(Repository.find(slug: 'ada/repo0'))

# Commit new images
%w(jpg png svg).each do |file_type|
  file = Base64.encode64(File.read(Rails.root.
    join("db/seeds/fixtures/ontohub.#{file_type}")))

  FactoryGirl.create(:additional_commit,
                     repository: repository,
                     user: repository.owner,
                     files: [{path: "icons/ontohub.#{file_type}",
                              content: file,
                              encoding: 'base64',
                              action: 'create'}])
end

# Commit new text
text = File.read(Rails.root.join('db/seeds/fixtures/ontohub.txt'))
path = 'texts/ontohub.txt'

FactoryGirl.create(:additional_file,
                   repository: repository,
                   user: repository.owner,
                   path: path,
                   content: text,
                   encoding: 'plain')

# Change new text
new_content = <<~TEXT
  Ontohub

  An open source repository engine for ontologies, models and specifications.

  Open — based on open source software.
  Flexible — supporting OWL, UML, FOL/TPTP, HOL/THF, and more
  Distributed — OMS alignments, mappings, networks, combinations using DOL.
TEXT

FactoryGirl.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: path,
                             content: new_content,
                             encoding: 'plain',
                             action: 'update'}])

# Commit new pdf
pdf = Base64.encode64(File.read(Rails.root.
  join('db/seeds/fixtures/ontohub.pdf')))

FactoryGirl.create(:additional_file,
                   repository: repository,
                   user: repository.owner,
                   path: 'pdf/ontohub.pdf',
                   content: pdf,
                   encoding: 'base64')

# Commit changes multiple files
to_be_changed = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_changed.txt'))
to_be_changed_path = 'texts/ontohub_changed.txt'
changed_text = <<~TEXT
  The main Ontohub service that serves the data for the frontend and other
  clients via the GraphQL API!
TEXT

to_be_renamed = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_renamed.txt'))
to_be_renamed_path = 'texts/ontohub_to_be_renamed.txt'

to_be_changed_and_renamed = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_changed_and_renamed.txt'))
to_be_changed_and_renamed_path = 'texts/ontohub_to_be_changed_and_renamed.txt'
changed_renamed_text = <<~TEXT
  Ontohub is an awesome thing.
TEXT

to_be_removed = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_removed.txt'))
to_be_removed_path = 'texts/ontohub_removed.txt'

to_be_created = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_created.txt'))
to_be_created_path = 'texts/ontohub_created.txt'

FactoryGirl.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: to_be_changed_path,
                             content: to_be_changed,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_renamed_path,
                             content: to_be_renamed,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_changed_and_renamed_path,
                             content: to_be_changed_and_renamed,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_removed_path,
                             content: to_be_removed,
                             encoding: 'plain',
                             action: 'create'}])

FactoryGirl.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: to_be_changed_path,
                             content: changed_text,
                             encoding: 'plain',
                             action: 'update'},
                            {path: 'texts/ontohub_renamed.txt',
                             previous_path: to_be_renamed_path,
                             action: 'rename'},
                            {path: 'texts/ontohub_changed_renamed.txt',
                             previous_path: to_be_changed_and_renamed_path,
                             content: changed_renamed_text,
                             encoding: 'plain',
                             action: 'update'},
                            {path: 'new_folder/',
                             action: 'mkdir'},
                            {path: 'texts/ontohub_removed.txt',
                             action: 'remove'},
                            {path: to_be_created_path,
                             content: to_be_created,
                             encoding: 'plain',
                             action: 'create'}])
