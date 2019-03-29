require "spec_helper"

describe Api::Application do
  context "Get /" do
    it "should be ok" do
      get "/"

      expect(last_response.status).to eq 200
    end
  end
end
