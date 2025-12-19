return {
  "mfussenegger/nvim-jdtls",

  opts = {

    settings = {
      java = {
        configuration = {
          runtimes = {
            {
              name = "JavaSE-25",
              path = "/usr/lib/jvm/java-25-openjdk",
            },
          },
        },
      },
    },
  },
}
