local CraftScan = select(2, ...)

local TaskQueue = {
    queue = {},
    isProcessing = false,
    frame = CreateFrame('Frame'),
}

function TaskQueue:Start()
    if self.isProcessing then
        return
    end

    local OnUpdate = function()
        if not self.currentTask then
            if #self.queue == 0 then
                self.isProcessing = false
                self.frame:SetScript('OnUpdate', nil)
                return
            end

            self.isProcessing = true
            self.currentTask = table.remove(self.queue, 1)
            self.currentIndex = 1
        end

        local task = self.currentTask
        local total = #task.keys
        local count = 0

        while self.currentIndex <= total and count < task.perFrame do
            local key = task.keys[self.currentIndex]
            local success, err = pcall(task.callback, key, task.dataTable[key])

            if not success then
                self.queue = {}
                self.currentTask = nil
                self.frame:SetScript('OnUpdate', nil)
                error(err)
                return
            end

            self.currentIndex = self.currentIndex + 1
            count = count + 1
        end

        if self.currentIndex > total then
            if task.onFinish then
                task.onFinish()
            end
            self.currentTask = nil -- This triggers the next task check on the next frame
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
        TaskQueue:Start()
    end
end

CraftScan.TimeSlice = TimeSlice
