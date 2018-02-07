# frozen_string_literal: true

RSpec.describe AuthorizedKeysFile do
  describe 'filepath' do
    let(:expected_filepath) { Rails.root.join('tmp/test/data/authorized_keys') }
    it 'has the correct filepath' do
      expect(AuthorizedKeysFile::AUTHORIZED_KEYS_FILE).to eq(expected_filepath)
    end
  end

  describe 'write' do
    let!(:public_keys) { create_list(:public_key, 2) }
    before do
      AuthorizedKeysFile.write
    end

    let(:authorized_keys_lines) do
      File.read(AuthorizedKeysFile::AUTHORIZED_KEYS_FILE).lines
    end

    it 'the file exists' do
      expect(File.exist?(AuthorizedKeysFile::AUTHORIZED_KEYS_FILE)).to be(true)
    end

    it 'writes a line for each public key' do
      expectation = public_keys.all? do |public_key|
        authorized_keys_lines.any? do |line|
          line.match(%r{/bin/git-shell #{public_key.id}"})
        end
      end
      expect(expectation).to be(true)
    end

    it 'has as many lines as there are public keys' do
      expect(authorized_keys_lines.length).to eq(PublicKey.count)
    end

    it 'each line begins with the proper command' do
      authorized_keys_lines.all? do |line|
        expect(line).
          to match(%r{\Acommand="/.*/bin/git-shell \d+"[^"]*\z})
      end
    end

    it 'each line contains the ssh flags' do
      flags = ',no-port-forwarding,no-x11-forwarding,no-agent-forwarding,no-pty'
      authorized_keys_lines.all? do |line|
        expect(line).to match(/"#{flags}/)
      end
    end

    it 'writes each public key into the file' do
      expectation = public_keys.all? do |public_key|
        authorized_keys_lines.any? do |line|
          # rubocop:disable Metrics/LineLength
          regex =
            /#{public_key.id}"\S+ #{public_key.key.strip} #{public_key.name}\n*\z/
          # rubocop:enable Metrics/LineLength
          line.match(regex)
        end
      end
      expect(expectation).to be(true)
    end
  end
end
