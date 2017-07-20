import nodeResolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import coffee from 'rollup-plugin-coffee-script';
import sizeBreakdown from 'rollup-plugin-sizes';
import bundleSize from 'rollup-plugin-filesize';

export default {
  entry: 'src/index.coffee',
  plugins: [
    coffee({exclude: 'node_modules/**'}),
    nodeResolve({extensions: ['.js', '.coffee']}),
    commonjs({extensions: ['.js', '.coffee']}),
    sizeBreakdown(),
    bundleSize()
  ],
  targets: [
    {format: 'es', dest: 'dist/solaris.mjs'},
    {format: 'umd', moduleName: 'Solaris', dest: 'dist/solaris.js'}
  ]
};
