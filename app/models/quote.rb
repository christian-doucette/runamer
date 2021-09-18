class Quote < ActiveRecord::Base
  def format_quote
    if self.author.nil?
      %Q["#{self.quote_text}" - Unknown"]
    else
      %Q["#{self.quote_text}" - #{self.author}]
    end
  end
end
