# frozen_string_literal: true

documents = Rails.root.join('db/seeds/fixtures/documents')

ada_fixtures_repo = RepositoryCompound.find(slug: 'ada/fixtures')

%w(Numbers.casl RelationsAndOrders.casl).each do |file|
  FactoryBot.
    create(:additional_file,
           repository: ada_fixtures_repo,
           commit_message: "Create #{file}",
           user: ada_fixtures_repo.owner,
           path: File.join('Basic', file),
           content: File.read(documents.join(file)),
           encoding: 'plain')
end

FactoryBot.
  create(:additional_commit,
         repository: ada_fixtures_repo,
         user: ada_fixtures_repo.owner,
         commit_message: 'Delete both casl files again.',
         files: [{path: File.join('Basic', 'Numbers.casl'),
                  action: 'remove'},
                 {path: File.join('Basic',
                                  'RelationsAndOrders.casl'),
                  action: 'remove'}])

%w(Numbers.casl RelationsAndOrders.casl).each do |file|
  FactoryBot.
    create(:additional_file,
           repository: ada_fixtures_repo,
           commit_message: "Recreate #{file}.",
           user: ada_fixtures_repo.owner,
           path: File.join('Basic', file),
           content: File.read(documents.join(file)),
           encoding: 'plain')
end

FactoryBot.
  create(:additional_commit,
         repository: ada_fixtures_repo,
         user: ada_fixtures_repo.owner,
         commit_message: 'Create some NativeDocuments.',
         files: [{path: File.join('NativeDocuments', 'cat.clif'),
                  content: File.read(documents.join('cat.clif')),
                  encoding: 'plain',
                  action: 'create'},
                 {path: File.join('NativeDocuments', 'pizza.owl'),
                  content: File.read(documents.join('pizza.owl')),
                  encoding: 'plain',
                  action: 'create'}])

content = "#{File.read(documents.join('Numbers.casl'))}\n"
FactoryBot.
  create(:additional_commit,
         repository: ada_fixtures_repo,
         user: ada_fixtures_repo.owner,
         commit_message: 'Append newline: Numbers.casl.',
         files: [{path: File.join('Basic', 'Numbers.casl'),
                  content: content,
                  encoding: 'plain',
                  action: 'update'}])

FactoryBot.
  create(:additional_commit,
         repository: ada_fixtures_repo,
         user: ada_fixtures_repo.owner,
         commit_message: 'Add newline: NativeDocuments.',
         files: [{path: File.join('NativeDocuments', 'cat.clif'),
                  content: "#{File.read(documents.join('cat.clif'))}\n",
                  encoding: 'plain',
                  action: 'update'},
                 {path: File.join('NativeDocuments', 'pizza.owl'),
                  content: "#{File.read(documents.join('pizza.owl'))}\n",
                  encoding: 'plain',
                  action: 'update'}])

content = "#{File.read(documents.join('RelationsAndOrders.casl'))}\n"
FactoryBot.
  create(:additional_commit,
         repository: ada_fixtures_repo,
         user: ada_fixtures_repo.owner,
         commit_message: 'Append newline: RelationsAndOrders.casl.',
         files: [{path:
                    File.join('Basic', 'RelationsAndOrders.casl'),
                  content: content,
                  encoding: 'plain',
                  action: 'update'}])

# Create some Hets-lib files in a subdirectory, using a UrlMapping

organization_fixtures_repo =
  RepositoryCompound.find(slug: 'seed-user-organization/fixtures')

UrlMapping.create(repository_id: organization_fixtures_repo.id,
                  source: 'Basic/',
                  target: 'Hets-lib/Basic/')

%w(Numbers.casl RelationsAndOrders.casl).each do |file|
  FactoryBot.create(:additional_file,
                     repository: organization_fixtures_repo,
                     commit_message: "Create #{file}",
                     user: User.first(slug: 'ada'),
                     path: File.join('Hets-lib/Basic', file),
                     content: File.read(documents.join(file)),
                     encoding: 'plain')
end
