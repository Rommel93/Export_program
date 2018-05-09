require 'spec_helper'

describe 'tomcat_cookbook::default' do
   describe command('curl http://localhost:8080') do
    it (:stdout) { should match /Tomcat/ }
  end
end
