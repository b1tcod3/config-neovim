return {
    "nvim-mini/mini.surround",
    lazy = false,
    config = function()
        require("mini.surround").setup({
            custom_surroundings = {
                ["i"] = { output = { left = "@island ", right = " @endisland" } },
            },
        })
    end,
}
