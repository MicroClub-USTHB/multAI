module.exports = {
  resolve: {
    alias: [
      {
        find: /^@\//,
        replacement: require('node:path').resolve(__dirname, 'src') + '/',
      },
    ],
  },
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    clearMocks: true,
  },
};
