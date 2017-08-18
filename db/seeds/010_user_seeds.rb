# frozen_string_literal: true

# Create users
[{name: 'admin', role: 'admin'},
 {name: 'ada', display_name: 'Ada Lovelace', role: 'user'},
 {name: 'bob', role: 'user'},
 {name: 'cam', display_name: 'Cam Pino', role: 'user'},
 {name: 'dan', role: 'user'},
 {name: 'eva', role: 'user'},
 {name: 'flo', role: 'user'}].each do |userinfo|
  user = User.new(userinfo.
                  merge(email: "#{userinfo[:name]}@example.com",
                        role: userinfo[:role],
                        url_path_method: ModelURLPath.user))
  user.password = 'changemenow'
  user.confirmed_at = Time.now
  user.save
end
