require 'spec_helper'

describe Kraken do

  after(:all) do
    Kraken.configure do |conf|
      conf.api_key = nil
      conf.api_secret = nil
      conf.s3.api_key = nil
      conf.s3.api_secret = nil
    end
  end

  it 'saves the config' do
    Kraken.configure do |conf|
      conf.api_key = 1
      conf.api_secret = 2
      conf.s3.api_key = 3 
      conf.s3.api_secret = 4
    end

    expect(Kraken.api_key).to eq 1
    expect(Kraken.api_secret).to eq 2
    expect(Kraken.s3.api_key).to eq 3
    expect(Kraken.s3.api_secret).to eq 4
  end

  describe Kraken::Credentials do
    subject { Kraken::Credentials.new }
    it { should respond_to :api_key  }
    it { should respond_to :api_secret   }
    it { should respond_to :api_key= }
    it { should respond_to :api_secret=  }
    it { should respond_to :service  }

    it 'has api_key/api_secret configs for other services' do
      expect(Kraken.s3.service).to eq :s3
      expect(Kraken.rackspace.service).to eq :rackspace
    end
  end
end
