require File.expand_path('../support/test_helper', __dir__)

require 'minitest/autorun'

class TestData
  BASE_URL = "http://www.omdbapi.com"
  BASE_PARAMS = {"apikey" => "Your_key_here"}

  # OMDb Responses
  BAD_RESPONSE = {"Response" => "False"}
  GOOD_RESPONSE = {"Response" => "True"}

  # OMDb Error Codes
  NO_API_KEY_ERROR = {"Error" => "No API key provided."}

  # Response Keys
  SEARCH_KEY = "Search"
  MOVIE_KEYS = %w(Title Year imdbID Type Poster)

  # HTTP Status Codes
  OK_STATUS_CODE = 200
  UNAUTHORIZED_STATUS_CODE = 401
end

describe "OMDB Tests" do
  include RequestHelper

  def build_params(params)
    # Wrapper to create a params hash
    {params: params}
  end

  def build_options(headers = {}, params = {})
    # Builds an options hash with given headers and params
    {headers: headers, params: params}
  end

  def last_search_results
    # returns the array of search results for an OMDb response
    last_response.obj[TestData::SEARCH_KEY]
  end

  describe "API Request" do
    before do
      # All requests will hit the same base URL
      self.default_url = TestData::BASE_URL
      self.default_params = TestData::BASE_PARAMS
    end

    it "should return failure without an API key" do
      self.default_params = {}
      my_response = request('GET', '', build_params({"s" => "star"}))
      _(my_response.status).must_equal TestData::UNAUTHORIZED_STATUS_CODE
      _(my_response.obj).must_equal TestData::BAD_RESPONSE.merge TestData::NO_API_KEY_ERROR
    end

    describe "search with value \'thomas\'" do
      before do
        request('GET', '', build_params({"s" => "thomas"}))
        # Make sure all responses in this group are good
        _({"Response" => last_response.obj["Response"]}).must_equal TestData::GOOD_RESPONSE
      end

      it "should have only titles containing \'thomas\'" do
        _(last_response.obj).must_include TestData::SEARCH_KEY
        _(last_search_results.length).must_be :>, 0
        last_search_results.each do |movie|
          _(movie["Title"].downcase).must_include "thomas"
        end
      end

      it "should contain all the correct keys for a movie" do
        last_search_results.each do |movie|
          TestData::MOVIE_KEYS.each { |key| _(movie).must_include key }
        end
      end

      it "should have values that are the correct class (one record at random)" do
        _(last_search_results).must_be_instance_of Array

        index = rand(last_search_results.length)
        _(last_search_results[index]).must_be_instance_of Hash
        hash_values = last_search_results[index].values
        hash_values.each { |value| _(value).must_be_instance_of String }
      end

      it "should use the correct format for year" do
        year_values = last_search_results.map do |movie|
          movie["Year"]
        end
        # Beware: dash is an En-dash, UTF-8 0xe28093
        year_format = /^(\d{4})(–|–(\d{4}))?$/
        year_values.each do |year|
          # check format
           _(year).must_match year_format

           # check that the year the show started is before or equal to its end
           # TODO: Add check for movies existing before invented or in the future
           captures = year.match(year_format).captures
           unless captures[2].nil?
             start_year = captures[0].to_i
             end_year = captures[2].to_i
             _(start_year).must_be :<=, end_year
           end
        end
      end

      it "should have valid imdbIDs for movie results" do
        imdbIDs_with_titles = last_search_results.map do |movie|
           {imdbID: movie["imdbID"], title: movie["Title"]}
        end

        imdbIDs_with_titles.each do |imdbID_with_title|
          request('GET', '', build_params({"i" => imdbID_with_title[:imdbID]}))
          _(last_response.status).must_equal TestData::OK_STATUS_CODE
          _(last_response.obj["Title"]).must_equal imdbID_with_title[:title]
        end
      end

      it "should have no broken poster links on page 1" do
        poster_links = last_search_results.map { |movie| movie["Poster"] }

        poster_links.each do |poster_link|
          request('GET', '', {}, poster_link)
          _(last_response.status).must_equal TestData::OK_STATUS_CODE
        end
      end
    end
    
    describe "search with value \'action\'" do
      # Assuming that all OMDb results contain an IMDb ID.
      # Another way to do this is to create a movie class that implements eq? and hash.
      it "should return unique records across 5 pages of results" do
        movie_list = {}
        all_movies_are_unique = true
        (1..5).each do |page|
          request('GET', '', build_params({"s" => "action", "page" => page.to_s}))
          last_search_results.map do |movie|
            imdbID = movie["imdbID"]
            if movie_list.include? imdbID
              # Stop scanning if duplicate found
              all_movies_are_unique = false
              break
            else
              movie_list[imdbID] = true
            end
          end
          break unless all_movies_are_unique
        end

        _(all_movies_are_unique).must_equal true
      end
    end

    describe "personal interest requests" do
      it "should return the oldest movie (according to Wikipedia)" do
        request('POST', '', build_options({"Content-Type" => "text/plain"},
                                           {"t" => "Roundhay Garden Scene"}))
        _(last_response.obj["Year"]).must_equal "1888"
      end

      it "should handle long URLs" do
        lots_of_Qs = "Q" * 1024
        request('GET', '', build_params({"s" => lots_of_Qs}))
        _(last_response.attrs[:status]).must_equal TestData::OK_STATUS_CODE
      end
    end
  end
end

