const base = require('jsonresume-theme-relaxed');

// Hide the "Work Experience" and "Education" h3 section headers, and
// replace the visual separator they provided with a border-top on each
// article. This recovers ~5em of vertical space for single-page resumes.
const COMPACT_CSS =
  '#work>h3,#education>h3{display:none}' +
  '#work,#education{border-top:.2ex solid #789;padding-top:.5em}';

module.exports = {
  render: (resume) => base.render(resume).replace('</style>', COMPACT_CSS + '</style>'),
  pdfViewport: base.pdfViewport,
  pdfRenderOptions: base.pdfRenderOptions,
};
