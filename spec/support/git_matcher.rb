# frozen_string_literal: true

RSpec::Matchers.define :match_blob do |expected|
  match do |actual|
    %i(id name path size).all? do |attribute|
      expected.send(attribute) == actual.send(attribute)
    end
  end
end

RSpec::Matchers.define :match_branches do |expected|
  match do |actual|
    %i(name target dereferenced_target).each do |attribute|
      expect(expected.map(&attribute)).to match_array(actual.map(&attribute))
    end
  end
end

RSpec::Matchers.define :match_commit do |expected|
  match do |actual|
    %i(author_email author_name authored_date
       committer_email committer_name committed_date
       id message).all? do |attribute|
      expected.send(attribute) == actual.send(attribute)
    end
  end
end

RSpec::Matchers.define :match_git_date do |expected|
  match do |actual|
    (expected - actual).to_f.abs < 1.seconds
  end
end

RSpec::Matchers.define :match_tree do |expected|
  match do |actual|
    %i(name path root_id type).each do |attribute|
      expect(expected.map(&attribute)).to match_array(actual.map(&attribute))
    end
  end
end
