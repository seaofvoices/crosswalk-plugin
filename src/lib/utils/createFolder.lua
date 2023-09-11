local function createFolder(location: Instance, name: string): Folder
    local folder = Instance.new('Folder') :: Folder
    folder.Name = name
    folder.Parent = location
    return folder
end

return createFolder
