# frozen_string_literal: true

RSpec.describe(SettingsSchema) do
  subject { Dry::Validation.Schema(SettingsSchema).call(settings) }
  let(:settings) { create :settings }

  before do
    allow(File).to receive(:directory?).and_call_original
    [settings[:data_directory]].each do |dir|
      allow(File).to receive(:directory?).with(dir).and_return(true)
    end
    [settings[:git_shell][:copy_authorized_keys_executable],
     settings[:git_shell][:path]].each do |file|
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
        settings[:jwt] = settings[:jwt].merge(expiration_hours: nil)
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
      %i(copy_authorized_keys_executable path).each do |field|
        it "#{field} is nil" do
          settings[:git_shell][field] = nil
          expect(subject.errors).
            to include(git_shell: include(field => ['must be filled']))
      end
    end
    
    context 'elasticsearch' do
      context 'host' do
        it 'is nil' do
          settings[:elasticsearch][:host] = nil
          expect(subject.errors).
            to include(elasticsearch: include(host: ['must be filled']))
        end

        it 'is maltyped' do
          settings[:elasticsearch][:host] = 0
          expect(subject.errors).
            to include(elasticsearch: include(host: ['must be a string']))
        end
      end

      context 'port' do
        it 'is nil' do
          settings[:elasticsearch][:port] = nil
          expect(subject.errors).
            to include(elasticsearch: include(port: ['must be filled']))
        end

        it 'is maltyped' do
          settings[:elasticsearch][:port] = 'string'
          expect(subject.errors).
            to include(elasticsearch: include(port: ['must be an integer']))
        end
      end

      context 'prefix' do
        it 'is string' do
          settings[:elasticsearch][:prefix] = 'string'
          expect(subject.errors).to be_empty
        end
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
      %i(copy_authorized_keys_executable path).each do |field|
        context 'path' do
          let(:field_value) { settings[:git_shell][field] }

          context 'bad type' do
            let(:field_value) { 1 }

            it 'is not a String type' do
              settings[:git_shell][field] = field_value
              expect(subject.errors).
                to include(git_shell: include(field => ['must be a string']))
            end
          end

          it 'is not a file' do
            allow(File).
              to receive(:file?).
              with(field_value.to_s).
              and_return(false)
            expect(subject.errors).
              to include(git_shell:
                           include(field => ['is not an executable file']))
          end

          it 'is not an _executable_ file' do
            allow(File).
              to receive(:executable?).
              with(field_value.to_s).
              and_return(false)
            expect(subject.errors).
              to include(git_shell:
                           include(field =>
                                     ['is not an executable file']))
          end
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
