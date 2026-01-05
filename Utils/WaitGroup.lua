local CraftScan = select(2, ...)

CraftScan.WaitGroup = CraftScan.Object:extend()

function CraftScan.WaitGroup:new(onFinish)
    self.counter = 0
    self.onFinish = onFinish
    self.isClosed = false
end

function CraftScan.WaitGroup:Add()
    self.counter = self.counter + 1
end

function CraftScan.WaitGroup:Done()
    self.counter = self.counter - 1
    self:Check()
end

-- Call this when you are done adding new tasks
function CraftScan.WaitGroup:Close()
    self.isClosed = true
    self:Check()
end

function CraftScan.WaitGroup:Check()
    if self.isClosed and self.counter <= 0 then
        if self.onFinish then
            self.onFinish()
        end
    end
end
