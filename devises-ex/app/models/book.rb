class Book < ApplicationRecord
  belongs_to :author

  validates :name, uniqueness: true
  validate :release_date_cannot_be_in_the_future

  # Constants for sorting
  SORT_OPTIONS = {
    'Name (A-Z)' => 'name_asc',
    'Name (Z-A)' => 'name_desc',
    'Created at (Newest first)' => 'created_at_desc',
    'Created at (Oldest first)' => 'created_at_asc'
  }.freeze

  # Filterrific configuration
  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :with_author_id,
      :with_release_date_gte
    ]
  )

  # Default scope, always first
  scope :sorted_by, lambda { |sort_key|
    direction = (sort_key =~ /desc$/) ? 'desc' : 'asc'
    case sort_key.to_s
    when /^created_at_/  # sorting by created_at
      order("books.created_at #{direction}")
    when /^name_/  # sorting by book name
      order(Arel.sql("LOWER(books.name) #{direction}"))
    else
      raise(ArgumentError, "Invalid sorting option: #{sort_key.inspect}")
    end
  }

  scope :search_query, lambda { |query|
    return nil  if query.blank?

    # Split the query at spaces and search for any of the words within the book names
    terms = query.to_s.downcase.split(/\s+/)

    terms = terms.map do |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    end
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(books.name) LIKE ? OR LOWER(authors.name) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    ).includes(:author).references(:author)
  }

  scope :with_author_id, lambda { |author_id|
    where(author_id: [*author_id])
  }

  scope :with_release_date_gte, lambda { |ref_date|
    where('books.release_date >= ?', ref_date)
  }

  # Validator method
  def release_date_cannot_be_in_the_future
    if release_date.present? && release_date > Date.today
      errors.add(:release_date, "can't be in the future")
    end
  end

  # If using select options for sorting, a method returning sortable options can be helpful
  def self.options_for_sorted_by
    SORT_OPTIONS.map { |label, key| [label, key] }
  end
end
