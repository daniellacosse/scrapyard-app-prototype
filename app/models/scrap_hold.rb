class ScrapHold < ActiveRecord::Base
	belongs_to :holdable, polymorphic: true
	belongs_to :scrap
end
