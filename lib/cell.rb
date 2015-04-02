class Cell < ActiveRecord::Base
    belongs_to :ocean
    belongs_to :ship

    def to_str
        if hit
            if ship_id != nil
                '='
            else
                'x'
            end
        else
            '.'
        end
    end

    def to_s
        to_str
    end
end