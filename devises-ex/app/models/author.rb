require 'csv'
class Author < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :books

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  validates :name, presence: true, uniqueness: true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :with_name
    ]
  )

  scope :sorted_by, ->(sort_option) {
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      order("Authors.created_at #{direction}")
    when /^name_/
      order("Authors.title #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }
  
  scope :search_query, ->(query) {
    return nil if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(Authors.name) LIKE ? OR LOWER(Authors.email) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :with_name, ->(name) {
    where('name = ?', name)
  }

  def self.options_for_sorted_by(sort_option = nil)
    [
      ['Article (A-Z)', 'name_asc'],
      ['Article (Z-A)', 'name_desc'],
      ['Created date (Newest first)', 'created_at_desc'],
      ['Created date (Oldest first)', 'created_at_asc']
    ]
  end

  def self.to_csv
    attributes = %w{name email} # add other attributes here if needed

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |author|
        csv << attributes.map{ |attr| author.send(attr) }
      end
    end
  end

end
