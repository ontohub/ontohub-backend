# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tree do
  context 'attributes' do
    subject { create :tree }

    %i(commit_id entries id path repository).each do |attribute|
      it "contain a getter for #{attribute}" do
        expect(subject).to respond_to(attribute)
      end

      it "contain a setter for #{attribute}" do
        expect(subject).to respond_to("#{attribute}=")
      end
    end
  end

  context 'with a real git repository' do
    let(:repository) { create(:repository_compound) }
    subject do
      create(:tree, repository: repository, commit_id: 'master', path: '/',
                    entries: repository.git.tree('master', '/'))
    end

    context 'that has no files on a branch' do
      before do
        repository.git.ls_files('master').each do |filepath|
          repository.git.remove_file(file: {path: filepath},
                                     author: generate(:git_user),
                                     committer: generate(:git_user),
                                     commit: {message: 'delete',
                                              branch: 'master'})
        end
      end

      subject do
        Tree.find(repository_id: repository.to_param,
                  branch: 'master', path: '/')
      end

      it 'is a Tree' do
        expect(subject).to be_a(Tree)
      end

      it 'has no entries' do
        expect(subject.entries).to be_empty
      end
    end

    context '.new' do
      it 'has the correct names' do
        expect(subject.entries.map(&:name)).
          to match_array(repository.git.tree('master', '/').map(&:name))
      end

      it 'has the correct paths' do
        expect(subject.entries.map(&:path)).
          to match_array(repository.git.tree('master', '/').map(&:path))
      end

      it 'has the correct types' do
        expect(subject.entries.map(&:type)).
          to match_array(repository.git.tree('master', '/').
                           map { |entry| entry.type.to_s.pluralize.to_sym })
      end
    end

    context '.find' do
      subject do
        Tree.find(repository_id: repository.to_param,
                  branch: 'master', path: '/')
      end

      it "returns nil if the branch doesn't exist" do
        expect(Tree.find(repository_id: repository.to_param,
                         branch: 'inexistent-branch', path: '/')).
          to be(nil)
      end

      it "returns nil if the path doesn't exist" do
        expect(Tree.find(repository_id: repository.to_param,
                         branch: 'master', path: 'inexistent-path')).
          to be(nil)
      end

      it 'has the correct names' do
        expect(subject.entries.map(&:name)).
          to match_array(repository.git.tree('master', '/').map(&:name))
      end

      it 'has the correct paths' do
        expect(subject.entries.map(&:path)).
          to match_array(repository.git.tree('master', '/').map(&:path))
      end

      it 'has the correct types' do
        expect(subject.entries.map(&:type)).
          to match_array(repository.git.tree('master', '/').
                           map { |entry| entry.type.to_s.pluralize.to_sym })
      end
    end

    context '.find on subpath' do
      let(:subpath) { repository.git.tree('master', '/').first.path }
      subject do
        Tree.find(repository_id: repository.to_param,
                  branch: 'master', path: subpath)
      end

      it 'has the correct names' do
        expect(subject.entries.map(&:name)).
          to match_array(repository.git.tree('master', subpath).map(&:name))
      end

      it 'has the correct paths' do
        expect(subject.entries.map(&:path)).
          to match_array(repository.git.tree('master', subpath).map(&:path))
      end

      it 'has the correct types' do
        expect(subject.entries.map(&:type)).
          to match_array(repository.git.tree('master', subpath).
                           map { |entry| entry.type.to_s.pluralize.to_sym })
      end

      it 'builds the correct url' do
        prefix = Settings.server_url
        expect(subject.url(prefix)).to eq([Settings.server_url,
                                           repository.to_param,
                                           'ref',
                                           subject.git.branch_sha('master'),
                                           'tree',
                                           subpath].join('/'))
      end

      it 'builds the correct url_path' do
        expect(subject.url_path).to eq(['',
                                        repository.to_param,
                                        'ref',
                                        subject.git.branch_sha('master'),
                                        'tree',
                                        subpath].join('/'))
      end
    end
  end
end
