require 'spec_helper'
describe 'update' do
  context 'with default values for all parameters' do
    it { should contain_class('update') }
  end
end
