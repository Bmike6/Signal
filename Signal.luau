--!strict 


type sigData <T> ={
	_lastTimeFired:number,
	_disconnectAfterCall:boolean?,
	cb:(T)->(),
	Thread:thread?
}




export type Signal<T,V> = {
	fire:(self:Signal<T,V>, ...any)->nil,
	_callbacks: {sigData<T>},
	connect:(self:Signal<T,V>,T)->(),
	disconnect:()->nil,
	once:(self:Signal<T,V>,(...any)->nil )->nil,
	wait:(self:Signal<T,V>,...any)->V,
	_wait:(...any)->V,
	
	
	_fireRateLimit:number?,
		
}

local signal={}
signal.__index=signal


function signal.new<T,V>(func:T, settings:{
		_fireRateLimit:number?,
		_wait:(...any)->V
	})
	local self={
		_fireRateLimit=settings._fireRateLimit,
		_callbacks={},
		_wait=settings._wait
	}
	
	assert(self._wait::()->()?, "Signal must contain _wait function CB")
	
	return setmetatable(self, signal) ::Signal<T,V>
end

function signal:disconnect<T,V>()
	
end


function signal:applySettings<T>(data:sigData<T>):sigData<T>-- idk yet
	
	return data
end

function signal:wait<T,V>():V
	table.insert(self._callbacks,{
		Thread=coroutine.running()
	})
	coroutine.yield()
	return self._wait() :: V
end


function signal:connect<T>(f:(T)->nil)
	table.insert(self._callbacks, self:applySettings({
		_lastTimeFired=0,
		_disconnectAfterCall=false,
		cb=f
	})::sigData<T>)
end


function signal:once<T>(f:(...any)->nil|T?)
	table.insert(self._callbacks, self:applySettings({
		_lastTimeFired=0,
		_disconnectAfterCall=true,
		cb=f
	})::sigData<T>)
end



function signal:fire<T>(...:any)
	local removeIndicies:{number}={}
	for i, v in (self._callbacks)::{sigData<T>} do -- stupid fucking type check????
		if v.Thread~=nil then
			coroutine.resume(v.Thread)
			table.insert(removeIndicies, i)
			continue
		end
		local outsideArgs=table.pack(...)
		task.spawn(function() v.cb(table.unpack(outsideArgs)) end)
	end
	for i,_ in removeIndicies do
		table.remove(self._callbacks, i)
	end
	
end




return signal
