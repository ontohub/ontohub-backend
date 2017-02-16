# frozen_string_literal: true

def exec_silently(cmd, working_directory = nil)
  out, status = Popen.popen(['bash', '-c', cmd], working_directory)
  return if status.zero?
  # :nocov:
  raise "Command failed!\n#{cmd}\nExit status: #{status}\nOutput:\n#{out}\n"
  # :nocov:
end

FactoryGirl.define do
  sequence(:svn_repository_path_bare) do |n|
    File.join(Dir.pwd, 'svn_repositories_bare', n.to_s).to_s
  end

  sequence(:svn_repository_path_work) do |n|
    File.join(Dir.pwd, 'svn_repositories_work', n.to_s).to_s
  end

  sequence(:svn_branch_name) do |n|
    "my-branch-#{n}"
  end

  factory :svn_repository, class: Array do
    skip_create
    initialize_with do
      path_bare = generate(:svn_repository_path_bare)
      path_work = generate(:svn_repository_path_work)
      bare_dirname = File.dirname(path_bare)
      FileUtils.mkdir_p(bare_dirname)
      Dir.chdir(bare_dirname) do
        exec_silently("svnadmin create #{File.basename(path_bare)}")
        exec_silently("svn co file://#{path_bare} #{path_work}")
      end

      [path_bare, path_work]
    end
  end

  trait :with_svn_standard_layout do
    after(:create) do |(_svn_bare_path, svn_work_path)|
      %w(branches tags trunk).each do |dir|
        FileUtils.mkdir_p(File.join(svn_work_path, dir))
        exec_silently("svn add #{dir}", svn_work_path)
      end
      exec_silently("svn commit -m 'Setup standard layout'",
                    svn_work_path)
    end
  end

  trait :with_svn_branches do
    transient do
      branch_count 1
    end

    after(:create) do |(_svn_bare_path, svn_work_path), evaluator|
      branches = (1..evaluator.branch_count).map do
        generate(:svn_branch_name)
      end

      unless File.directory?(File.join(svn_work_path, 'trunk'))
        # :nocov:
        raise 'Only can create a branch in an svn stanard layout.'
        # :nocov:
      end

      branches.each do |branch|
        full_filepath = File.join(svn_work_path, 'branches', branch)
        FileUtils.mkdir_p(full_filepath)
        exec_silently("svn add #{full_filepath}", svn_work_path)
      end
      exec_silently("svn commit -m 'Add branches.'", svn_work_path)
    end
  end

  trait :with_svn_commits do
    transient do
      commit_count 1
    end

    after(:create) do |(_svn_bare_path, svn_work_path), evaluator|
      commit_files = (1..evaluator.commit_count).map { generate(:filepath) }
      commit_files.each do |filepath|
        full_filepath =
          if File.directory?(File.join(svn_work_path, 'trunk'))
            File.join(svn_work_path, 'trunk', filepath)
          else
            File.join(svn_work_path, filepath)
          end
        FileUtils.mkdir_p(File.dirname(full_filepath))
        File.write(full_filepath, "#{Faker::Lorem.sentence}\n")
        exec_silently("svn add '#{File.dirname(full_filepath)}'", svn_work_path)
        exec_silently("svn commit -m '#{generate(:commit_message)}'",
                      svn_work_path)
      end
    end
  end
end
