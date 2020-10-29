# QA API Code Test

It is time to run some tests against OMDb API - The Open Movie Database!

## How to Set Up Directory:

1. Clone this project to a directory on your machine.
2. Have Ruby installed on your system.
3. Run `gem install bundler`.
4. Run `bundle install` in the directory containing `Gemfile.lock`.

## How to Run the Tests:

1. Replace `"Your_key_here"` in `TestData::BASE_PARAMS` in `suite/api_spec.rb` with your key from http://www.omdbapi.com.
2. Run `rake test` in the top level directory.

## Decisions

I switched this from asserts to expectations to better match a test file with Node (which never happened), but in retrospect, it's worse in Minitest. 

## Tips:

- You can find the main api page at http://www.omdbapi.com
- You must use minitest and rest-client as supplied, and follow the existing pattern of api requests in test_no_api_key.
- You may add or change other gems as you see the need. (For example, byebug is supplied debugging but you may use another debugger.)
- Completed repo should allow for easy setup/running of your test file.
- Unique or helpful information should be documented in the readme.

## Tasks:

1. Successfully make api requests to omdbapi from within tests in api_test.rb

2. Add an assertion to test_no_api_key to ensure the response at runtime matches what is currently displayed with the api key missing

3. Extend api_test.rb by creating a test that performs a search on 'thomas'.

  - Verify all titles are a relevant match
  - Verify keys include Title, Year, imdbID, Type, and Poster for all records in the response
  - Verify values are all of the correct object class
  - Verify year matches correct format

4. Add a test that uses the i parameter to verify each title on page 1 is accessible via imdbID

5. Add a test that verifies none of the poster links on page 1 are broken

6. Add a test that verifies there are no duplicate records across the first 5 pages

7. Add a test that verifies something you are curious about with regard to movies or data in the database.
