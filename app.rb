require 'sinatra'
require 'rspotify'
require 'open-uri'

ALPHABET = "abcdefghijklmnopqrstuvwxyz".split("")

get '/' do 
	# this is the homepage, it can accept four different params - query, genre, offset, and pretentiousness
	@track = RSpotify::Track.search(
		set_query(params[:query], params[:genre]), 
		offset: set_offset(params[:pretentiousness])).sample 
	# this is the call to Spotify to get a track based on the params present

	set_times(params[:length])
	erb :home
end

post '/download/:id' do 
	# calling this URL will download the current file
	attachment "file.mp3"
	open(RSpotify::Track.find(params[:id]).preview_url) { |f| f.read }
end

private

def set_query(query, genre) 
	# this method determines what string is used to search Spotify. 
	# Spotify API requires any genre selection to be done via the query parameter. 
	# E.g. searching 'Aphex Twin genre: electronic' is how you seach for 'Aphex Twin' matches within the electronic genre
	# This means our genre and query parameters need to be combined into the same string

	# there are four potential search possiblities:
	# 1) a user inputs neither a query or a genre => we just randomly search spotify with a random letter of the alphabet
	# 1) a user inputs a query but no genre => we search against that query
	# 2) a user inputs a genre but no query => we search against that genre
	# 3) a user inputs both a query and a genre => we search against both

	if is_present(query)
		@query = query 
	else 
		if is_present(genre) 
			@query = ''
		else
			@query = ALPHABET.sample 
		end
	end
	if is_present(genre)
		@genre = genre
		@search_query = "#{@query} genre:\"#{@genre}\"" 
	else
		@genre = ''
		@search_query = "#{@query}" 
	end
end

def set_offset(pretentiousness)
	# results from the Spotify API are automatically returned in order of popularity
	# pretentiousness works by setting the upper limit of how far we are willing to go down the list
	# higher pretentiousness = higher chance of getting a track further down the list

	@pretentiousness = pretentiousness || 0
	if @pretentiousness == 0
		@offset = 0
	else
		@offset = rand(0..@pretentiousness.to_i)
	end
end

def set_times(length=4.0)
	# this method sets the start & stop time of the track - which effectively is a sample. 
	# Remember Spotify only provides us with 30 second snippets to work with
	if is_present(length)
		# if a custom length is provided, use that
		@length = length.to_f
	else
		# else default to 4 seconds
		@length = 4.0
	end
	max_start_time = 30.0 - @length
	@start_time = rand(0..max_start_time.to_i)
	@stop_time = @start_time + @length
end

def is_present(var)
	# this is just a convenience method to determine if the user provided a param
	if !var.nil? && !var.empty?
		true
	else
		false
	end
end