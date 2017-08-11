# frozen_string_literal: true

# Create users
[{name: 'ada', display_name: 'Ada Lovelace', role: 'user'},
 {name: 'bob', role: 'admin'},
 {name: 'cam', display_name: 'Cam Pino', role: 'user'}].each do |userinfo|
  user = User.new(userinfo.
                  merge(email: "#{userinfo[:name]}@example.com",
                        role: userinfo[:role].to_s,
                        url_path_method: ModelURLPath.user))
  user.password = 'changemenow'
  user.confirmed_at = Time.now
  user.save
end
