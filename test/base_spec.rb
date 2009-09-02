require 'sinatra'
require 'sinatra/test/rspec'
require File.dirname(__FILE__) + '/../mini'

describe 'Rubysztan' do
  it 'should have default page' do
    get '/'
    @response.should be_ok
  end
end