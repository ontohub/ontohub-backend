# frozen_string_literal: true

RSpec.describe(Popen) do
  it 'returns the output' do
    out, _status = Popen.popen(%w(echo message))
    expect(out).to eq("message\n")
  end

  it 'returns the correct exit code on success' do
    _out, status = Popen.popen(%w(bash -c) + ['test -z ""'])
    expect(status).to be_zero
  end

  it 'returns the correct exit code on failure' do
    _out, status = Popen.popen(%w(bash -c) + ['test -n ""'])
    expect(status).to eq(1)
  end

  it 'raises an error on bad parameters' do
    expect { Popen.popen(%(/usr/bin/false)) }.to raise_error(/array of strings/)
  end

  it 'changes the working directory' do
    dir = Dir.mktmpdir
    out, _status = Popen.popen(%w(pwd), dir)
    expect(out).to eq("#{dir}\n")
    Dir.rmdir(dir)
  end

  it 'sets environment variables' do
    vars = {'VARIABLE1' => 'value1', 'VARIABLE2' => 'value2'}
    vars.each do |variable, value|
      out, _status = Popen.popen(%w(bash -c) + ["echo $#{variable}"], nil, vars)
      expect(out).to eq("#{value}\n")
    end
  end
end
