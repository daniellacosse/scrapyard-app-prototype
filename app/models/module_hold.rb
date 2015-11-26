class ModuleHold < ActiveRecord::Base
	belongs_to :holdable, polymorphic: true
	belongs_to :scrapper_module
end
