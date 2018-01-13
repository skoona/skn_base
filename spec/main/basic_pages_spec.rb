
# Ref: http://testing-for-beginners.rubymonstas.org/rack_test/rack.html
# Ref: http://tutorials.jumpstartlab.com/topics/capybara/capybara_with_rack_test.html


# describe Skn::SknBase, "Application pages Respond Correctly. ", roda: :app do
describe "Application pages Respond Correctly. " do

  context "Basic Navigation" do

    it "returns http success" do
      get "/"
      expect(last_response.status).to eq 200

      get "/about"
      expect(last_response.status).to eq 200

      get "/contact"
      expect(last_response.status).to eq 200

      get "/sessions/signin"
      expect(last_response.status).to eq 200
    end

    it "returns http Unauthorized" do
      get "/profiles/users"
      expect(last_response.status).to eq 404

      get "/profiles/resources"
      expect(last_response.status).to eq 404
    end
  end

  context "Honors API_AUTH login. " do

    before :each do
      basic_authorize('emtester', 'demos')
    end

    it "/profiles/users returns Requested Page" do
      get "/profiles/users"
      expect(last_response.status).to eq 200
    end

    it "/profiles/resources returns Requested Page" do
      get "/profiles/resources"
      expect(last_response.status).to eq 200
    end

  end

end
