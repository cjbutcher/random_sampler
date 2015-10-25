require 'sinatra'
require 'rspotify'
require 'open-uri'

ALPHABET = "abcdefghijklmnopqrstuvwxyz".split("")

get '/' do
	@track = RSpotify::Track.search(
		set_query(params[:query], params[:genre]), 
		offset: set_offset(params[:pretentiousness])).sample

	set_times(params[:length])
	erb :home
end

post '/download/:id' do
	attachment "file.mp3"
	open(RSpotify::Track.find(params[:id]).preview_url) { |f| f.read }
end

def set_offset(pretentiousness)
	@pretentiousness = pretentiousness || 0
	@pretentiousness == 0 ? @offset = 0 : @offset = rand(0..@pretentiousness.to_i)
end

def set_query(query, genre)
	if is_present(query)
		@query = query
	else
		is_present(genre) ? @query = '' : @query = ALPHABET.sample
	end
	if is_present(genre)
		@genre = genre
		@search_query = "#{@query} genre:\"#{genre}\""
	else
		@genre = ''
		@search_query = "#{@query}"
	end
end

def set_times(length)
	if is_present(length)
		@length = length.to_f
		max_start_time = 30.0 - @length
		@start_time = rand(0..max_start_time.to_i)
	else
		@length = 4.0
		@start_time = 15.0
	end
	@stop_time = @start_time + @length
end

def is_present(var)
	if !var.nil? && !var.empty?
		true
	else
		false
	end
end