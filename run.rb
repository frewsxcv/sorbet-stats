# typed: true

require 'csv'

SEARCH_TERMS = [
  "typed: strong",
  "typed: strict",
  "typed: true",
  "typed: false",
  "typed: ignore",
]

def checkout(ref)
  `git checkout --quiet #{ref}`
end

def fetch_rows
  rows = []

  loop do
    row = []

    SEARCH_TERMS.each do |search_term|
      row << Integer(`git grep "#{search_term}" | wc -l`)
    end

    if row.sum == 0
      break
    end

    row.unshift(`git show -s --format=%ci`.strip)

    rows << row

    checkout('HEAD^')
  end

  rows.reverse!

  rows
end


checkout('master')

puts(
  CSV.generate do |csv|
    csv << ['date', *SEARCH_TERMS]

    fetch_rows.each { |row| csv << row }
  end
)

checkout('master')
