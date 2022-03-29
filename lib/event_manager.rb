# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'



def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
          address: zipcode,
          levels: 'country',
          roles: %w[legislatorUpperBody legislatorLowerBody]
        )
        legislators = legislators.officials
        legislator_names = legislators.map(&:name)
        legislator_names.join(", ")
      rescue 
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
      end

end

puts 'EventManager initialized!'

contents = CSV.open('/home/aniket/Projects/event_manager/event_attendees.csv', headers: true,header_converters: :symbol)

template_letter = File.read('/home/aniket/Projects/event_manager/form_letter.html')

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  personal_letter = template_letter.gsub("FIRST_NAME", name)
  personal_letter.gsub!("LEGISLATORS", legislators)

  puts personal_letter
end
