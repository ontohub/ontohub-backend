# frozen_string_literal: true

RSpec.shared_examples 'a password has been reset email sender' do
  it 'sends a notification email' do
    expect(performed_jobs.size).to eq(1)
  end

  let(:email) { emails[0] }

  it 'has the correct recipient' do
    expect(email.to).to match_array([user.email])
  end

  it 'has the correct subject' do
    expect(email.subject).to eq('Password Changed')
  end

  it 'includes the name' do
    expect(email.body.encoded).to include(user.display_name)
  end

  it 'includes a notice about the changed password' do
    expect(email.body.encoded).to include('password has been changed')
  end
end
