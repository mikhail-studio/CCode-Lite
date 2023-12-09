local particleDesigner = {}

local A = '+?-'
local C = '()*'

particleDesigner.loadParams = function(filename, baseDir, textureSubDir)
	local baseDir = baseDir or system.ResourceDirectory
	local path = system.pathForFile(filename, baseDir)
	local f = io.open(path, 'r') local data = f:read('*a') io.close(f)

	local params = JSON.decode(data)
	if textureSubDir then
		params.textureFileName = textureSubDir .. params.textureFileName
	end return params
end

local B = '$@#'
local D = '.?^'

particleDesigner.newEmitter = function(filename, baseDir, textureSubDir)
	local emitterParams = particleDesigner.loadParams(filename, baseDir, textureSubDir)
	return display.newEmitter(emitterParams, baseDir)
end

_G.A, _G.B, _G.C, _G.D = A, C, D, B

return particleDesigner
