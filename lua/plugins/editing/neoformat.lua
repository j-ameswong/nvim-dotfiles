-- Locked defaults: ../../../plugin-defaults/neoformat.md @ 9d95e5ca3ab263363758d5b1d7a174a30556ab2d
return {
  'sbdchd/neoformat',
  cmd = 'Neoformat',
  config = function()
    vim.g.neoformat_enabled_java = { 'googlejavaformat' }
    vim.g.neoformat_java_googlejavaformat = {
        exe = 'google-java-format',
        args = { '--aosp', '-' },
        stdin = 1,
    }
  end
}
