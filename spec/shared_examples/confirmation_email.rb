# frozen_string_literal: true

RSpec.shared_examples 'a confirmation email sender' do |additional_jobs = 0|
  it 'sends an email' do
    expect(performed_jobs.size).to eq(1 + additional_jobs)
    expect(UsersMailer.deliveries.size).to eq(1)
  end

  it 'is has the correct recipient' do
    expect(last_email.to).to match_array([user.email])
  end

  it 'is has the correct subject' do
    expect(last_email.subject).to eq('Confirmation instructions')
  end

  it 'includes the name' do
    expect(last_email.body.encoded).to include(user.display_name)
  end

  it 'includes the confirmation token' do
    expect(last_email.body.encoded).
      to include(User.first(email: user.email).confirmation_token)
  end

  it 'includes a confirmation link' do
    persisted_user = User.first(email: user.email)
    token = persisted_user.confirmation_token
    # rubocop:disable Metrics/LineLength
    link = %(<a href="http://example.test/account/confirm-email?confirmation_token=#{token}">Confirm my account</a>)
    # rubocop:enable Metrics/LineLength
    expect(last_email.body.encoded).to include(link)
  end
end
