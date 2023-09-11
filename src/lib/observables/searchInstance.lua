local Rx = require('../rx/init')
local getChildren = require('./getChildren')

local function searchInstance(parent: Instance, name: string): Rx.Observable<Instance?>
    return Rx.of(parent):pipe(
        getChildren(),
        Rx.map(function(children: { Instance }): Instance?
            for _, child in children do
                if child.Name == name then
                    return child
                end
            end
            return nil
        end),
        Rx.distinctUntilChanged()
    )
end

return searchInstance
