# frozen_string_literal: true

[{name: 'ada', display_name: 'Ada Lovelace'}, {name: 'bob'}].each do |userinfo|
  user = User.new(userinfo.
                  merge(email: "#{userinfo[:name]}@example.com",
                        role: 'user',
                        url_path_method: ModelURLPath.user))
  user.password = 'changemenow'
  user.confirmed_at = Time.now
  user.save
end
