--[[
	Scripter: FacelessDev (@julimaxx)
	Description: Buffered Tables (to store ints)
	Last Review: 02/04/2026	
]]--
--!strict

local IntBuffer = {}
IntBuffer.__index = IntBuffer

export type IntBuffer = {
	buff: buffer
}

function IntBuffer.new(size: number): IntBuffer
	local self = setmetatable({},IntBuffer)
	self.buff = buffer.create((size+1)*4)
	buffer.writeu32(self.buff,0,0)
	return self
end

function IntBuffer:__index(key): any
	if type(key) == "number" then
		if key < 1 or key > (buffer.len(self.buff)/4)  then
			error("Index out of range", 2)
		end
		return buffer.readi32(self.buff,4*(key))
	else
		return rawget(IntBuffer,key)
	end
end

function IntBuffer:__newindex(key,value)
	if type(key) == "number" then
		if key < 1 or key > (buffer.len(self.buff)/4) then
			error("Index out of range", 2)
		end
		
		if type(value) ~= "number" then
			error("Value not number", 2)
		end
		
		buffer.writeu32(self.buff, 0,buffer.readu32(self.buff,0)+1)
		return buffer.writei32(self.buff,4*(key),value)
	else
		rawset(self,key,value)
	end
end

function IntBuffer:__len(): number
	return self.size
end

function IntBuffer:pairs()
	local i = 0
	local n = buffer.readu32(self.buff,0)

	return function(_,_): (number?,number?)
		i += 1
		if i <= n then
			return i, buffer.readi32(self.buff, 4*i)
		else
			return nil,nil
		end
	end, nil, i
end

return IntBuffer
