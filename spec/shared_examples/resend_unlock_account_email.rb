# frozen_string_literal: true

RSpec.shared_examples 'an unlock account email sender' do
  it 'sends an instructions email' do
    expect(UsersMailer.deliveries.size).to eq(1)
  end

  it 'is has the correct recipient' do
    expect(last_email.to).to match_array([user.email])
  end

  it 'is has the correct subject' do
    expect(last_email.subject).to eq('Unlock instructions')
  end

  it 'includes the name' do
    expect(last_email.body.encoded).to include(user.display_name)
  end

  it 'includes the unlock token' do
    expect(last_email.body.encoded).
      to match(/^Your unlock token is: \S+\s*$/)
  end

  it 'includes a unlock link' do
    # rubocop:disable Metrics/LineLength
    link = %r{<a href="http://example.test/users/unlock\?unlock_token=[^"]+">Unlock my account</a>}
    # rubocop:enable Metrics/LineLength
    expect(last_email.body.encoded).to match(link)
  end
end
