require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

MAX_RETRIES = 3

describe Harvest::HardyClient::HardyCollection do
  before do
    # def initialize(collection, client, max_retries)
    @hardy_client = Harvest::HardyClient::HardyCollection.new([], nil, MAX_RETRIES, 1)
    @response = mock("response", :headers => {})
  end

  describe ".sleep_increment" do
    it "defaults to 16" do
      @hardy_client = Harvest::HardyClient::HardyCollection.new([], nil, MAX_RETRIES)
      @hardy_client.sleep_increment.should == 16
    end

    it "can be set" do
      @hardy_client = Harvest::HardyClient::HardyCollection.new([], nil, MAX_RETRIES, 1)
      @hardy_client.sleep_increment.should == 1
    end
  end

  describe ".retry_rate_limits" do
    context "no times" do
      it "does not retry" do
        @actual_tries = -1
        @hardy_client.retry_rate_limits do
          @actual_tries += 1
        end
        
        @actual_tries.should == 0
      end
    end

    shared_examples_for "Error Raised" do
      context "every time" do
        it "retries the max number of times then dies" do
          @actual_tries = -1
          puts @error_under_test
                
          lambda {
            @hardy_client.retry_rate_limits do
              @actual_tries += 1
              raise @error_under_test.new(@response)
            end
          }.should raise_error(@error_under_test)

          @actual_tries.should == 3
        end
      end

      context "once" do
        it "retries, then " do
          @actual_tries = -1
          error_spectrum = [@error_under_test.new(@response), nil]

          puts @error_under_test
                
          @hardy_client.retry_rate_limits do
            @actual_tries += 1
            if error_to_raise = error_spectrum[@actual_tries]
              raise error_to_raise
            end              
          end

          @actual_tries.should == 1
        end
      end
    end

    describe Harvest::RateLimited do
      before(:each) do
        @error_under_test = Harvest::RateLimited
        @response.stub!(:headers => { 'retry-after' => ["1"]})      
      end

      it_should_behave_like "Error Raised"
    end

    describe Harvest::Unavailable do
      before(:each) { @error_under_test = Harvest::Unavailable }
      it_should_behave_like "Error Raised"
    end

    describe Harvest::InformHarvest do
      before(:each) { @error_under_test = Harvest::InformHarvest }
      it_should_behave_like "Error Raised"
    end
  end
end