require 'csv'
require 'pry-byebug'
require 'google/apis/civicinfo_v2'
require 'erb'




puts 'Event Manager Initialized!'

# puts File.exist?("../event_attendees.csv")

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,'0')[0..4]
end

def clean_homephone(homephone)
    clean_homephone = homephone.gsub(/\D/,'')
    homephone_length = clean_homephone.length
    unless homephone_length == 10
        if homephone_length < 10
            return 'Digits missing'
        elsif homephone_length == 11 && clean_homephone[0] == '1'
            # binding.pry
            return clean_homephone[1..10]
        else
            return 'Bad number'
        end
    end

    clean_homephone

end

def legislator_by_zipcode(zip)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    begin
        civic_info.representative_info_by_address(
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials

    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end

end

def save_thank_you_letter(id,form_letter)
    Dir.exist?('output') unless  Dir.mkdir('output')
    filename = "output/thanks_#{id}.html"
    File.open(filename,'w') do |file|
        file.puts form_letter
    end
end

contents = CSV.open("../event_attendees.csv", 
    headers:true,
    header_converters: :symbol
)

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new template_letter
contents.each do |row|
    id = row[0]
    name = row[:first_name]
    clean_phone = clean_homephone(row[:homephone])
    # binding.pry

    puts clean_phone
    # zipcode = clean_zipcode(row[:zipcode])
    # legislators = legislator_by_zipcode(zipcode)

    # form_letter = erb_template.result(binding)
    # save_thank_you_letter(id, form_letter)
    
end
