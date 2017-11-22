# frozen_string_literal: true

repository = RepositoryCompound.wrap(Repository.first(slug: 'ada/fixtures'))

# Commit new images
%w(jpg png svg).each do |file_type|
  file = Base64.encode64(File.read(Rails.root.
    join("db/seeds/fixtures/ontohub.#{file_type}")))

  FactoryBot.create(:additional_file,
                     repository: repository,
                     user: repository.owner,
                     path: "icons/ontohub.#{file_type}",
                     content: file,
                     encoding: 'base64')
end

# Commit new text
text = File.read(Rails.root.join('db/seeds/fixtures/ontohub.txt'))
path = 'texts/ontohub.txt'

FactoryBot.create(:additional_file,
                   repository: repository,
                   user: repository.owner,
                   path: path,
                   content: text,
                   encoding: 'plain')

# Change new text
new_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_new_content.txt'))

FactoryBot.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: path,
                             content: new_content,
                             encoding: 'plain',
                             action: 'update'}])

# Commit new pdf
pdf = Base64.encode64(File.read(Rails.root.
  join('db/seeds/fixtures/ontohub.pdf')))

FactoryBot.create(:additional_file,
                   repository: repository,
                   user: repository.owner,
                   path: 'pdf/ontohub.pdf',
                   content: pdf,
                   encoding: 'base64')

# Commit changes in multiple files
to_be_changed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_changed.txt'))
to_be_changed_path = 'texts/ontohub_changed.txt'
changed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_changed_text.txt'))

to_be_renamed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_renamed.txt'))
to_be_renamed_path = 'texts/ontohub_to_be_renamed.txt'

to_be_changed_and_renamed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_changed_and_renamed.txt'))
to_be_changed_and_renamed_path = 'texts/ontohub_to_be_changed_and_renamed.txt'
changed_renamed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_changed_renamed_text.txt'))

to_be_removed_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_removed.txt'))
to_be_removed_path = 'texts/ontohub_removed.txt'

to_be_created_content = File.read(Rails.root.
  join('db/seeds/fixtures/ontohub_to_be_created.txt'))
to_be_created_path = 'texts/ontohub_created.txt'

FactoryBot.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: to_be_changed_path,
                             content: to_be_changed_content,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_renamed_path,
                             content: to_be_renamed_content,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_changed_and_renamed_path,
                             content: to_be_changed_and_renamed_content,
                             encoding: 'plain',
                             action: 'create'},
                            {path: to_be_removed_path,
                             content: to_be_removed_content,
                             encoding: 'plain',
                             action: 'create'}])

FactoryBot.create(:additional_commit,
                    repository: repository,
                    user: repository.owner,
                    files: [{path: to_be_changed_path,
                             content: changed_content,
                             encoding: 'plain',
                             action: 'update'},
                            {new_path: 'texts/ontohub_renamed.txt',
                             path: to_be_renamed_path,
                             action: 'rename'},
                            {new_path: 'texts/ontohub_changed_renamed.txt',
                             path: to_be_changed_and_renamed_path,
                             content: changed_renamed_content,
                             encoding: 'plain',
                             action: 'rename_and_update'},
                            {path: 'new_folder/',
                             action: 'mkdir'},
                            {path: 'texts/ontohub_removed.txt',
                             action: 'remove'},
                            {path: to_be_created_path,
                             content: to_be_created_content,
                             encoding: 'plain',
                             action: 'create'}])
