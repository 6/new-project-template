describe HealthchecksController, type: :controller do
  describe "GET #show" do
    it "returns 200 OK" do
      get :show
      expect(response).to be_ok
      expect(response_json).to include(message: 'Hola!')
    end
  end
end
