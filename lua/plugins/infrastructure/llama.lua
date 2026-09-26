-- Locked defaults: ../../../plugin-defaults/llama.vim.md @ 789c40a23f099134a58f5bbb623582f0bcf49bd4
return {
  "ggml-org/llama.vim",
  init = function()
    -- Preserve defaults already filled by llama.vim if lazy.nvim reloads specs.
    -- ~31 t/s generation and ~2200 t/s prompt with the local server.
    vim.g.llama_config = vim.tbl_deep_extend("force", vim.g.llama_config or {}, {
      endpoint_fim = "http://127.0.0.1:8012/infill",
      n_prefix = 256,
      n_suffix = 64,
      n_predict = 128,
      t_max_prompt_ms = 800,
      t_max_predict_ms = 1000,
      show_info = 0,
      keymap_fim_accept_full = "<C-y>",
      keymap_inst_cancel = "",
      auto_fim = false,
    })
  end,
}
