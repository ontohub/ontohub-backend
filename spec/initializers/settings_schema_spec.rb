# frozen_string_literal: true

RSpec.describe(SettingsSchema) do
  subject { Dry::Validation.Schema(SettingsSchema).call(settings) }
  let(:settings) { create :settings }

  before do
    allow(File).to receive(:directory?).and_call_original
    [settings[:data_directory]].each do |dir|
      allow(File).to receive(:directory?).with(dir).and_return(true)
    end
    [settings[:git_shell][:path]].each do |file|
      allow(File).to receive(:file?).with(file).and_return(true)
      allow(File).to receive(:executable?).with(file).and_return(true)
    end
  end

  it 'passes' do
    expect(subject.errors).to be_empty
  end

  context 'fails if the' do
    it 'server_url is nil' do
      settings[:server_url] = nil
      expect(subject.errors).
        to include(server_url: ['must be filled'])
    end

    context 'jwt' do
      it 'expiration_hours is nil' do
        settings[:jwt][:expiration_hours] = nil
        expect(subject.errors).
          to include(jwt: {expiration_hours: ['must be filled']})
      end
    end

    it 'data_directory is nil' do
      settings[:data_directory] = nil
      expect(subject.errors).
        to include(data_directory: ['must be filled'])
    end

    context 'git_shell' do
      it 'path is nil' do
        settings[:git_shell][:path] = nil
        expect(subject.errors).
          to include(git_shell: include(path: ['must be filled']))
      end
    end

    context 'rabbitmq' do
      %i(host username password virtual_host).each do |field|
        context field.to_s do
          it 'is nil' do
            settings[:rabbitmq][field] = nil
            expect(subject.errors).
              to include(rabbitmq: {field => ['must be filled']})
          end

          it 'is maltyped' do
            settings[:rabbitmq][field] = 0
            expect(subject.errors).
              to include(rabbitmq: {field => ['must be a string']})
          end
        end
      end
      context 'port' do
        it 'is nil' do
          settings[:rabbitmq][:port] = nil
          expect(subject.errors).
            to include(rabbitmq: {port: ['must be filled']})
        end

        it 'is maltyped' do
          settings[:rabbitmq][:port] = 'string'
          expect(subject.errors).
            to include(rabbitmq: {port: ['must be an integer']})
        end
      end
    end

    context 'server_url' do
      it 'is not a string' do
        settings[:server_url] = 0
        expect(subject.errors).to include(server_url: ['must be a string'])
      end

      it 'has a bad schema' do
        settings[:server_url] = 'gopher://example.com'
        expect(subject.errors).to include(
          server_url: ['has an invalid scheme (only http, https are allowed)']
        )
      end

      it 'has a path' do
        settings[:server_url] = 'http://example.com/some_path'
        expect(subject.errors).to include(server_url: ['must not have a path'])
      end

      it 'has a query string' do
        settings[:server_url] = 'http://example.com?query_string'
        expect(subject.errors).
          to include(server_url: ['must not have a query string'])
      end

      it 'has a fragment' do
        settings[:server_url] = 'http://example.com#fragment'
        expect(subject.errors).
          to include(server_url: ['must not have a fragment'])
      end

      it 'contains user info' do
        settings[:server_url] = 'http://user:pass@example.com'
        expect(subject.errors).
          to include(server_url: ['must not have user info'])
      end
    end

    context 'jwt' do
      context 'expiration_hours' do
        it 'is not a Numeric type' do
          settings[:jwt][:expiration_hours] = 'bad'
          expect(subject.errors).to include(
            jwt: {expiration_hours: ['must be an integer or must be a float']}
          )
        end
      end
    end

    context 'data_directory' do
      before do
        allow(File).
          to receive(:directory?).
          with(settings[:data_directory]).
          and_return(false)
        allow(File).
          to receive(:exist?).
          with(settings[:data_directory]).
          and_return(true)
      end

      it 'is not a directory or cannot be created' do
        expect(subject.errors).to include(
          data_directory: ['is not a directory or cannot not be created']
        )
      end
    end

    context 'git_shell' do
      context 'path' do
        let(:path) { settings[:git_shell][:path] }

        context 'bad type' do
          let(:path) { 1 }

          it 'is not a String type' do
            settings[:git_shell][:path] = path
            expect(subject.errors).
              to include(git_shell: include(path: ['must be a string']))
          end
        end

        it 'is not a file' do
          allow(File).to receive(:file?).with(path.to_s).and_return(false)
          expect(subject.errors).
            to include(git_shell: include(path: ['is not an executable file']))
        end

        it 'is not an _executable_ file' do
          allow(File).to receive(:executable?).with(path.to_s).and_return(false)
          expect(subject.errors).
            to include(git_shell: include(path: ['is not an executable file']))
        end
      end
    end

    context 'sneakers' do
      it 'is not an Array type' do
        settings[:sneakers] = 'bad'
        expect(subject.errors).to include(sneakers: ['must be an array'])
      end

      context 'workers' do
        it 'is not an integer' do
          settings[:sneakers] = [workers: 'bad']
          expect(subject.errors).to include(
            sneakers: {0 => include(workers: ['must be an integer'])}
          )
        end
      end

      context 'classes' do
        it 'is not an Array or String type' do
          settings[:sneakers] = [classes: 123]
          expect(subject.errors).to include(sneakers: {0 => include(
            classes: ['must be a worker class or a list of worker classes']
          )})
        end

        it 'is not a valid worker class' do
          settings[:sneakers] = [classes: ['BadClass']]
          expect(subject.errors).to include(sneakers: {0 => include(
            classes: ['must be a worker class or a list of worker classes']
          )})
        end
      end
    end
  end
end
