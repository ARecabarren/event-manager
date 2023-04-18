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

def register_hour(regdate,hash)
    # registration_time = regdate.gsub(/\d{1,2}\/\d{1,2}\/\d{1,2} /,'')
    # registration_hour = registration_time.gsub(/:\d{1,2}/,'')
    full_time = Time.strptime(regdate,'%m/%d/%y %H:%M')
    hour = full_time.strftime('%H')
    day_as_word = full_time.strftime('%A')
    # binding.pry
    hash[hour][:ocurrences] += 1
    hash[hour][:day].push(day_as_word)
end

def write_most_active_days_hour(hash)
    ocurrences = []
    hash.values.each_with_index do |value, index| 
        ocurrences.push(value[:ocurrences])
    end
    
    max_value = ocurrences.max
    max_keys = hash.select {|k,v| v[:ocurrences]== max_value}.keys

    if max_keys.length != 0 > 1
        puts "The most active hours are #{max_keys} with #{max_value} registrations"
    elsif max_keys.length == 1
        puts "The most active hour is #{max_keys} with #{max_value} registrations"
    end
    days = []
    max_keys.each do |value|
        hash[value][:day].each{|value| days.push(value)}
    end

    puts "Most active days #{days.uniq}"

end
contents = CSV.open("../event_attendees.csv", 
    headers:true,
    header_converters: :symbol
)

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new template_letter
hour_frequencies = Hash.new
24.times do |time|
    time_as_s =  time.to_s.length == 1 ? '0' + time.to_s : time.to_s
    hour_frequencies[time_as_s] = {ocurrences: 0, day: [] }
end

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    clean_phone = clean_homephone(row[:homephone])
    register_hour(row[:regdate],hour_frequencies)
    # puts row[:regdate].gsub(/\d{1,2}:\d{1,2}/,'')
    # time = Time.strptime(row[:regdate],'%m/%d/%y %H:%M')
    # puts time.strftime("%H")
    
    # binding.pry
    

    # puts registration_hour
    # zipcode = clean_zipcode(row[:zipcode])
    # legislators = legislator_by_zipcode(zipcode)

    # form_letter = erb_template.result(binding)
    # save_thank_you_letter(id, form_letter)
    
end

write_most_active_days_hour(hour_frequencies)
# puts hour_frequencies


