# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Version do
  describe 'Read version' do
    let(:version) { '0.0.0-12-gabcdefg' }
    context 'in production mode' do
      before do
        allow(Version).to receive(:production?).and_return(true)
      end

      context 'being successful' do
        before do
          allow(Version).to receive(:read_version_file).and_return(version)
        end

        subject { Version.load_version }

        it 'reads the version correctly' do
          expect(subject).to equal(version)
        end
      end

      context 'being unsuccessful' do
        before do
          allow(Version).to receive(:read_version_file).and_return('')
        end

        it 'fails to determine the version' do
          expect { Version.load_version }.to(
            raise_error(Version::CouldNotDetermineVersion)
          )
        end
      end
    end

    context 'in development mode' do
      before do
        allow(Version).to receive(:production?).and_return(false)
      end

      context 'being successful' do
        before do
          allow(Version).to receive(:read_version_from_git).and_return(version)
        end

        subject { Version.load_version }

        it 'reads the version correctly' do
          expect(subject).to equal(version)
        end
      end

      context 'being unsuccessful' do
        before do
          allow(Version).to receive(:read_version_from_git).and_return('')
        end

        it 'fails to determine the version' do
          expect { Version.load_version }.to(
            raise_error(Version::CouldNotDetermineVersion)
          )
        end
      end
    end
  end
end
