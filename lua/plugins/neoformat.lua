return {
  'sbdchd/neoformat',
  config = function()
    vim.g.neoformat_enabled_java = { 'googlejavaformat' }
    vim.g.neoformat_java_googlejavaformat = {
        exe = 'google-java-format',
        args = { '--aosp', '-' },
        stdin = 1,
    }
  end
}
