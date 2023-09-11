local Array = require('../luau-polyfill/collections/Array/init')
local CrosswalkContext = require('../CrosswalkContext')
local Rx = require('../rx/init')
local getChildren = require('./getChildren')

type ModuleTreeNode = CrosswalkContext.ModuleTreeNode

local function filterModuleScript(childInstance: Instance): boolean
    return childInstance:IsA('ModuleScript')
end

local function sortByName(a: Instance, b: Instance): boolean
    return a.Name < b.Name
end

local loadModules

local function loadNestedModules(): Rx.OperatorFunction<ModuleScript, ModuleTreeNode>
    return Rx.switchMap(function(module: ModuleScript)
        return Rx.combineLatest({
            moduleScript = Rx.of(module),
            children = Rx.of(module :: Instance):pipe(loadModules()),
            -- api = {}
        })
    end)
end

function loadModules(): Rx.OperatorFunction<Instance, { [string]: ModuleTreeNode }>
    return Rx.pipe(
        getChildren(),
        Rx.map(function(children: { Instance }): { ModuleScript }
            local moduleScripts: { ModuleScript } =
                Array.filter(children, filterModuleScript) :: any
            table.sort(moduleScripts, sortByName)
            return moduleScripts
        end),
        Rx.switchMap(function(children: { ModuleScript })
            if #children == 0 then
                return Rx.create(function(subsriber)
                    subsriber:next({})
                end)
            end

            local innerObservables = Array.reduce(
                children,
                function(acc: { [string]: Rx.Observable<ModuleTreeNode> }, subModule: ModuleScript)
                    acc[subModule.Name] = Rx.of(subModule):pipe(loadNestedModules())
                    return acc
                end,
                {}
            )

            return Rx.combineLatest(innerObservables)
        end)
    )
end

return loadModules
