Given /^the next request will receive a (bad request|not found|bad gateway|server error|rate limit) response$/ do |type|
  statuses = {
    'bad request' => ['400', 'Bad Request'],
    'not found' => ['404', 'Not Found'],
    'bad gateway' => ['502', 'Bad Gateway'],
    'server error' => ['500', 'Server Error'],
    'rate limit' => ['503', 'Rake Limited']
  }
  
  if status = statuses[type]
    FakeWeb.register_uri(:get, /\/clients/, [
      {:status => status, :times => 1},
      {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
    ])
  else
    pending
  end
end

Given /^the next request to (\/.+) will receive a (bad request|not found|bad gateway|server error|rate limit) response$/ do |path, type|
  statuses = {
    'bad request' => ['400', 'Bad Request'],
    'not found' => ['404', 'Not Found'],
    'bad gateway' => ['502', 'Bad Gateway'],
    'server error' => ['500', 'Server Error'],
    'rate limit' => ['503', 'Rate Limited']
  }
    
  if status = statuses[type]
    FakeWeb.register_uri(:get, Regexp.new(path), [
      {:status => status, :times => 1},
      {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
    ])
  else
    pending
  end
end

Given /^the next request will receive a rate limit response with a refresh in (\d+) seconds$/ do |seconds|
  FakeWeb.register_uri(:get, /\/clients/, [
    {:status => ['503', 'Rake Limited'], "Retry-After" => seconds},
    {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
  ])
end

Given 'the next request will receive a rate limit response without a refresh set' do
  FakeWeb.register_uri(:get, /\/clients/, [
    {:status => ['503', 'Rake Limited']},
    {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
  ])
end

When 'I make a request with the standard client' do
  set_time_and_return_and_error do
    standard_api.clients.all
  end
end

When 'I make a request with the standard client to invoices' do
  set_time_and_return_and_error do
    standard_api.invoices.all
  end
end

When 'I make a request with the standard client to expense_categories' do
  set_time_and_return_and_error do
    standard_api.expense_categories.all
  end
end

When 'I make a request with the standard client to expenses' do
  set_time_and_return_and_error do
    standard_api.expenses.all
  end
end

When 'I make a request with the hardy client' do
  set_time_and_return_and_error do
    harvest_api.clients.all
  end
end

When /^I make a request with the hardy client with (\d+) max retries$/ do |times|
  set_time_and_return_and_error do
    api = Harvest.hardy_client(@subdomain, @username, @password, :ssl => @ssl, :retry => times.to_i)
    api.clients.all
  end
end

Then /a ([^"]*) error should be raised/ do |code|
  case code
  when '400'
    @error.should be_a(Harvest::BadRequest)
  when '404'
    @error.should be_a(Harvest::NotFound)
  when '502'
    @error.should be_a(Harvest::Unavailable)
  when '500'
    @error.should be_a(Harvest::ServerError)
  when '503'
    @error.should be_a(Harvest::RateLimited)
  when 'ModuleDisabled'
    @error.should be_a(Harvest::ModuleDisabled)
  else
    pending
  end
end

Then /the hardy client should wait (\d+) seconds for the rate limit to reset/ do |seconds|
  Time.now.should be_close(@time + seconds.to_i, 2)
end

Then 'I should be able to make a request again' do
  harvest_api.clients.all
  harvest_api.clients.all
end

Given /^the next (\d+) requests will receive a bad gateway response$/ do |times|
  FakeWeb.register_uri(:get, /\/clients/, [
    {:status => ['502', 'Bad Gateway'], :times => times.to_i},
    {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
  ])
end

Given /^the next (\d+) requests will receive a server error response$/ do |times|
  FakeWeb.register_uri(:get, /\/clients/, [
    {:status => ['500', 'Server Error'], :times => times.to_i},
    {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
  ])
end

Given /^the next (\d+) requests will receive an HTTP Error$/ do |times|
  FakeWeb.register_uri(:get, /\/clients/, [
    {:exception => Net::HTTPError, :times => times.to_i},
    {:body => File.read(File.dirname(__FILE__) + '/../support/fixtures/empty_clients.xml')}
  ])
end

Then 'no errors should be raised' do
  @error.should be_nil
  @clients.should == []
end

Given 'the rate limit status indicates I\'m over my limit' do
  over_limit_response = File.read(File.dirname(__FILE__) + '/../support/fixtures/over_limit.xml')
  FakeWeb.register_uri(:get, /\/account\/rate_limit_status/, :body => over_limit_response)
end

Given 'the rate limit status indicates I\'m under my limit' do
  over_limit_response = File.read(File.dirname(__FILE__) + '/../support/fixtures/under_limit.xml')
  FakeWeb.register_uri(:get, /\/account\/rate_limit_status/, :body => over_limit_response)
end