# frozen_string_literal: true

RSpec.shared_examples 'a password reset email sender' do
  it 'sends an instructions email' do
    expect(performed_jobs.size).to eq(1)
    expect(UsersMailer.deliveries.size).to eq(1)
  end

  let(:email) { emails[0] }

  it 'is has the correct recipient' do
    expect(email.to).to match_array([user.email])
  end

  it 'is has the correct subject' do
    expect(email.subject).to eq('Reset password instructions')
  end

  it 'includes the name' do
    expect(email.body.encoded).to include(user.display_name)
  end

  it 'includes the reset password token' do
    expect(email.body.encoded).
      to match(/Your reset password token is: [^\n]+\n/)
  end

  it 'includes a reset password link' do
    # rubocop:disable Metrics/LineLength
    link = %r{<a href="http://example.test/account/edit-password\?reset_password_token=[^"]+">Change my password</a>}
    # rubocop:enable Metrics/LineLength
    expect(email.body.encoded).to match(link)
  end
end
