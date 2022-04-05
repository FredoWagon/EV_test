## dependencies
require 'uri'
require 'net/https'
require 'json'
require 'csv'
require 'net/ftp'
require 'tempfile'
# require 'byebug'

## Design for fun
class String
    # colorization
    def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
    end

    def red
        colorize(31)
    end

    def green
        colorize(32)
    end

    def yellow
        colorize(33)
    end

    def blue
        colorize(34)
    end

    def pink
        colorize(35)
    end

    def light_blue
        colorize(36)
    end
end

# Parse data then create Guest object with filtered attributes
class GuestParser
    def initialize(response, selected_attributes = nil)
        @response = response
        @selected_attibutes =  selected_attributes || nil
    end

    def guests
        if @selected_attibutes
            parsed_json.map {|attributes| Guest.new(attributes.slice(*@selected_attibutes))}
        else
            parsed_json.map {|attributes| Guest.new(attributes)}
        end
    end

    private

    def parsed_json
        JSON.parse(@response)
    end
end

# Guest with dynamic attributes
class Guest

    def initialize(attributes = {})
        attributes.each do |attr, value|
            instance_variable_set("@#{attr}", value)
            define_singleton_method(attr) { attributes[attr] }
        end
    end

    def identity
        "#{defined?(self.first_name) && self.first_name} #{defined?(self.last_name) && self.last_name}"
    end

    def from_tesla?
        defined?(self.company_name) ? (self.company_name.strip.downcase == "tesla" ? true : false) : ""
    end

end


## Configuration (ENV variables)
# PLEASE ENTER YOUR CONFIGURATION VARIABLE HERE

#API
# API_KEY = "????" # <====?
#
# API_URL = "https://app.eventmaker.io"
# EVENT_ID = "623892c455f3056b99d816d3"
# API_PATH = "/api/v1/events/#{EVENT_ID}/guests.json"
#
# #FTP
# FTP_LOGIN = "????" # <====?
# FTP_PASSWORD = "????" # <====?
# FTP_HOST = "????" # <====?
# FTP_PORT = "????"  # <====?



## variables
# API url constructor
uri = URI(API_URL + API_PATH)
params = {:auth_token => API_KEY}
uri.query = URI.encode_www_form(params)



## methods & STEPS

#uri_string: URI::HTTPS, selected_attribues: array, limit: integer
def get_data_from_api(uri_string, limit = 10)
    # animation
    puts limit == 10 ? "### Get data from API:".green : "redirected to #{uri_string}".blue


    # Raise error if request limit exced
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    # API request response
    response = Net::HTTP.get_response(uri_string)

    # handle response
    case response
    when Net::HTTPSuccess
        # animation
        puts "= done"
        puts ""
        puts ""

        return response.body

    when Net::HTTPRedirection
        #handle redirection
        new_location = response['location']
        get_data_from_api(URI(new_location), limit - 1)
    else
        puts "Sorry, an error occured. Error Message : #{response.message}".red
    end

end


#data: Array of Guest instances | data from API call
def store_into_csv(guest_list, headers = [])
    # animation
    puts "### Create a CSV file from request:".green

    # create the Tempfile with data
    csv_tempfile = Tempfile.new().tap do |file|
        CSV.open(file,"wb") do |csv|
            csv << headers
            guest_list.each do |guest|
                csv << [guest.email, guest.company_name, guest.identity, guest.uid, guest.from_tesla?]
            end
        end
    end

    # animation
    puts "= done"
    puts ""

    return csv_tempfile

end


#file: Temfile | file to upload
def upload_csv(file)
    # animation
    puts "### Upload CSV to FTP serveur:".green

    # create the file name
    time_stamp = Time.now.to_i
    filename = "Event_guest_list_V#{time_stamp}.csv"

    # connect to ftp server then upload file
    ftp = Net::FTP.new
    defined?(FTP_PORT) ? ftp.connect(FTP_HOST, FTP_PORT) : ftp.connect(FTP_HOST)

    ftp.login(FTP_LOGIN, FTP_PASSWORD)
    ftp.passive = true
    ftp.debug_mode = true

    ftp.putbinaryfile(file, "/fred/#{filename}") do |data|
        loading_animation(data)
    end
    files = ftp.chdir("fred")
    files = ftp.ls("Event*")
    puts ""
    puts "#{filename} uploaded !".light_blue
    puts "FTP files list :"
    puts files
    ftp.close

    # delete temporary file
    file.close

    # animation
    puts ""

    puts "= done"
    puts ""
    puts ""
    return filename

end


##filename: String | name of the file
def download_back_uploaded_csv(filename)
    # animation
    puts "###Downloading back #{filename} from FTP serveur:".green

    # download request from ftp server
    ftp = Net::FTP.new
    defined?(FTP_PORT) ? ftp.connect(FTP_HOST, FTP_PORT) : ftp.connect(FTP_HOST)
    ftp.login(FTP_LOGIN, FTP_PASSWORD)
    ftp.passive = true
    ftp.chdir("fred")
    ftp.getbinaryfile(filename, localfile=File.basename(filename), 1024) do |data|
        loading_animation(data)
    end
    ftp.close

    # animation
    puts ""
    puts "#{filename} downloaded !".light_blue
    puts "= done"
    puts ""
    puts ""

end


#filename: String | name of the localfile
def read_a_csv(filename)
    # animation
    puts "### Display CSV file into terminal :".green
    puts ""

    # get the file then display in terminal
    file = File.open(filename)
    CSV.foreach(file) do |row|
        puts "________________________".yellow
        puts ""
        row.each { |value| print "   #{value}   |".yellow  }
        puts ""
    end

    # animation
    puts ""
    puts ""
    puts ""
    puts "      This is the end !".pink
    puts "      Thank you for watching".pink
    puts ""
    puts ""
    puts ""

end

# data transfert animation
#data: String | file to upload/download
def loading_animation(data)
    transferred = 0
    transferred += data.size
    percent = ((transferred.to_f/data.size.to_f)*100).to_i
    finished = ((transferred.to_f/data.size.to_f)*30).to_i
    not_finished = 30 - finished
    print "\r"
    print "#{"%3i" % percent}%".green
    print "[".green
    finished.downto(1) { |n| print "=".green }
    print ">".green
    not_finished.downto(1) { |n| print " " }
    print "]".green
end



# STARTING POINT

## STEP 1
# get data from API
api_call_response = get_data_from_api(uri)

# STEP 2
# parse and create guests list
guest_selected_attributes = ["email", "first_name", "company_name", "last_name", "uid"] #optional
guests_lis = GuestParser.new(api_call_response, guest_selected_attributes).guests

#STEP 3
# create a CSV file with headers
guets_csv_file = store_into_csv(guests_lis, ["email", "company name", "identity", "uid", "from tesla"])

# STEP 4
# upload the CSV file to FTP server
file_name = upload_csv(guets_csv_file)

# STEP 5
# download back the CSV file from FTP server
download_back_uploaded_csv(file_name)

# FINAL STEP
# read the CSV file that we received back
read_a_csv(file_name)

