require 'spec_helper'
require 'timeout'

describe Kraken::API do

  before(:all) do
    Kraken.configure do |conf|
      conf.s3.api_key = 3
      conf.s3.api_secret = 4
    end
  end

  after(:all) do
    Kraken.configure do |conf|
      conf.s3.api_key = nil
      conf.s3.api_secret = nil
      conf.rackspace.api_key = nil
      conf.rackspace.api_secret = nil
    end
  end

  let(:result) do
    {
      "success" =>  true,
      "file_name" => "header.jpg",
      "original_size" =>  324520,
      "kraked_size" =>  165358,
      "saved_bytes" =>  159162,
      "kraked_url" => "http://dl.kraken.io/ecdfa5c55d5668b1b5fe9e420554c4ee/header.jpg"
    }
  end

  let(:expected_params) { {} }

  let(:json_body) do 
    Hash[expected_params.sort].to_json
  end

  subject { Kraken::API.new(1, 2) }

  describe '#async' do
    let(:expected_params) do
      {
          'wait' => true,
          'auth' => { 'api_key' => 1, 'api_secret' => 2},
          'url' => 'http://farts.gallery',
      }
    end

    it 'returns the result eventually' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)

      defer = nil
      immediate = subject.async.url('http://farts.gallery') do |result|
        defer = result.kraked_url
      end

      expect(immediate).to be_nil

      Timeout.timeout(2) do
        loop until defer
      end

      expect(defer).to eq result['kraked_url']
    end
  end

  describe '#callback' do
    let(:expected_params) do
      {
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'callback_url' => 'http://seriouslylike.omg',
        'url' => 'http://farts.gallery',
        'wait' => true
      }
    end

    let(:result) do
      {
        "id" => "18fede37617a787649c3f60b9f1f280d"
      }
    end

    it 'uses the call back and runs async' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)

      res = subject.callback_url('http://seriouslylike.omg').url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#lossy' do
    let(:expected_params) do
      {
        'wait' => true,
        'lossy' => true,
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'url' => 'http://farts.gallery'
      }
    end

    it 'calls with lossy' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)

      res = subject.lossy.url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#webp' do
    let(:expected_params) do
      {
        'wait' => true,
        'webp' => true,
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'url' => 'http://farts.gallery'
      }
    end

    it 'calls with webp' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)

      res = subject.webp.url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#resize' do
    let(:expected_params) do
      {
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'resize' => {
          'height' => 75,
          'strategy' => 'crop',
          'width' => 45
        },
        'wait' => true,
        'url' => 'http://farts.gallery/image4.jpg'
      }
    end

    before do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)
    end

    it 'calls with width, height and specified strategy' do
      subject.resize(width: 45, height: 75).crop.url('http://farts.gallery/image4.jpg')
    end

    it 'works in either order' do
      subject.crop.resize(width: 45, height: 75).url('http://farts.gallery/image4.jpg')
    end

    it "raises an ArgumentError if width or height aren't provided" do
      expect { subject.resize(width: 45) }.to raise_error(ArgumentError)
      expect { subject.resize(height: 45) }.to raise_error(ArgumentError)
    end

  end

  describe '#s3' do
    let(:base_params) do
      {
        wait:  true,
        auth:  { 'api_key' => 1, 'api_secret' => 2},
        url:   'http://farts.gallery/image.jpg'
      }
    end

    before do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)
    end

    # do some READMEdd here
    context 'with default parameters' do
       let(:expected_params) do
          base_params.reverse_merge({
            s3_store: {
              bucket: 'images.s3-bucket.com',
              key: 3,
              secret: 4
            }
          })
        end

       it 'succeeds' do
         res = subject.s3('images.s3-bucket.com').url('http://farts.gallery/image.jpg')
         expect(res.code).to eq 200
      end
    end

    context 'with acls' do
      let(:expected_params) do
        base_params.reverse_merge({
          s3_store: {
            acl: 'private',
            bucket: 'images.s3-bucket.com',
            key: 3,
            secret: 4
          }
        })
      end

      it 'succeeds' do
        res = subject.s3('images.s3-bucket.com', acl: :private).url('http://farts.gallery/image.jpg')
        expect(res.code).to eq 200
      end
    end

    context 'with invalid acls' do

      it 'does not succeed' do
        expect {
          subject.s3('images.s3-bucket.com', acl: :dudes_with_hats).url('http://farts.gallery/image.jpg')
        }.to raise_error ArgumentError
      end

    end

    context 'with specific path' do
      let(:expected_params) do
        base_params.reverse_merge({
          s3_store: {
            bucket: 'images.s3-bucket.com',
            key: 3,
            path: '/something/a/thing.jpg',
            secret: 4
          }
        })
      end

      it 'succeeds' do
        res = subject.s3('images.s3-bucket.com', path: '/something/a/thing.jpg').url('http://farts.gallery/image.jpg')
        expect(res.code).to eq 200
      end
    end
  end

  describe '#rackspace' do
    before do
      Kraken.configure do |conf|
        conf.rackspace.api_key = 3
        conf.rackspace.api_secret = 4
      end
    end

    let(:base_params) do
      {
        wait:  true,
        auth:  { 'api_key' => 1, 'api_secret' => 2},
        url:   'http://farts.gallery/image.jpg'
      }
    end

    before do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)
    end

    # do some READMEdd here
    context 'with default parameters' do
       let(:expected_params) do
          base_params.reverse_merge({
            cf_store: {
              container: 'images.s3-bucket.com',
              key: 3,
              secret: 4
            }
          })
        end

       it 'succeeds' do
         res = subject.rackspace('images.s3-bucket.com').url('http://farts.gallery/image.jpg')
         expect(res.code).to eq 200
      end
    end

    context 'with specific path' do
      let(:expected_params) do
        base_params.reverse_merge({
          cf_store: {
            container: 'images.s3-bucket.com',
            key: 3,
            path: '/something/a/thing.jpg',
            secret: 4
          }
        })
      end

      it 'succeeds' do
        res = subject.rackspace('images.s3-bucket.com', path: '/something/a/thing.jpg').url('http://farts.gallery/image.jpg')
        expect(res.code).to eq 200
      end
    end
  end

  describe '#url' do
    let(:expected_params) do
      {
        'wait' => true,
        'auth' => { 'api_key' => 1, 'api_secret' => 2},
        'url' => 'http://farts.gallery'
      }
    end

    it 'provides a url to the kraken api' do
      stub_request(:post, "https://api.kraken.io/v1/url")
        .with(:body => json_body).to_return(body: result.to_json)

      res = subject.url('http://farts.gallery')
      expect(res.code).to eq 200
    end
  end

  describe '#upload' do
    let(:expected_params) do
      {
        'wait' => true,
        'auth' => { 'api_key' => 1, 'api_secret' => 2}
      }
    end

    it 'uploads multipart form data to the server' do
      stub_request(:post, "https://api.kraken.io/v1/upload").with do |req|
        expect(req.body).to include(json_body)
        expect(req.body).to include('filename="test.gif"')
        expect(req.headers['Content-Type']).to include('multipart/form-data')
      end.to_return(body: result.to_json)

      res = subject.upload(File.expand_path('test.gif', File.dirname(__FILE__)))
      expect(res).to be_kind_of Kraken::Response
    end
  end
end
