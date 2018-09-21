require 'rails_helper'

describe Api::V1::SongsController do
  # before(:each) { request.headers['Accept'] = "application/vnd.regan-ryan.v1" }

  describe "GET #songs" do
    before(:each) do
      @songs = [FactoryBot.create(:song),
                FactoryBot.create(:song, firstline_title: "Another song", lyrics: "Different words[G]")]
      get :songs, format: :json
    end

    it "returns all songs" do
      songs_response = JSON.parse(response.body, symbolize_names: true)
      expect(songs_response.to_json).to eql @songs.to_json
    end

    it "returns 200" do
      expect(response).to have_http_status(200)
    end
  end
end