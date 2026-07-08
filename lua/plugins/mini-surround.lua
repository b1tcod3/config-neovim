return {
    "nvim-mini/mini.surround",
    lazy = false,
    config = function()
        require("mini.surround").setup({
            custom_surroundings = {
                ["i"] = { output = { left = "@island ", right = " @endisland" } },
                ["p"] = { output = { left = "@php", right = " @endphp" } },
                ["f"] = { output = { left = "@if", right = " @endif" } },
                ["e"] = { output = { left = "@foreach", right = " @endforeach" } },
                ["s"] = { output = { left = "@section", right = " @endsection" } },
                ["h"] = { output = { left = "@push", right = " @endpush" } },
                ["d"] = { output = { left = "@error", right = " @enderror" } },
                ["a"] = { output = { left = "@auth", right = " @endauth" } },
                ["g"] = { output = { left = "@guest", right = " @endguest" } },
                ["w"] = { output = { left = "@env", right = " @endenv" } },
            },
        })
        vim.keymap.set("x", "S", function() require("mini.surround").add("visual") end, { desc = "Add surround (visual)" })
    end,
}
