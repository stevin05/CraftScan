local CraftScan = select(2, ...)

local TaskQueue = {
    queue = {},
    isProcessing = false,
    frame = CreateFrame('Frame'),
}

--- Processes the next task in the queue
function TaskQueue:ProcessNext()
    if #self.queue == 0 then
        self.isProcessing = false
        self.frame:SetScript('OnUpdate', nil)
        return
    end

    self.isProcessing = true
    local currentTask = table.remove(self.queue, 1)
    local index = 1
    local total = #currentTask.keys

    local function OnUpdate()
        local count = 0
        while index <= total and count < currentTask.perFrame do
            local key = currentTask.keys[index]
            currentTask.callback(key, currentTask.dataTable[key])

            index = index + 1
            count = count + 1
        end

        if index > total then
            self.frame:SetScript('OnUpdate', nil)
            if currentTask.onFinish then
                currentTask.onFinish()
            end
            self:ProcessNext() -- Start next queued item
        end
    end
    self.frame:SetScript('OnUpdate', OnUpdate)

    -- Fire off a single OnUpdate, so the caller can pass a huge perFrame to get
    -- fully synchronous behavior, allowing conditional time slicing.
    OnUpdate()
end

local function TimeSlice(dataTable, perFrame, callback, onFinish)
    local keys = {}
    for k in pairs(dataTable) do
        table.insert(keys, k)
    end

    table.insert(TaskQueue.queue, {
        dataTable = dataTable,
        keys = keys,
        perFrame = perFrame,
        callback = callback,
        onFinish = onFinish,
    })

    if not TaskQueue.isProcessing then
        TaskQueue:ProcessNext()
    end
end

CraftScan.TimeSlice = TimeSlice
