class Cell < ActiveRecord::Base
    belongs_to :ocean
    belongs_to :ship


    # is there a reason you're implementing `to_str` and then aliasing `to_s` to
    # `to_str`? General best practice is that only objects that can be actually
    # converted to a string should implement `to_str`. Another way to say this
    # is that calling `to_str` implies that the object behaves like a string.
    def to_str
        if hit
            if ship != nil
                '#'
            else
                'o'
            end
        else
            '.'
        end
    end

    def to_s
        to_str
    end
end
